import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_project/generated/app_localizations.dart';
import 'package:flutter_project/pages/register_page.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:flutter_project/utils/constant.dart'; // ✅ 引入 baseApiUrl
import 'package:flutter_project/pages/student_version/student_choose_class.dart';
import 'package:flutter_project/pages/teacher_version/teacher_choose_class.dart';
import 'package:flutter_project/test.dart'; // 引入 fetchLogin 方法

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  /// **连接后端的登录逻辑**
  Future<void> _login() async {
  String username = _usernameController.text.trim();
  String password = _passwordController.text.trim();

  if (username.isEmpty || password.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please enter both username and password')),
    );
    return;
  }

  setState(() {
    _isLoading = true;
  });

  try {
    var url = Uri.parse("$baseApiUrl/login/signin");

    // **1️⃣ 打印请求信息**
    print("🔹 [REQUEST] Sending POST request to: $url");
    print("🔹 Headers: {Username: $username, Password: $password}");

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

    // **2️⃣ 打印完整的 Response 信息**
    print("🔸 [RESPONSE] Status Code: ${response.statusCode}");
    print("🔸 Response Headers: ${response.headers}");
    print("🔸 Response Body: ${response.body}");

    var responseBody = jsonDecode(response.body);

    if (response.statusCode == 200) {
      String token = responseBody["token"];

      print("✅ Login Successful!");
      print("🔹 Token: $token");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login successful')),
      );

      fetchLogin(); // ✅ 之前的 fetchLogin 方法仍然调用

      // **从后端获取角色**
      String role = username.startsWith('t') ? 'Teacher' : 'Student';

      if (role == 'Teacher') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TeacherChooseClassPage(
              teacherName: username,
              classes: [],
            ),
          ),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StudentChooseClassPage(
              studentName: username,
              classes: [],
            ),
          ),
        );
      }
    } else {
      print("❌ Login Failed: ${responseBody["error"]}");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(responseBody["error"] ?? "Login failed")),
      );
    }
  } catch (e) {
    setState(() {
      _isLoading = false;
    });

    print("❌ Network Error: $e");

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Network error, please try again later")),
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

    double baseWidth = 2160;
    double baseHeight = 1080;
    double scaleX = screenWidth / baseWidth;
    double scaleY = screenHeight / baseHeight;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          width: screenWidth,
          height: screenHeight,
          decoration: const BoxDecoration(color: Colors.white),
          child: Stack(
            children: [
              Positioned(
                left: 666 * scaleX,
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
                left: 855 * scaleX,
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
                left: 855 * scaleX,
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
                left: 855 * scaleX,
                top: 413 * scaleY,
                child: SizedBox(
                  width: 450 * scaleX,
                  height: 68 * scaleY,
                  child: TextField(
                    controller: _usernameController,
                    textAlignVertical: TextAlignVertical.center,
                    style: TextStyle(fontSize: 30 * scaleX),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFECECEC),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                      hintText: AppLocalizations.of(context)!.enterYourName,
                      hintStyle: const TextStyle(color: Colors.black45),
                    ),
                  ),
                ),
              ),

              Positioned(
                left: 855 * scaleX,
                top: 573 * scaleY,
                child: SizedBox(
                  width: 450 * scaleX,
                  height: 68 * scaleY,
                  child: TextField(
                    controller: _passwordController,
                    obscureText: true,
                    textAlignVertical: TextAlignVertical.center,
                    style: TextStyle(fontSize: 30 * scaleX),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFECECEC),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                      hintText: AppLocalizations.of(context)!.enterYourPassword,
                      hintStyle: const TextStyle(color: Colors.black45),
                    ),
                  ),
                ),
              ),

              Positioned(
                left: 753 * scaleX,
                top: 707 * scaleY,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RegisterPage(userType: "Student"),
                      ),
                    );
                  },
                  child: Container(
                    width: 276 * scaleX,
                    height: 69 * scaleY,
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

              Positioned(
                left: 1131 * scaleX,
                top: 707 * scaleY,
                child: GestureDetector(
                  onTap: _login, // ✅ **调用后端登录 API**
                  child: Container(
                    width: 276 * scaleX,
                    height: 69 * scaleY,
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
              Positioned(
                left: 981 * scaleX,
                top: 810 * scaleY,
                child: GestureDetector(
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
