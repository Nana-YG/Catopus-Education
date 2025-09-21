import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_project/generated/app_localizations.dart';
import 'package:flutter_project/pages/avatar_editor_page.dart';
import 'package:flutter_project/pages/login.dart';
import 'package:flutter_project/utils/color.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_project/utils/constant.dart';
import 'package:flutter_project/utils/app_locale.dart';

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
      username = savedUsername;
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
        // ignore: avoid_print
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
      // ignore: avoid_print
      print('🎨 返回的新头像字符串: $result');
      setState(() {
        avatarString = result;
      });
    }
  }

  Future<void> _changeLang(String code) async {
    await AppLocale.I.set(code);
    if (!mounted) return;
    setState(() {}); // 刷新本页文案
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

    final currentCode = AppLocale.I.code; // 'zh' or 'en'

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context, true);
          },
        ),
        title: Text(AppLocalizations.of(context)!.profile),
        centerTitle: true,
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).padding.bottom + 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 头像
                GestureDetector(
                  onTap: _goToAvatarEditor,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[400],
                    child: ClipOval(child: avatarWidget),
                  ),
                ),
                const SizedBox(height: 16),

                // 用户名（头像下）
                if (username != null && username!.isNotEmpty)
                  Text(
                    username!,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),

                const SizedBox(height: 28),

                // 语言设置 一行（标题 + 分段切换）
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.languageSettings,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 16),
                      _LangSegmentedSwitch(
                        value: currentCode, // 'zh' 或 'en'
                        onChanged: (code) => _changeLang(code),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // 退出登录
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
        ),
      ),
    );
  }
}

/// 分段切换：中文 / English
/// - `value`: 'zh' 或 'en'
/// - 带平滑滑块动画、点击任意一侧切换
class _LangSegmentedSwitch extends StatelessWidget {
  final String value; // 'zh' | 'en'
  final ValueChanged<String> onChanged;

  const _LangSegmentedSwitch({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    const double height = 44;
    const double width = 220;
    const double radius = 9;
    const Duration anim = Duration(milliseconds: 180);

    final bool isZh = value == 'zh';

    return Semantics(
      label: 'Language segmented control',
      toggled: isZh,
      child: GestureDetector(
        onTapUp: (d) {
          // 点击左右半区切换
          final localX = d.localPosition.dx;
          final half = width / 2;
          if (localX < half && !isZh) {
            onChanged('zh');
          } else if (localX >= half && isZh) {
            onChanged('en');
          }
        },
        child: Container(
          width: width,
          height: height,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: Colors.black12),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 6,
                offset: Offset(0, 2),
              )
            ],
          ),
          child: Stack(
            children: [
              // 滑块
              AnimatedAlign(
                duration: anim,
                curve: Curves.easeOut,
                alignment: isZh ? Alignment.centerLeft : Alignment.centerRight,
                child: Container(
                  width: (width - 8) / 2, // 减去左右内边距 4+4
                  height: height - 8,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(radius),
                  ),
                ),
              ),

              // 文案
              Row(
                children: [
                  Expanded(
                    child: Center(
                      child: AnimatedDefaultTextStyle(
                        duration: anim,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isZh ? Colors.white : Colors.black87,
                        ),
                        child: const Text('中文'),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: AnimatedDefaultTextStyle(
                        duration: anim,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isZh ? Colors.black87 : Colors.white,
                        ),
                        child: const Text('English'),
                      ),
                    ),
                  ),
                ],
              ),

              // 分隔线（可选，若不想要可删除）
              // Center(child: Container(width: 1, color: Colors.black12)),
            ],
          ),
        ),
      ),
    );
  }
}
