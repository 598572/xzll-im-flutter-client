import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'services/auth_service.dart';

// 应用程序入口
void main() => runApp(const XzllImClient());

class XzllImClient extends StatelessWidget {
  const XzllImClient({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '蝎聊',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.purple,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const AuthWrapper(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// 认证包装器，用于检查用户登录状态
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  _AuthWrapperState createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final AuthService _authService = AuthService();
  bool _isLoading = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    try {
      // 初始化认证服务，检查本地存储的登录状态
      final isInitialized = await _authService.initialize();
      
      setState(() {
        _isLoggedIn = isInitialized && _authService.isLoggedIn;
        _isLoading = false;
      });

      // 如果有保存的登录信息但验证失败，显示相关信息
      if (!_isLoggedIn && isInitialized == false) {
        print('本地登录状态验证失败，需要重新登录');
      }
    } catch (e) {
      print('检查认证状态异常: $e');
      setState(() {
        _isLoggedIn = false;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      // 显示启动加载页面
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
                child: const Icon(
                  Icons.chat_bubble_outline,
                  size: 60,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 32),
              
              // 应用名称
              const Text(
                '蝎聊',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
              const SizedBox(height: 16),
              
              // 加载指示器
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
              ),
              const SizedBox(height: 16),
              
              Text(
                '正在启动...',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 根据登录状态决定显示的页面
    return _isLoggedIn ? HomeScreen() : const LoginScreen();
  }
}
