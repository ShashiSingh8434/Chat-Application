import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:permission_handler/permission_handler.dart';

class VideoCallPage extends StatefulWidget {
  const VideoCallPage({super.key});

  @override
  _VideoCallPageState createState() => _VideoCallPageState();
}

class _VideoCallPageState extends State<VideoCallPage> {
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  String? roomId;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    requestPermissions();
    _initializeRenderers();
  }

  Future<void> requestPermissions() async {
    await Permission.camera.request();
    await Permission.microphone.request();
  }

  Future<void> _initializeRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
  }

  @override
  void dispose() {
    _endCall(); // Ensure cleanup on dispose
    super.dispose();
  }

  Future<void> _startCall() async {
    await _getUserMedia();
    await _createPeerConnection();
    await _createOffer();
  }

  Future<void> _joinCall(String roomId) async {
    await _getUserMedia();
    await _createPeerConnection();
    await _listenForOffer(roomId);
  }

  Future<void> _getUserMedia() async {
    _localStream = await navigator.mediaDevices.getUserMedia({
      'video': true,
      'audio': true,
    });

    setState(() {
      _localRenderer.srcObject = _localStream;
    });
  }

  Future<void> _createPeerConnection() async {
    _peerConnection = await createPeerConnection({
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'}
      ],
    });

    _peerConnection!.onIceCandidate = (candidate) {
      if (candidate != null && roomId != null) {
        String candidateType = _peerConnection!.signalingState ==
                RTCSignalingState.RTCSignalingStateHaveLocalOffer
            ? 'callerCandidates'
            : 'calleeCandidates';

        _firestore
            .collection('calls')
            .doc(roomId)
            .collection(candidateType)
            .add({
          'candidate': candidate.candidate,
          'sdpMid': candidate.sdpMid,
          'sdpMLineIndex': candidate.sdpMLineIndex,
        });
      }
    };

    _peerConnection!.onTrack = (event) {
      if (event.track.kind == 'video') {
        setState(() {
          _remoteRenderer.srcObject = event.streams[0];
        });
      }
    };

    _localStream!.getTracks().forEach((track) {
      _peerConnection!.addTrack(track, _localStream!);
    });
  }

  Future<void> _createOffer() async {
    final offer = await _peerConnection!.createOffer();
    await _peerConnection!.setLocalDescription(offer);

    final docRef = await _firestore.collection('calls').add({
      'offer': {
        'sdp': offer.sdp,
        'type': offer.type,
      },
    });

    setState(() {
      roomId = docRef.id;
    });

    _firestore
        .collection('calls')
        .doc(roomId)
        .snapshots()
        .listen((snapshot) async {
      if (snapshot.data()?['answer'] != null) {
        final answer = snapshot.data()!['answer'];
        await _peerConnection!.setRemoteDescription(
          RTCSessionDescription(answer['sdp'], answer['type']),
        );
      }
    });

    _listenForIceCandidates(roomId!, 'calleeCandidates');
  }

  Future<void> _listenForOffer(String roomId) async {
    this.roomId = roomId;
    final docSnapshot = await _firestore.collection('calls').doc(roomId).get();

    if (docSnapshot.exists) {
      final offer = docSnapshot.data()?['offer'];
      await _peerConnection!.setRemoteDescription(
        RTCSessionDescription(offer['sdp'], offer['type']),
      );

      final answer = await _peerConnection!.createAnswer();
      await _peerConnection!.setLocalDescription(answer);

      await _firestore.collection('calls').doc(roomId).update({
        'answer': {
          'sdp': answer.sdp,
          'type': answer.type,
        }
      });

      _listenForIceCandidates(roomId, 'callerCandidates');
    }
  }

  void _listenForIceCandidates(String roomId, String candidateType) {
    _firestore
        .collection('calls')
        .doc(roomId)
        .collection(candidateType)
        .snapshots()
        .listen((snapshot) {
      for (var doc in snapshot.docs) {
        final data = doc.data();
        _peerConnection!.addCandidate(
          RTCIceCandidate(
              data['candidate'], data['sdpMid'], data['sdpMLineIndex']),
        );
      }
    });
  }

  Future<void> _endCall() async {
    await _peerConnection?.close();
    _peerConnection = null;

    if (roomId != null) {
      await _firestore.collection('calls').doc(roomId).delete();
    }

    _localRenderer.srcObject = null;
    _remoteRenderer.srcObject = null;
    _localStream?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('WebRTC Video Call')),
      body: Column(
        children: [
          Expanded(child: RTCVideoView(_localRenderer, mirror: true)),
          Expanded(child: RTCVideoView(_remoteRenderer)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _startCall,
                child: const Text('Start Call'),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      TextEditingController controller =
                          TextEditingController();
                      return AlertDialog(
                        title: const Text('Enter Room ID'),
                        content: TextField(controller: controller),
                        actions: [
                          TextButton(
                            onPressed: () {
                              _joinCall(controller.text);
                              Navigator.pop(context);
                            },
                            child: const Text('Join'),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: const Text('Join Call'),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: _endCall,
                child: const Text('End Call'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
