import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_project/generated/app_localizations.dart';
import 'package:flutter_project/pages/avatar_editor_page.dart';
import 'package:flutter_project/pages/login.dart';
import 'package:flutter_project/utils/color.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_project/utils/constant.dart';

import 'avatar_editor_page.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  String? avatarString;
  String? username;

  @override
  void initState() {
    super.initState();
    _loadAvatarFromServer();
  }

  Future<void> _loadAvatarFromServer() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUsername = prefs.getString('username');
    final token = prefs.getString('token');
    setState(() {
      username = savedUsername; // ✅ 保存到 state
    });

    if (username != null && token != null) {
      final response = await http.get(
        Uri.parse('$baseApiUrl/login/profile-picture'),
        headers: {
          'Username': savedUsername!,
          'Token': token,
        },
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        setState(() {
          avatarString = json['profilePicture'];
        });
      } else {
        print("❌ 获取头像失败: ${response.statusCode} ${response.body}");
      }
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  void _goToAvatarEditor() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            AvatarEditorPage(initialAvatarString: avatarString),
      ),
    );

    if (result != null && result is String) {
      print('🎨 返回的新头像字符串: $result');
      setState(() {
        avatarString = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final avatarWidget = avatarString != null
        ? CustomPaint(
            key: ValueKey(avatarString),
            painter: AvatarPainter(avatarString!),
            size: const Size(100, 100),
          )
        : const Icon(Icons.person, size: 50, color: Colors.white);

    return Scaffold(
      backgroundColor:  AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context, true); // ✅ 通知上层页面可以刷新头像
          },
        ),
        title: Text(AppLocalizations.of(context)!.profile),
        centerTitle: true,
        backgroundColor:  AppColors.background,
        elevation: 0,
      ),
      // 2) body：在头像上方插入 username
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (username != null && username!.isNotEmpty) ...[
              Text(
                username!,
                style: const TextStyle(
                  fontSize: 26, // ✅ 字号更大
                  fontWeight: FontWeight.bold,
                  color: Colors.black87, // ✅ 更清晰
                  letterSpacing: 1.2, // ✅ 增加字间距（可选）
                ),
              ),
              const SizedBox(height: 20),
            ],
            GestureDetector(
              onTap: _goToAvatarEditor,
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey[400],
                child: ClipOval(
                  child: avatarString != null
                      ? SizedBox(
                          width: 100,
                          height: 100,
                          child: CustomPaint(
                            key: ValueKey(avatarString),
                            painter: AvatarPainter(avatarString!),
                            size: const Size(100, 100),
                          ),
                        )
                      : const SizedBox(
                          width: 100,
                          height: 100,
                          child: Center(
                            child: Icon(Icons.person,
                                size: 50, color: Colors.white),
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout),
              label: Text(AppLocalizations.of(context)!.logout),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
