import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xzll_im_flutter_client/screens/splash/splash_logic.dart';

class SplashPage extends GetView<SplashLogic> {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint("${controller.hashCode}");
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.purple,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(Icons.chat_bubble_outline, size: 60, color: Colors.white),
            ),
            const SizedBox(height: 32),

            // 应用名称
            Text(
              "app_name".tr,
              style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.purple),
            ),
            const SizedBox(height: 16),

            // 加载指示器
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
            ),
            const SizedBox(height: 16),

            Text("starting".tr, style: TextStyle(fontSize: 16, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }
}
