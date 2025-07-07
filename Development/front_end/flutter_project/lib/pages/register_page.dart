import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_project/generated/app_localizations.dart';
import 'package:flutter_project/pages/student_version/student_fill_info_page.dart';
import 'package:flutter_project/pages/login.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_project/utils/constant.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_project/utils/color.dart';

class RegisterPage extends StatefulWidget {
  final String userType;

  const RegisterPage({super.key, required this.userType});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _register() async {
  String username = _usernameController.text.trim();
  String password = _passwordController.text.trim();

  if (username.isEmpty || password.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context).pleaseFillAllFields)),
    );
    return;
  }

  setState(() {
    _isLoading = true;
  });

  try {
    final url = Uri.parse("$baseApiUrl/login/signup");

    final headers = {
      "username": username,
      "password": password,
      "accountType": widget.userType.toUpperCase(), // 确保是 STUDENT 或 TEACHER
    };

    // 🔍 可选调试输出
    print("📤 正在发送注册请求 headers: $headers");

    final response = await http.post(url, headers: headers);

    setState(() {
      _isLoading = false;
    });

    print("🔵 Response (${response.statusCode}): ${response.body}");

    final responseBody = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final token = responseBody["token"];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      await prefs.setString('username', username);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).registrationSuccessful)),
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StudentUserInfoPage(
            username: username,
            token: token,
          ),
        ),
      );
    } else {
      // 注册失败，例如用户名已存在
      final errorMsg = responseBody["message"] ?? AppLocalizations.of(context).registrationFailed;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMsg)));
    }
  } catch (e) {
    setState(() {
      _isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Unexpected error: $e")),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double baseWidth = 2160;
    double baseHeight = 1080;
    double scaleX = screenWidth / baseWidth;
    double scaleY = screenHeight / baseHeight;
    double inputHeight = screenHeight * 0.08;
    double rightShift = screenWidth * 0.20;
    final double gap = 32 * scaleX;
    final double buttonWidth = (screenWidth * 0.284 - gap) / 2;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          width: screenWidth,
          height: screenHeight,
          decoration: const BoxDecoration(color: AppColors.background),
          child: Stack(
            children: [
              // 背景三层卡片
              Positioned(
                left: (-240 * scaleX),
                top: -80 * scaleY,
                child: Container(
                  transform: Matrix4.identity()..rotateZ(0.09),
                  width: 1278.26 * scaleX,
                  height: 1300.66 * scaleY,
                  decoration: ShapeDecoration(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(side: BorderSide(width: 1.5)),
                    shadows: [
                      BoxShadow(
                        color: Color(0x3F000000),
                        blurRadius: 35,
                        offset: Offset(4, 4),
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: -260 * scaleX,
                top: -100 * scaleY,
                child: Container(
                  transform: Matrix4.identity()..rotateZ(0.09),
                  width: 1278.26 * scaleX,
                  height: 1300.66 * scaleY,
                  decoration: ShapeDecoration(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(side: BorderSide(width: 1.5)),
                    shadows: [
                      BoxShadow(
                        color: Color(0x3F000000),
                        blurRadius: 35,
                        offset: Offset(4, 4),
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: -280 * scaleX,
                top: -125 * scaleY,
                child: Container(
                  transform: Matrix4.identity()..rotateZ(0.09),
                  width: 1278.26 * scaleX,
                  height: 1300.66 * scaleY,
                  decoration: ShapeDecoration(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(side: BorderSide(width: 1.5)),
                    shadows: [
                      BoxShadow(
                        color: Color(0x3F000000),
                        blurRadius: 35,
                        offset: Offset(4, 4),
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                ),
              ),
              // 插图
              Positioned(
                left: -100 * scaleX,
                top: 60 * scaleY,
                child: SizedBox(
                  width: 976 * scaleX,
                  height: 976 * scaleY,
                  child: Image.asset(
                    'assets/images/circle.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              // 标题
              Positioned(
                left: (855 * scaleX + rightShift),
                top: 234 * scaleY,
                child: Text(
                  '${AppLocalizations.of(context).registerAs} ${widget.userType}',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 48 * scaleX,
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              // 用户名
              Positioned(
                left: (855 * scaleX + rightShift),
                top: 354 * scaleY,
                child: Text(
                  AppLocalizations.of(context).name,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 32 * scaleX,
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Positioned(
                left: (855 * scaleX + rightShift),
                top: 413 * scaleY,
                child: SizedBox(
                  width: screenWidth * 0.284,
                  height: inputHeight,
                  child: TextField(
                    controller: _usernameController,
                    textAlignVertical: TextAlignVertical.center,
                    style: TextStyle(fontSize: 30 * scaleX),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.inputBackgroundColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 20),
                      hintText: AppLocalizations.of(context).enterYourName,
                      hintStyle: const TextStyle(color: Colors.black45),
                    ),
                  ),
                ),
              ),

              // 密码
              Positioned(
                left: (855 * scaleX + rightShift),
                top: 515 * scaleY,
                child: Text(
                  AppLocalizations.of(context).password,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 32 * scaleX,
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Positioned(
                left: (855 * scaleX + rightShift),
                top: 573 * scaleY,
                child: SizedBox(
                  width: screenWidth * 0.284,
                  height: inputHeight,
                  child: TextField(
                    controller: _passwordController,
                    obscureText: true,
                    textAlignVertical: TextAlignVertical.center,
                    style: TextStyle(fontSize: 30 * scaleX),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.inputBackgroundColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 20),
                      hintText: AppLocalizations.of(context).enterYourPassword,
                      hintStyle: const TextStyle(color: Colors.black45),
                    ),
                  ),
                ),
              ),
              // ✅ 将“已有账号？登录” 放在密码输入框下方，右对齐
              Positioned(
                left: (855 * scaleX + rightShift),
                top: (573 * scaleY + inputHeight + 20 * scaleY),
                child: SizedBox(
                  width: screenWidth * 0.284,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LoginPage()),
                        );
                      },
                      child: Text(
                        AppLocalizations.of(context).alreadyHaveAccount,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 24 * scaleX,
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.w400,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // 返回按钮
              Positioned(
                left: (855 * scaleX + rightShift),
                top: 750 * scaleY,
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: buttonWidth,
                    height: inputHeight,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x3F000000),
                          blurRadius: 15,
                          spreadRadius: 0,
                        )
                      ],
                    ),
                    child: Center(
                      child: Text(
                        AppLocalizations.of(context).back,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 32 * scaleX,
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // 注册按钮
              Positioned(
                left: (855 * scaleX + rightShift + buttonWidth + gap),
                top: 750 * scaleY,
                child: GestureDetector(
                  onTap: _register,
                  child: Container(
                    width: buttonWidth,
                    height: inputHeight,
                    decoration: BoxDecoration(
                      color: const Color(0xFF292929),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              AppLocalizations.of(context).next,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 32 * scaleX,
                                fontFamily: 'Manrope',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
