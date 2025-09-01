import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_project/generated/app_localizations.dart';
import 'package:flutter_project/pages/forgot_password_page.dart';
import 'package:flutter_project/pages/register_page.dart';
import 'package:flutter_project/pages/student_version/student_fill_info_page.dart';
import 'package:flutter_project/pages/teacher_version/teacher_fill_info_page.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_project/utils/constant.dart';
import 'package:flutter_project/pages/student_version/student_choose_class.dart';
import 'package:flutter_project/pages/teacher_version/teacher_choose_class.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_project/utils/color.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _userFocus = FocusNode();
  final FocusNode _passFocus = FocusNode();

  bool _isLoading = false;
  bool _passwordVisible = false;

  Future<void> _login() async {
    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.pleaseEnterBothFields),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final url = Uri.parse("$baseApiUrl/login/signin");
      final response = await http.post(
        url,
        headers: {"Username": username, "Password": password},
      );

      setState(() => _isLoading = false);

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final token = responseBody["token"];
        final accountType = responseBody["accountType"];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        await prefs.setString('username', username);
        await prefs.setString('accountType', accountType);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(AppLocalizations.of(context)!.loginSuccessful)),
        );

        await Future.delayed(const Duration(milliseconds: 500));
        await _checkUserInfo(username, token, accountType);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              responseBody["error"] ??
                  AppLocalizations.of(context)!.loginFailed,
            ),
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.networkError)),
      );
    }
  }

  Future<void> _checkUserInfo(
      String username, String token, String accountType) async {
    final url = Uri.parse("$baseApiUrl/login/check");
    final headers = {"Username": username, "Token": token};

    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 204) {
        // 信息不完整 → 跳转填写信息
        if (accountType == "TEACHER") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  TeacherUserInfoPage(username: username, token: token),
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  StudentUserInfoPage(username: username, token: token),
            ),
          );
        }
      } else if (response.statusCode == 200) {
        // 信息完整 → 跳转选择课程
        if (accountType == "TEACHER") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => TeacherChooseClassPage(teacherName: username),
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => StudentChooseClassPage(studentName: username),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.networkError)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.networkError)),
      );
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _userFocus.dispose();
    _passFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 与注册页一致的基准
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final baseWidth = 2160.0;
    final baseHeight = 1080.0;
    final scaleX = screenWidth / baseWidth;
    final scaleY = screenHeight / baseHeight;
    final rightShift = screenWidth * 0.20;

    // 输入区与注册页一致的宽与高度、面板位置微调
    final panelWidth = screenWidth * 0.30; // 与注册页一致
    final panelLeft = (855 * scaleX + rightShift) - 40 * scaleX; // 往左微调
    final panelTop = -70 * scaleY; // 往上微调
    final inputHeight = screenHeight * 0.08;
    final inputHeightRight = inputHeight * 1.12; // 与注册页一致的“更高一点”
    final gap = 32 * scaleX;
    final buttonWidth = (screenWidth * 0.284 - gap) / 2;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          width: screenWidth,
          height: screenHeight,
          decoration: const BoxDecoration(color: AppColors.background),
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => FocusScope.of(context).unfocus(), // 点击空白收起键盘
            child: Stack(
              children: [
                // 左侧三层斜叠容器（保持不变）
                Positioned(
                  left: (-240 * scaleX),
                  top: -80 * scaleY,
                  child: Container(
                    transform: Matrix4.identity()..rotateZ(0.09),
                    width: 1278.26 * scaleX,
                    height: 1300.66 * scaleY,
                    decoration: ShapeDecoration(
                      color: Colors.white,
                      shape: const RoundedRectangleBorder(
                        side: BorderSide(width: 1.5),
                      ),
                      shadows: const [
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
                      shape: const RoundedRectangleBorder(
                        side: BorderSide(width: 1.5),
                      ),
                      shadows: const [
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
                      shape: const RoundedRectangleBorder(
                        side: BorderSide(width: 1.5),
                      ),
                      shadows: const [
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
                // 插图（保持不变）
                Positioned(
                  left: -100 * scaleX,
                  top: 60 * scaleY,
                  child: SizedBox(
                    width: 976 * scaleX,
                    height: 976 * scaleY,
                    child: Image.asset('assets/images/circle.png',
                        fit: BoxFit.contain),
                  ),
                ),

                // 右侧可滚动面板 —— 与注册页对齐
                Positioned(
                  left: panelLeft,
                  top: panelTop,
                  width: panelWidth,
                  bottom: 0,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () => FocusScope.of(context).unfocus(),
                    child: SingleChildScrollView(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                      ),
                      child: SizedBox(
                        height: 1300 * scaleY, // 与注册页相同的滚动内容高度
                        child: Stack(
                          children: [
                            // 标题
                            Positioned(
                              left: 0,
                              top: 234 * scaleY,
                              child: Text(
                                AppLocalizations.of(context)!.login,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 48 * scaleX,
                                  fontFamily: 'Manrope',
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),

                            // 用户名标签
                            Positioned(
                              left: 0,
                              top: 354 * scaleY,
                              child: Text(
                                AppLocalizations.of(context)!.name,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 32 * scaleX,
                                  fontFamily: 'Manrope',
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                            // 用户名输入
                            Positioned(
                              left: 0,
                              top: 413 * scaleY,
                              child: SizedBox(
                                width: panelWidth,
                                height: inputHeightRight,
                                child: TextField(
                                  controller: _usernameController,
                                  focusNode: _userFocus,
                                  textInputAction: TextInputAction.next,
                                  onSubmitted: (_) => _passFocus.requestFocus(),
                                  textAlignVertical: TextAlignVertical.center,
                                  style: TextStyle(fontSize: 30 * scaleX),
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: AppColors.inputBackgroundColor,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide.none,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 20),
                                    hintText: AppLocalizations.of(context)!
                                        .enterYourName,
                                    hintStyle:
                                        const TextStyle(color: Colors.black45),
                                  ),
                                ),
                              ),
                            ),

                            // 密码标签
                            Positioned(
                              left: 0,
                              top: 515 * scaleY,
                              child: Text(
                                AppLocalizations.of(context)!.password,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 32 * scaleX,
                                  fontFamily: 'Manrope',
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                            // 密码输入 + 显示切换
                            Positioned(
                              left: 0,
                              top: 573 * scaleY,
                              child: SizedBox(
                                width: panelWidth,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    SizedBox(
                                      height: inputHeightRight,
                                      child: TextField(
                                        controller: _passwordController,
                                        focusNode: _passFocus,
                                        textInputAction: TextInputAction.done,
                                        onSubmitted: (_) => _login(),
                                        obscureText: !_passwordVisible,
                                        textAlignVertical:
                                            TextAlignVertical.center,
                                        style: TextStyle(fontSize: 30 * scaleX),
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor:
                                              AppColors.inputBackgroundColor,
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: BorderSide.none,
                                          ),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 20),
                                          hintText:
                                              AppLocalizations.of(context)!
                                                  .enterYourPassword,
                                          hintStyle: const TextStyle(
                                              color: Colors.black45),
                                          suffixIcon: IconButton(
                                            icon: Icon(
                                              _passwordVisible
                                                  ? Icons.visibility
                                                  : Icons.visibility_off,
                                              color: Colors.grey,
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                _passwordVisible =
                                                    !_passwordVisible;
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 20 * scaleY),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) =>
                                                  const ForgotPasswordPage()),
                                        );
                                      },
                                      child: Text(
                                        AppLocalizations.of(context)!
                                            .forgotPassword,
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 24 * scaleX,
                                          fontFamily: 'Manrope',
                                          fontWeight: FontWeight.w400,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // 按钮区（与注册页一致的按钮高度/间距风格）
                            Positioned(
                              left: 0,
                              top: 750 * scaleY,
                              child: Row(
                                children: [
                                  // 注册
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => const RegisterPage(
                                              userType: "Student"),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      width: (screenWidth * 0.284 - gap) / 2,
                                      height: inputHeightRight,
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
                                          AppLocalizations.of(context)!.signUp,
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
                                  SizedBox(width: gap),
                                  // 登录
                                  GestureDetector(
                                    onTap: _login,
                                    child: Container(
                                      width: (screenWidth * 0.284 - gap) / 2,
                                      height: inputHeightRight,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF292929),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Center(
                                        child: _isLoading
                                            ? const CircularProgressIndicator(
                                                color: Colors.white)
                                            : Text(
                                                AppLocalizations.of(context)!
                                                    .signIn,
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
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
