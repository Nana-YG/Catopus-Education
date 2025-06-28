import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_project/generated/app_localizations.dart';
import 'package:flutter_project/pages/student_version/student_fill_info_page.dart';
import 'package:flutter_project/pages/register_page.dart';
import 'package:flutter_project/pages/teacher_version/teacher_fill_info_page.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:flutter_project/utils/constant.dart';
import 'package:flutter_project/pages/student_version/student_choose_class.dart';
import 'package:flutter_project/pages/teacher_version/teacher_choose_class.dart';
import 'package:flutter_project/test.dart';
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
  bool _isLoading = false;

  bool _passwordVisible = false;

  Future<void> _login() async {
    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(AppLocalizations.of(context)!.pleaseEnterBothFields)),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      var url = Uri.parse("$baseApiUrl/login/signin");

      var response = await http.post(
        url,
        headers: {
          "Username": username,
          "Password": password,
        },
      );

      setState(() {
        _isLoading = false;
      });

      var responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        print("🔹 [CHECK LOGIN] Status: ${response.statusCode}");
        print("🔹 [CHECK LOGIN] Body: ${response.body}");
        String token = responseBody["token"];
        String accountType = responseBody["accountType"]; // ✅ 获取 accountType

        // **存储 token, username, accountType**
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        await prefs.setString('username', username);
        await prefs.setString('accountType', accountType); // ✅ 存储 accountType

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(AppLocalizations.of(context)!.loginSuccessful)),
        );

// ✅ 等待 SnackBar 显示完成后再跳转
        await Future.delayed(const Duration(milliseconds: 500));
        await _checkUserInfo(username, token, accountType);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(responseBody["error"] ??
                  AppLocalizations.of(context)!.loginFailed)),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.networkError)),
      );
    }
  }

  Future<void> _checkUserInfo(
      String username, String token, String accountType) async {
    final url = Uri.parse("$baseApiUrl/login/check");
    final headers = {
      "Username": username,
      "Token": token,
    };

    try {
      final response = await http.get(url, headers: headers);

      print("🔹 [CHECKINFO LOGIN] Status: ${response.statusCode}");
      print("🔹 [CHECKINFO LOGIN] Body: ${response.body}");

      if (response.statusCode == 204) {
        print("❌ 用户信息不完整，需要填写信息");

        // ✅ 根据 accountType 跳转到对应的信息填写页面
        if (accountType == "TEACHER") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => TeacherUserInfoPage(
                username: username,
                token: token,
              ),
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => StudentUserInfoPage(
                username: username,
                token: token,
              ),
            ),
          );
        }
      } else if (response.statusCode == 200) {
        print("✅ 用户信息完整，跳转到选择课程页面");

        var userInfo = jsonDecode(response.body);

        if (accountType == "TEACHER") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => TeacherChooseClassPage(
                teacherName: username,
              ),
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => StudentChooseClassPage(
                studentName: username,
              ),
            ),
          );
        }
      } else {
        print("❌ 服务器返回错误: ${response.statusCode}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.networkError)),
        );
      }
    } catch (e) {
      print("❌ 登录检查失败: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.networkError)),
      );
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // ✅ **UI 代码完全保留，不做任何修改**
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double rightShift = screenWidth * 0.20; // 👈 向右偏移 25% 屏幕宽度

    double baseWidth = 2160;
    double baseHeight = 1080;
    double scaleX = screenWidth / baseWidth;
    double scaleY = screenHeight / baseHeight;
    final double gap = 32 * scaleX;
    final double buttonWidth = (screenWidth * 0.284 - gap) / 2;
    double inputHeight = screenHeight * 0.08;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          width: screenWidth,
          height: screenHeight,
          decoration: const BoxDecoration(color: AppColors.background),
          child: Stack(
            children: [
              // 左侧三个斜叠容器
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
              // ✅ 放在三层卡片的上方
              Positioned(
                left: -100 * scaleX, // 根据卡片整体偏移微调
                top: 60 * scaleY,
                child: SizedBox(
                  width: 976 * scaleX,
                  height: 976 * scaleY,
                  child: Image.asset(
                    'assets/images/circle.png', // ✅ 你的插图路径
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              Positioned(
                left: (855 * scaleX + rightShift),
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

              Positioned(
                left: (855 * scaleX + rightShift),
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
              Positioned(
                left: (855 * scaleX + rightShift),
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
                      hintText: AppLocalizations.of(context)!.enterYourName,
                      hintStyle: const TextStyle(color: Colors.black45),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: (855 * scaleX + rightShift),
                top: 573 * scaleY,
                child: SizedBox(
                  width: screenWidth * 0.284, // ✅ 同 username
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      SizedBox(
                        height: inputHeight, // ✅ 同 username
                        child: TextField(
                          controller: _passwordController,
                          obscureText: !_passwordVisible,
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
                            hintText:
                                AppLocalizations.of(context)!.enterYourPassword,
                            hintStyle: const TextStyle(color: Colors.black45),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _passwordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                setState(() {
                                  _passwordVisible = !_passwordVisible;
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20 * scaleY),
                      GestureDetector(
                        onTap: () {
                          // TODO: 忘记密码逻辑
                        },
                        child: Text(
                          AppLocalizations.of(context)!.forgotPassword,
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
// 👉 定义按钮宽度和间距

// 注册按钮
              Positioned(
                left: (855 * scaleX + rightShift),
                top: 750 * scaleY,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const RegisterPage(userType: "Student"),
                      ),
                    );
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
              ),

// 登录按钮（在注册按钮右边 + 间距）
              Positioned(
                left: (855 * scaleX + rightShift + buttonWidth + gap),
                top: 750 * scaleY,
                child: GestureDetector(
                  onTap: _login,
                  child: Container(
                    width: buttonWidth,
                    height: inputHeight,
                    decoration: BoxDecoration(
                      color: const Color(0xFF292929),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        AppLocalizations.of(context)!.signIn,
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
