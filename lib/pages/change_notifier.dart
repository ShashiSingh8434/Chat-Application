import 'package:hive/hive.dart';
import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  String _username = '';
  List<String> _friendsList = [];

  String get username => _username;
  List<String> get friendsList => _friendsList;

  Future<void> initializeUser() async {
    var box = await Hive.openBox('myBox');
    _username = box.get('username', defaultValue: '') ?? '';
    notifyListeners();
  }

  Future<void> setUsername(String newUsername) async {
    var box = await Hive.openBox('myBox');

    await box.delete('username');

    _username = newUsername;
    await box.put('username', newUsername);
    notifyListeners();
  }

  Future<void> clearUsernameFromHive() async {
    var box = await Hive.openBox('myBox');
    await box.delete('username');
    _username = '';
    notifyListeners();
  }

  Future<void> initializeFriendsList() async {
    var box = await Hive.openBox('friendsBox');
    _friendsList = List<String>.from(box.get('friends', defaultValue: []));
    notifyListeners();
  }

  Future<void> addFriend(String newFriend) async {
    var box = await Hive.openBox('friendsBox');
    _friendsList.add(newFriend);
    await box.put('friends', _friendsList);
    notifyListeners();
  }
}
