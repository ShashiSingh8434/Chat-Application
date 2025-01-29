import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'pages/change_notifier.dart';
import 'pages/friends_list.dart';
import 'video_call_feature.dart';
// import 'pages/chat.dart';

// this app is working fine but we have to solve the false cases
// work on this on free time

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Hive.initFlutter();
  // await Hive.openBox('myBox');
  await Firebase.initializeApp();

  runApp(ChangeNotifierProvider(
      create: (context) => UserProvider()..initializeUser(),
      child: const MyApp()));
}

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: const NameListPage(),
//     );
//   }
// }

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: VideoCallPage(),
    );
  }
}
