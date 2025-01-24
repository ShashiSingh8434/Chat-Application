import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

final DatabaseReference _database = FirebaseDatabase.instance
    .refFromURL('https://chat-app-shashi-singh-default-rtdb.firebaseio.com/');

Future<void> makeNewUser(String name, String password) async {
  try {
    await _database
        .child("userInfo")
        .push()
        .set({"name": name, "password": password});

    print("made a user");
  } catch (e) {
    print("error $e   this is a error");
  }
}

Future<void> makeNewChat(String member1, String member2) async {
  String chatname = "$member1-$member2 chat";
  try {
    if (await verifyChat(member1, member2)) {
    } else if (await verifyChat(member2, member1)) {
    } else {
      await _database
          .child("chatID")
          .push()
          .set({"member1": member1, "member2": member2});
      await _database
          .child(chatname)
          .child("member names")
          .set({"member1": member1, "member2": member2});
    }
  } catch (e) {
    // print("error $e");
  }
}

Future<bool> verifyUser(String name, String password) async {
  bool verifiedUser = false;
  try {
    DataSnapshot dataSnapshot = await _database.child("userInfo").get();

    if (dataSnapshot.exists) {
      final users = dataSnapshot.value as Map<dynamic, dynamic>;

      users.forEach((key, value) {
        if (value['name'] == name) {
          if (value['password'] == password) {
            verifiedUser = true;
          }
        }
      });
    }
  } catch (e) {
    // print("error $e");
  }
  return verifiedUser;
}

Future<bool> verifyChat(String member1, String member2) async {
  bool verifiedChat = false;
  try {
    DataSnapshot dataSnapshot = await _database.child("chatID").get();

    if (dataSnapshot.exists) {
      final users = dataSnapshot.value as Map<dynamic, dynamic>;

      users.forEach((key, value) {
        if (value['member1'] == member1) {
          if (value['member2'] == member2) {
            verifiedChat = true;
          }
        }
      });
    }
  } catch (e) {
    // print("error $e");
  }
  return verifiedChat;
}

Future<void> pushMsg(String sender, String receiver, String message) async {
  // datetime format is yyyy-mm-dd-hh-mm-ss
  DateTime now = DateTime.now();
  String datetime = DateFormat('yyyy-MM-dd-HH-mm-ss').format(now);
  Map<String, String> sendData = {"sender": sender, "message": message};
  String chatname = "";
  if (await verifyChat(sender, receiver)) {
    chatname = "$sender-$receiver chat";
  } else if (await verifyChat(receiver, sender)) {
    chatname = "$receiver-$sender chat";
  } else {
    chatname = "";
  }

  if (chatname != "") {
    try {
      await _database
          .child(chatname)
          .child("messages")
          .child(datetime)
          .set(sendData);
    } catch (e) {
      // print("error $e");
    }
  }
}

Future<List<Map<String, dynamic>>> getMsg(
    String sender, String receiver) async {
  String chatname = "";
  if (await verifyChat(sender, receiver)) {
    chatname = "$sender-$receiver chat";
  } else if (await verifyChat(receiver, sender)) {
    chatname = "$receiver-$sender chat";
  } else {
    chatname = "";
  }

  List<Map<String, dynamic>> messagesList = [];

  try {
    DataSnapshot dataSnapshot =
        await _database.child(chatname).child("messages").get();

    if (dataSnapshot.exists) {
      final allData = dataSnapshot.value as Map<dynamic, dynamic>;

      messagesList = allData.values
          .map((value) => Map<String, dynamic>.from(value))
          .toList();
    }
  } catch (e) {
    // print("Error: $e");
  }

// Sample --->
// messagesList = [
//   {"sender": "Alice", "message": "Hi!"},
//   {"sender": "Bob", "message": "Hello!"}
// ]

  return messagesList;
}
