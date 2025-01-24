import 'package:flutter/material.dart';
import 'firebase_logic.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    //
    final List<Map<String, dynamic>> messages = [
      {'isSender': true, 'message': 'Hi there!'},
      {'isSender': false, 'message': 'Hello! How are you?'},
      {'isSender': true, 'message': 'I am good, thanks! And you?'},
      {'isSender': false, 'message': 'I am fine too. What are you up to?'},
    ];

    // final List<Map<String, dynamic>> messages = getMsg(sender, receiver);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                final isSender = message['isSender'] as bool;
                return Align(
                  alignment:
                      isSender ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSender ? Colors.blue : Colors.grey[300],
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(12),
                        topRight: const Radius.circular(12),
                        bottomLeft:
                            isSender ? const Radius.circular(12) : Radius.zero,
                        bottomRight:
                            isSender ? Radius.zero : const Radius.circular(12),
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
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
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
