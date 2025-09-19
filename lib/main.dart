import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xzll_im_flutter_client/constant/custom_log.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'services/auth_service.dart';

// 应用程序入口
void main() => runApp(const XzllImClient());

class XzllImClient extends StatelessWidget {
  const XzllImClient({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: '蝎聊',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple, brightness: Brightness.light),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
