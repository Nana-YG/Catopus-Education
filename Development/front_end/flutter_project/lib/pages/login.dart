import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_project/pages/choose_version.dart';
import 'package:flutter_project/pages/student_version/student_choose_class.dart';
import 'package:flutter_project/pages/teacher_version/teacher_choose_class.dart';
import 'package:flutter_project/test.dart'; // 引入 fetchLogin 方法所在的文件

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  List<dynamic> _users = [];
  bool _isLoading = false;

  Future<void> loadMockData() async {
    final String response =
        await rootBundle.loadString('lib/temp_data/mock_login_data.json');
    final data = json.decode(response);
    setState(() {
      _users = data['users'];
    });
  }

  void _login() async {
    String username = _usernameController.text;
    String password = _passwordController.text;

    final user = _users.firstWhere(
      (user) =>
          user['username'] == username && user['password'] == password,
      orElse: () => null,
    );

    if (user != null) {
      setState(() {
        _isLoading = true;
      });

      fetchLogin();

      if (user['role'] == 'teacher') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TeacherChooseClassPage(
              teacherName: user['username'],
              classes: user['classes'],
            ),
          ),
        );
      } else if (user['role'] == 'student') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StudentChooseClassPage(
              studentName: user['username'],
              classes: user['classes'],
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid role')),
        );
      }

      setState(() {
        _isLoading = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid username or password')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    loadMockData();
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
              Positioned(
                left: 666 * scaleX,
                top: 234 * scaleY,
                child: Text(
                  'Login',
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
                  'Name',
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
                  'Password',
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
      textAlignVertical: TextAlignVertical.center, // **让文字垂直居中**
      style: TextStyle(fontSize: 30 * scaleX), // **字体大小**
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFECECEC), // **背景颜色**
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8), // **一点点圆角**
          borderSide: BorderSide.none, // **去掉边框**
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20), // **左右间距**
        hintText: 'Enter your name', // **提示文本**
        hintStyle: const TextStyle(color: Colors.black45), // **提示文本颜色**
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
      obscureText: true, // **隐藏密码**
      textAlignVertical: TextAlignVertical.center, // **让文本垂直居中**
      style: TextStyle(fontSize: 30 * scaleX), // **设置字体大小**
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFECECEC), // **背景色**
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8), // **稍微增加一点圆角**
          borderSide: BorderSide.none, // **去掉边框**
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20), // **控制左右间距**
        hintText: 'Enter your password', // **提示文本**
        hintStyle: const TextStyle(color: Colors.black45), // **提示文本颜色**
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
                        builder: (context) => const ChooseVersionPage(),
                      ),
                    );
                  },
                  child: Container(
                    width: 276 * scaleX,
                    height: 69 * scaleY,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8), // **增加一点圆角**
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
                        'Sign up',
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
                  onTap: _login,
                  child: Container(
                    width: 276 * scaleX,
                    height: 69 * scaleY,
                    decoration: BoxDecoration(
                      color: const Color(0xFF292929),
                      borderRadius: BorderRadius.circular(8), // **增加一点圆角**
                    ),
                    child: Center(
                      child: Text(
                        'Sign in',
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
                    'Forgot password?',
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
