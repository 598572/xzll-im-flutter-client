import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 60),
                _buildLogo(),
                const SizedBox(height: 60),
                _buildUsernameField(),
                const SizedBox(height: 16),
                _buildPasswordField(),
                const SizedBox(height: 24),
                _buildLoginButton(),
                const SizedBox(height: 24),
                _buildDivider(),
                const SizedBox(height: 24),
                _buildRegisterButton(),
                const SizedBox(height: 40),
                _buildFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Center(
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.purple,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.chat_bubble_outline, size: 50, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Text(
            'app_name'.tr,
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.purple),
          ),
          const SizedBox(height: 8),
          Text('app_slogan'.tr, style: TextStyle(fontSize: 16, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildUsernameField() {
    return TextFormField(
      controller: controller.usernameController,
      decoration: InputDecoration(
        labelText: 'username'.tr,
        prefixIcon: const Icon(Icons.person_outline),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.purple),
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'plz_enter_username'.tr;
        }
        return null;
      },
      textInputAction: TextInputAction.next,
    );
  }

  Widget _buildPasswordField() {
    return Obx(
      () => TextFormField(
        controller: controller.passwordController,
        obscureText: controller.obscurePassword.value,
        decoration: InputDecoration(
          labelText: 'password'.tr,
          prefixIcon: const Icon(Icons.lock_outline),
          suffixIcon: IconButton(
            icon: Icon(controller.obscurePassword.value ? Icons.visibility_off : Icons.visibility),
            onPressed: controller.togglePasswordVisibility,
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.purple),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'plz_enter_password'.tr;
          }
          if (value.length < 6) {
            return 'password_too_short'.trParams({'min': 6.toString()});
          }
          return null;
        },
        textInputAction: TextInputAction.done,
        onFieldSubmitted: (_) => controller.handleLogin(),
      ),
    );
  }

  Widget _buildLoginButton() {
    return Obx(
      () => SizedBox(
        height: 50,
        child: ElevatedButton(
          onPressed: controller.isLoading.value ? null : controller.handleLogin,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purple,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 2,
          ),
          child: controller.isLoading.value
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text('login'.tr, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.grey[300])),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text('or'.tr, style: TextStyle(color: Colors.grey[600])),
        ),
        Expanded(child: Divider(color: Colors.grey[300])),
      ],
    );
  }

  Widget _buildRegisterButton() {
    return Obx(
      () => SizedBox(
        height: 50,
        child: OutlinedButton(
          onPressed: controller.isLoading.value ? null : controller.navigateToRegister,
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.purple,
            side: const BorderSide(color: Colors.purple),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text(
            'register_new_account'.tr,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Center(
      child: Column(
        children: [
          Text('login_means_agree'.tr, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  // TODO: 显示用户协议
                },
                child: Text(
                  'user_agreement'.tr,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.purple[600],
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              Text(' ${"and".tr} ', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              GestureDetector(
                onTap: () {
                  // TODO: 显示隐私政策
                },
                child: Text(
                  'privacy_policy'.tr,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.purple[600],
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
