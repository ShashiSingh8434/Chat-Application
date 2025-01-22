import 'package:firebase_database/firebase_database.dart';

final DatabaseReference _database = FirebaseDatabase.instance
    .refFromURL('https://chat-app-shashi-singh-default-rtdb.firebaseio.com/');

Future<void> makeNewUser(String name, String password) async {
  try {
    await _database
        .child("userInfo")
        .push()
        .set({"name": name, "password": password});
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

Future<void> pushData(
    String username, String title, List<Map<String, dynamic>> plan) async {
  String title0 = title;
  for (var i = 0; i < plan.length; i++) {
    Map<String, dynamic> plans = plan[i];
    try {
      await _database
          .child(username)
          .child("data")
          .push()
          .child(title0)
          .update(plans);
    } catch (e) {
      // print("error $e");
    }
  }
}

Future<Map<String, Map<String, dynamic>>> getData(String username) async {
  final Map<String, Map<String, dynamic>> test = {};

  try {
    DataSnapshot dataSnapshot =
        await _database.child(username).child("data").get();

    if (dataSnapshot.exists) {
      final users = dataSnapshot.value as Map<dynamic, dynamic>;

      users.forEach((key, value) {
        final planData = value as Map<dynamic, dynamic>;
        planData.forEach((planKey, planValue) {
          final plan = planValue as Map<dynamic, dynamic>;
          test[planKey] = {
            "item": plan["title"] ?? "N/A",
            "category": plan["category"] ?? "N/A",
            "duration": plan["duration"] ?? 0,
          };
        });
      });
    }
  } catch (e) {
    // print("Error: $e");
  }

  return test;
}
