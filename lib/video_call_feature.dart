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
  bool _isCaller = false;

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
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    super.dispose();
  }

  Future<void> _startCall() async {
    try {
      await _getUserMedia();
      await _createPeerConnection();
      await _createOffer();
    } catch (e) {
      print("Error starting call: $e");
    }
  }

  Future<void> _joinCall(String roomId) async {
    try {
      await _getUserMedia();
      await _createPeerConnection();
      await _listenForOffer(roomId);
    } catch (e) {
      print("Error joining call: $e");
    }
  }

  Future<void> _getUserMedia() async {
    try {
      _localStream = await navigator.mediaDevices.getUserMedia({
        'video': true,
        'audio': true,
      });

      setState(() {
        _localRenderer.srcObject = _localStream;
      });
    } catch (e) {
      print("Error getting user media: $e");
    }
  }

  Future<void> _createPeerConnection() async {
    try {
      _peerConnection = await createPeerConnection({
        'iceServers': [
          {'urls': 'stun:stun.l.google.com:19302'}
        ],
      });

      _peerConnection!.onIceCandidate = (candidate) async {
        if (candidate != null && roomId != null) {
          String collectionName =
              _isCaller ? 'callerCandidates' : 'calleeCandidates';
          await _firestore
              .collection('calls')
              .doc(roomId)
              .collection(collectionName)
              .add({
            'candidate': candidate.candidate,
            'sdpMid': candidate.sdpMid,
            'sdpMLineIndex': candidate.sdpMLineIndex,
          });
        }
      };

      _peerConnection!.onTrack = (event) {
        if (event.track.kind == 'video') {
          print("Remote video track received");
          setState(() {
            _remoteRenderer.srcObject = event.streams[0];
          });
        }
      };

      if (_localStream != null) {
        _localStream!.getTracks().forEach((track) {
          _peerConnection!.addTrack(track, _localStream!);
        });
      }
    } catch (e) {
      print("Error creating peer connection: $e");
    }
  }

  Future<void> _createOffer() async {
    try {
      if (_peerConnection == null) return;

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
        _isCaller = true;
      });

      _firestore
          .collection('calls')
          .doc(roomId)
          .snapshots()
          .listen((snapshot) async {
        if (snapshot.exists && snapshot.data()?['answer'] != null) {
          final answer = snapshot.data()!['answer'];
          await _peerConnection!.setRemoteDescription(
            RTCSessionDescription(answer['sdp'], answer['type']),
          );
        }
      });

      _listenForIceCandidates(roomId!, 'calleeCandidates');
    } catch (e) {
      print("Error creating offer: $e");
    }
  }

  Future<void> _listenForOffer(String roomId) async {
    try {
      this.roomId = roomId;
      _isCaller = false;

      final docSnapshot =
          await _firestore.collection('calls').doc(roomId).get();

      if (docSnapshot.exists && docSnapshot.data()?['offer'] != null) {
        final offer = docSnapshot.data()!['offer'];
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
    } catch (e) {
      print("Error listening for offer: $e");
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
    try {
      await _peerConnection?.close();
      _peerConnection = null;

      if (roomId != null) {
        await _firestore.collection('calls').doc(roomId).delete();
      }

      setState(() {
        _localRenderer.srcObject = null;
        _remoteRenderer.srcObject = null;
      });

      _localStream?.dispose();
    } catch (e) {
      print("Error ending call: $e");
    }
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
