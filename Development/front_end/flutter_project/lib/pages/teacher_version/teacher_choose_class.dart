import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_project/generated/app_localizations.dart';
import 'package:flutter_project/pages/avatar_editor_page.dart';
import 'package:flutter_project/pages/teacher_version/teacher_course_detail_page.dart';
import 'package:flutter_project/pages/user_profile_page.dart';
import 'package:flutter_project/widgets/class_card.dart';
import 'package:flutter_project/utils/color.dart';
import 'package:flutter_project/utils/constant.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TeacherChooseClassPage extends StatefulWidget {
  final String teacherName;

  const TeacherChooseClassPage({
    super.key,
    required this.teacherName,
  });

  @override
  State<TeacherChooseClassPage> createState() => _TeacherChooseClassPageState();
}

class _TeacherChooseClassPageState extends State<TeacherChooseClassPage> {
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
    _loadTeacherClasses();
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
            : raw.replaceAllMapped(
                RegExp(r'.{6}'), (match) => '#${match.group(0)}');

        return formatted;
      } else {
        print("❌ 获取头像失败: ${response.statusCode} ${response.body}");
      }
    }

    return null;
  }

  Future<void> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username') ?? 'Teacher';
    });
  }

  Future<void> _loadTeacherClasses() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username') ?? '';
    final token = prefs.getString('token') ?? '';

    print("📡 发起课程列表请求...");
    print("➡️ 请求地址: $baseApiUrl/course/createdClassList");
    print("➡️ 请求Header: Username=$username, Token=$token");

    final response = await http.get(
      Uri.parse('$baseApiUrl/course/createdClassList'),
      headers: {
        'Username': username,
        'Token': token,
      },
    );

    if (!mounted) return;

    print("✅ 响应状态: ${response.statusCode}");
    print("🧾 响应内容: ${response.body}");

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      final courseList = result['courses'] as List;

      print("📘 课程总数: ${courseList.length}");

      List<Map<String, dynamic>> updatedClasses = [];

      for (var course in courseList) {
        final classId = course['classId'];
        final className = course['className'];
        final joinKey = course['joinKey'];

        print("🔹 课程: $className ($classId), Join Key: $joinKey");

        // 获取学生列表
        final studentListRes = await http.get(
          Uri.parse('$baseApiUrl/course/inClassStudents'),
          headers: {
            'Username': username,
            'Token': token,
            'classId': classId,
          },
        );
        print("📤 发起学生列表请求: $baseApiUrl/course/inClassStudents");
        print("➡️ Header 内容:");
        print("   Username: $username");
        print("   Token: $token");
        print("   ClassId: $classId");

        print("👥 请求学生列表状态: ${studentListRes.statusCode}");
        print("👥 学生响应内容: ${studentListRes.body}");

        List<String?> studentAvatars = [];
        if (studentListRes.statusCode == 200) {
          final studentJson = jsonDecode(studentListRes.body);
          final List<dynamic> students = studentJson['studentList'] ?? [];

          print("👶 学生数: ${students.length}");


          for (int i = 0; i < students.length; i++) {
            final studentUsername = students[i];
            print("🎯 获取头像: $studentUsername");

            final avatarRes = await http.get(
              Uri.parse('$baseApiUrl/login/profile-picture'),
              headers: {
                'Username': studentUsername,
                'Token': token,
              },
            );

            print("🖼️ 头像状态: ${avatarRes.statusCode}");

            if (avatarRes.statusCode == 200) {
              final avatarJson = jsonDecode(avatarRes.body);
              final raw = avatarJson['profilePicture'];
              print("🧾 原始头像字符串: $raw");

              if (raw != null && raw.toString().isNotEmpty) {
                final formatted = RegExp(r'^#').hasMatch(raw)
                    ? raw
                    : raw.replaceAllMapped(
                        RegExp(r'.{6}'),
                        (match) => '#${match.group(0)}',
                      );
                print("🎨 格式化颜色: $formatted");
                studentAvatars.add(formatted);
              } else {
                print("⚠️ 没头像，添加 null");
                studentAvatars.add(null);
              }
            } else {
              print("⚠️ 获取头像失败，添加 null");
              studentAvatars.add(null);
            }
          }

          updatedClasses.add({
            'name': className,
            'classId': classId,
            'joinKey': joinKey,
            'studentAvatars': studentAvatars,
            'studentTotal': students.length,
          });

          print("✅ 完成课程卡片信息添加: $className");
        } else {
          print("❌ 获取学生列表失败 for classId=$classId");
        }
      }

      setState(() {
        classes = updatedClasses;
        isLoading = false;
      });

      print("🎉 所有课程加载完成 ✅");
    } else {
      print("❌ 课程列表请求失败");
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.networkError)),
      );
    }
  }

  void _showCreateClassDialog() {
    final nameController = TextEditingController();
    final joinKeyController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.createClass),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.className,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: joinKeyController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.joinKey,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();
                final key = joinKeyController.text.trim();

                if (name.isEmpty || key.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          AppLocalizations.of(context)!.pleaseFillAllFields),
                    ),
                  );
                  return;
                }

                Navigator.pop(dialogContext);
                _createCourse(name, key);
              },
              child: Text(AppLocalizations.of(context)!.submit),
            ),
          ],
        );
      },
    );
  }

  Future<void> _createCourse(String name, String joinKey) async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username') ?? '';
    final token = prefs.getString('token') ?? '';

    final url = Uri.parse('$baseApiUrl/course/createClass');
    final body = {
      'className': name,
      'coursePackage': 'BASIC',
      'joinKey': joinKey,
    };

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Username': username,
          'Token': token,
        },
        body: jsonEncode(body),
      );

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        await _loadTeacherClasses();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${responseBody['error']}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Request failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // 顶部自定义 AppBar
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
                        crossAxisCount: (screenWidth / 250).floor(),
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1,
                      ),
                      itemCount: classes.length + 1,
                      itemBuilder: (context, index) {
                        // ✅ 新增卡片：只负责创建班级
                        if (index == classes.length) {
                          return ClassCard(
                            classData: {'isAddCard': true},
                            onTap: _showCreateClassDialog,
                            isTeacher: true,
                          );
                        }

                        // ✅ 普通卡片：进入课程详情
                        final classData = classes[index];
                        return ClassCard(
                          classData: classData,
                          isTeacher: true,
                          onTap: () {
                            final classId = classData['classId'] as String;
                            final className = classData['name'] as String;

                            // 任务数：后端若暂时没有返回，用一个默认值（如 6）
                            final taskCount = (classData['taskCount'] ??
                                classData['tasks'] ??
                                6) as int;

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => TeacherCourseDetailPage(
                                  classId: classId,
                                  className: className,
                                  taskCount: taskCount,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
            )
          ],
        ),
      ),
    );
  }
}
