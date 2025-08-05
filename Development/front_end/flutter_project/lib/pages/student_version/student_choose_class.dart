import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_project/generated/app_localizations.dart';
import 'package:flutter_project/pages/avatar_editor_page.dart';
import 'package:flutter_project/pages/game_test.dart';
import 'package:flutter_project/pages/student_version/student_course_detail_page.dart';
import 'package:flutter_project/pages/test_ha_pages.dart';
import 'package:flutter_project/pages/user_profile_page.dart';
import 'package:flutter_project/widgets/class_card.dart';
import 'package:flutter_project/utils/color.dart';
import 'package:flutter_project/utils/constant.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class StudentChooseClassPage extends StatefulWidget {
  final String studentName;

  const StudentChooseClassPage({
    super.key,
    required this.studentName,
  });

  @override
  State<StudentChooseClassPage> createState() => _StudentChooseClassPageState();
}

class _StudentChooseClassPageState extends State<StudentChooseClassPage> {
  List<dynamic> classes = [];
  bool isLoading = true;
  String username = '';
  String? avatarString;

  @override
void initState() {
  super.initState();
  _loadInitialData();
}

void _loadInitialData() async {
  _loadUsername();
  _loadClasses();
  final updatedAvatar = await _loadAvatarString();
  if (!mounted) return;
  setState(() {
    avatarString = updatedAvatar;
  });
}


 Future<String?> _loadAvatarString() async {
  final prefs = await SharedPreferences.getInstance();
  final username = prefs.getString('username');
  final token = prefs.getString('token');

  if (username != null && token != null) {
    final response = await http.get(
      Uri.parse('$baseApiUrl/login/profile-picture'),
      headers: {
        'Username': username,
        'Token': token,
      },
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final raw = json['profilePicture'];

      if (raw == null || raw.isEmpty) return null;

      final formatted = RegExp(r'^#').hasMatch(raw)
          ? raw
          : raw.replaceAllMapped(RegExp(r'.{6}'), (match) => '#${match.group(0)}');

      return formatted; // ✅ 现在返回字符串
    } else {
      print("❌ 获取头像失败: ${response.statusCode} ${response.body}");
    }
  }

  return null; // 请求失败时返回 null
}

  Future<void> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username') ?? 'Student';
    });
  }

  Future<void> _loadClasses() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username') ?? '';
    final token = prefs.getString('token') ?? '';

    final response = await http.get(
      Uri.parse('$baseApiUrl/progress/$username'),
      headers: {
        'Username': username,
        'Token': token,
      },
    );

    if (!mounted) return;
    print('🧾 Raw response: ${response.body}');

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      final Map<String, dynamic> classMap = result['classes'] ?? {};

      final List<Map<String, dynamic>> classList = [];

      for (final entry in classMap.entries) {
        final String classId = entry.key;
        final Map<String, dynamic> classInfo = entry.value;
        final String subject = classInfo['subject'];
        final Map<String, dynamic> tasks = classInfo['tasks'];

        // ✅ 存储 classId -> subject
        await prefs.setString('class_$classId', subject);

        int completedTasks = 0;
        final totalTasks = tasks.length;

        for (final taskEntry in tasks.entries) {
          final String taskId = taskEntry.key;
          final int status = taskEntry.value;

          // ✅ 存储每个 task 状态
          await prefs.setInt('task_${classId}_$taskId', status);

          if (status == 1) completedTasks++;
        }

        final int progress =
            totalTasks > 0 ? ((completedTasks / totalTasks) * 100).round() : 0;

        classList.add({
          'classId': classId,
          'name': subject,
          'progress': progress,
          'taskCount': totalTasks
        });
      }

      setState(() {
        classes = classList;
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load classes')),
      );
    }
  }

  Future<void> _joinClass(
      BuildContext context, String classId, String joinKey) async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username') ?? '';
    final token = prefs.getString('token') ?? '';

    final url = Uri.parse('$baseApiUrl/course/joinClass');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Username': username,
          'Token': token,
        },
        body: jsonEncode({
          'classId': classId,
          'joinKey': joinKey,
        }),
      );

      final responseBody = jsonDecode(response.body);

      if (!mounted) return;

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Joined class: ${responseBody['className']}')),
        );
        await _loadClasses();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${responseBody['error']}')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Request failed: $e')),
      );
    }
  }

  void _showJoinClassDialog() {
    final classIdController = TextEditingController();
    final joinKeyController = TextEditingController();
    final outerContext = context;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.joinClassTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: classIdController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.classId,
                ),
              ),
              TextField(
                controller: joinKeyController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.joinKey,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                final classId = classIdController.text.trim();
                final joinKey = joinKeyController.text.trim();

                if (classId.isEmpty || joinKey.isEmpty) {
                  ScaffoldMessenger.of(outerContext).showSnackBar(
                    SnackBar(
                      content: Text(
                          AppLocalizations.of(context)!.pleaseFillAllFields),
                    ),
                  );
                  return;
                }

                Navigator.pop(dialogContext);
                Future.microtask(() {
                  _joinClass(outerContext, classId, joinKey);
                });
              },
              child: Text(AppLocalizations.of(context)!.joinButton),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = (screenWidth / 200).floor();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // 顶部区域
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              color: AppColors.background,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              '${AppLocalizations.of(context)!.helloText}, $username!',
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 32,
                                fontFamily: 'Manrope',
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.notifications_none, size: 28),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      GestureDetector(
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const UserProfilePage()),
                          );

                          if (result == true) {
                            final updatedAvatar =
                                await _loadAvatarString(); // 加载新的头像
                            print(
                                '🖼️ 刷新后头像 avatarString: $updatedAvatar'); // ✅ 新增打印
                            setState(() {
                              avatarString = updatedAvatar; // ✅ 更新状态
                            });
                          }
                        },
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: const ShapeDecoration(
                            color: Colors.white,
                            shape: CircleBorder(),
                            shadows: [
                              BoxShadow(
                                color: Color(0x33000000),
                                blurRadius: 15,
                                offset: Offset(0, 0),
                              )
                            ],
                          ),
                          child: ClipOval(
                            child: avatarString != null
                                ? CustomPaint(
                                    key: ValueKey(avatarString),
                                    painter: AvatarPainter(avatarString!),
                                    size: const Size(48, 48),
                                  )
                                : const Icon(Icons.person, size: 28),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppLocalizations.of(context)!.profile,
                        style: const TextStyle(
                          fontSize: 12,
                          fontFamily: 'Manrope',
                          color: Colors.black,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),

            // 卡片区域
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: (screenWidth / 250).floor(), // 每行显示卡片数
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1, // 强制正方形
                      ),
                      itemCount: classes.isEmpty ? 1 : classes.length + 1,
                      itemBuilder: (context, index) {
                        if (classes.isEmpty || index == classes.length) {
                          return ClassCard(
                            classData: {'isAddCard': true},
                            onTap: _showJoinClassDialog,
                          );
                        }
                        final classData = classes[index];

                        return ClassCard(
                          classData: classData,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CourseDetailPage(
                                  className: classData['name'],
                                  classId: classData['classId'],
                                  taskCount: classData['taskCount'], // ✅ 传进去
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
