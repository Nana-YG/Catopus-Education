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

  // 加载本地模拟数据
  Future<void> loadMockData() async {
    final String response =
        await rootBundle.loadString('lib/temp_data/mock_login_data.json');
    final data = json.decode(response);
    setState(() {
      _users = data['users'];
    });
  }

  // 验证登录
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
        _isLoading = true; // 设置加载状态
      });

      // 调用 fetchLogin 方法
      fetchLogin();

      // 根据角色跳转页面
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
        _isLoading = false; // 恢复加载状态
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
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Login'),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator()) // 显示加载指示器
            : Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.grey,
                        spreadRadius: 2,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Username',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _usernameController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Enter your username',
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Password',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Enter your password',
                        ),
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: ElevatedButton(
                          onPressed: _login,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 40, vertical: 12),
                          ),
                          child: const Text(
                            'Login',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ChooseVersionPage(),
                              ),
                            );
                          },
                          child: const Text(
                            'Don\'t have an account? Register here',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
        backgroundColor: Colors.grey[200],
      ),
    );
  }
}
