import 'package:flutter/material.dart';
import 'firebase_logic.dart';

class ChatScreen extends StatefulWidget {
  final String username;
  final String friend;

  const ChatScreen({
    super.key,
    required this.username,
    required this.friend,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late Future<List<Map<String, dynamic>>> messagesFuture;
  TextEditingController messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Fetch messages when the screen initializes
    messagesFuture = getMsg(widget.username, widget.friend);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with ${widget.username} and ${widget.friend}'),
      ),
      body: Column(
        children: [
          // Use FutureBuilder to handle the asynchronous messages
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: messagesFuture,
              builder: (context, snapshot) {
                // Handle different states of the Future
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // Show a loading indicator while waiting for data
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  // Handle errors
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  // Handle the case where there are no messages
                  return const Center(child: Text('No messages yet.'));
                } else {
                  // Data is available; build the ListView
                  final messages = snapshot.data!;
                  return ListView.builder(
                    padding: const EdgeInsets.all(8.0),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final isSender = message['sender'] == widget.username;

                      return Align(
                        alignment: isSender
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSender ? Colors.blue : Colors.grey[300],
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(12),
                              topRight: const Radius.circular(12),
                              bottomLeft: isSender
                                  ? const Radius.circular(12)
                                  : Radius.zero,
                              bottomRight: isSender
                                  ? Radius.zero
                                  : const Radius.circular(12),
                            ),
                          ),
                          child: Text(
                            message['message'],
                            style: TextStyle(
                              color: isSender ? Colors.white : Colors.black,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () {
                    // Add functionality to send a message
                    if (messageController.text != "") {
                      pushMsg(widget.username, widget.friend,
                          messageController.text);
                    }
                    messageController.clear();
                    setState(() {
                      messagesFuture = getMsg(widget.username, widget.friend);
                    });
                  },
                  icon: const Icon(Icons.send, color: Colors.blue),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
