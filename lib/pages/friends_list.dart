import 'package:chat_application/pages/chat.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'change_notifier.dart';
import 'login.dart';
import 'firebase_logic.dart';

class NameListPage extends StatefulWidget {
  const NameListPage({super.key});

  @override
  NameListPageState createState() => NameListPageState();
}

class NameListPageState extends State<NameListPage> {
  // final List<String> names = [
  //   "John",
  //   "Jane",
  //   "Paul",
  // ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await context.read<UserProvider>().initializeFriendsList();
    });
  }

  void _showAddNameDialog() {
    String newName = "";

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Add New Friend"),
          content: TextField(
            onChanged: (value) {
              newName = value;
            },
            decoration: InputDecoration(hintText: "Enter name"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                if (newName.isNotEmpty) {
                  if (await verifyFriend(newName)) {
                    await context.read<UserProvider>().addFriend(newName);
                  }
                }
                Navigator.of(context).pop();
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final username = context.watch<UserProvider>().username;
    final friendsList = context.watch<UserProvider>().friendsList;

    return Scaffold(
      appBar: AppBar(
        title: Text("Friend List"),
        actions: [
          Consumer<UserProvider>(
            builder: (context, userProvider, child) {
              return TextButton(
                onPressed: () {},
                child: Text(userProvider.username),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () async {
              final username = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginScreen(),
                ),
              );

              if (username != null) {
                context.read<UserProvider>().setUsername(username);
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: friendsList.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(friendsList[index]),
                  onTap: () async {
                    if (await verifyChat(username, friendsList[index])) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(
                              username: username, friend: friendsList[index]),
                        ),
                      );
                    } else {
                      if (await verifyChat(username, friendsList[index]) ==
                          false) {
                        makeNewChat(username, friendsList[index]);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatScreen(
                                username: username, friend: friendsList[index]),
                          ),
                        );
                      }
                    }
                  },
                );
              },
            ),
          ),
          // Button to add a new name
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _showAddNameDialog,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text("Add Name"),
            ),
          ),
        ],
      ),
    );
  }
}
