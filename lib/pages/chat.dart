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
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    messagesFuture = getMsg(widget.username, widget.friend);
    _scrollToBottom(); // Scroll when the screen loads
  }

  Future<void> _refreshMessages() async {
    setState(() {
      messagesFuture = getMsg(widget.username, widget.friend);
    });
    await Future.delayed(const Duration(milliseconds: 100)); // Wait for refresh
    _scrollToBottom(); // Ensure scrolling after refreshing
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with ${widget.username} and ${widget.friend}'),
      ),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshMessages,
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: messagesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No messages yet.'));
                  } else {
                    final messages = snapshot.data!;
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (_scrollController.hasClients) {
                        _scrollController.jumpTo(
                          _scrollController.position.maxScrollExtent,
                        );
                      }
                    });
                    return ListView.builder(
                      controller: _scrollController,
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
                  onPressed: () async {
                    if (messageController.text.isNotEmpty) {
                      await pushMsg(widget.username, widget.friend,
                          messageController.text);
                      messageController.clear();
                      setState(() {
                        messagesFuture = getMsg(widget.username, widget.friend);
                      });
                      Future.delayed(const Duration(milliseconds: 100), () {
                        _scrollToBottom();
                      });
                    }
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
