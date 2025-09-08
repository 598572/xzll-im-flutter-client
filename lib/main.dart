import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

// 应用程序入口
void main() => runApp(const XzllImClient());

class XzllImClient extends StatelessWidget {
  const XzllImClient({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '蝎聊',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: HomeScreen(),
    );
  }
}
