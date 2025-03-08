import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_project/generated/app_localizations.dart';
import 'package:flutter_project/pages/fill_info_page.dart';
import 'package:flutter_project/pages/login.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_project/utils/constant.dart';

class RegisterPage extends StatefulWidget {
  final String userType; // 区分教师和学生

  const RegisterPage({super.key, required this.userType});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _register() async {
    String username = _usernameController.text;
    String password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.pleaseFillAllFields)),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    var url = Uri.parse("$baseApiUrl/login/register");
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.registrationSuccessful)),
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FillUserInfoPage(),
        ),
      );
      // 注册成功后跳转到fill info
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(responseBody["error"] ?? AppLocalizations.of(context)!.registrationFailed)),
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

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          width: screenWidth,
          height: screenHeight,
          decoration: const BoxDecoration(color: Colors.white),
          child: Stack(
            children: [
              // **页面标题**
              Positioned(
                left: 666 * scaleX,
                top: 234 * scaleY,
                child: Text(
                  '${AppLocalizations.of(context)!.registerAs} ${widget.userType}',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 48 * scaleX,
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              // **用户名**
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
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 20),
                      hintText: AppLocalizations.of(context)!.enterYourName,
                      hintStyle: const TextStyle(color: Colors.black45),
                    ),
                  ),
                ),
              ),

              // **密码**
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
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 20),
                      hintText: AppLocalizations.of(context)!.enterYourPassword,
                      hintStyle: const TextStyle(color: Colors.black45),
                    ),
                  ),
                ),
              ),

              // **返回按钮**
              Positioned(
                left: 753 * scaleX,
                top: 707 * scaleY,
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
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
                        AppLocalizations.of(context)!.back,
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

              // **注册按钮**
              Positioned(
                left: 1131 * scaleX,
                top: 707 * scaleY,
                child: GestureDetector(
                  onTap: _register,
                  child: Container(
                    width: 276 * scaleX,
                    height: 69 * scaleY,
                    decoration: BoxDecoration(
                      color: const Color(0xFF292929),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              AppLocalizations.of(context)!.next,
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

              // **已有账号？返回登录**
              Positioned(
                left: 880 * scaleX,
                top: 810 * scaleY,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                    );
                  },
                  child: Text(
                    AppLocalizations.of(context)!.alreadyHaveAccount,
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
