import 'package:flutter/material.dart';

import 'pages/friends_list.dart';
import 'pages/chat.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const NameListPage(),
    );
  }
}
