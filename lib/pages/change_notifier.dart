import 'package:hive/hive.dart';
import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  String _username = '';

  String get username => _username;

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
}
