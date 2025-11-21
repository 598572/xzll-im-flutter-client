import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'pages/login_page.dart';
import 'pages/main_page.dart';
import 'providers/auth_provider.dart';
import 'services/user_cache_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化用户缓存服务
  await UserCacheService.instance.initialize();
  
  runApp(SimpleImApp());
}

class SimpleImApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AuthProvider(),
      child: MaterialApp(
        title: 'IM Flutter Client',
        theme: ThemeData(
          primarySwatch: Colors.green,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: Consumer<AuthProvider>(
          builder: (context, auth, child) {
            // 根据登录状态显示不同页面
            return auth.isLoggedIn ? MainPage() : LoginPage();
          },
        ),
      ),
    );
  }
}
