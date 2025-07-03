import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_project/generated/app_localizations.dart';
import 'package:flutter_project/pages/user_profile_page.dart';
import 'package:flutter_project/utils/class_card.dart';
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

  @override
  void initState() {
    super.initState();
    _loadUsername();
    _loadTeacherClasses();
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

    final response = await http.get(
      Uri.parse('$baseApiUrl/course/createdClassList'),
      headers: {
        'Username': username,
        'Token': token,
      },
    );

    if (!mounted) return;

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      final courseList = result['courses'] as List;

      setState(() {
        classes = courseList
            .map((course) => {
                  'name': course['className'],
                  'classId': course['classId'],
                  'joinKey': course['joinKey'],
                })
            .toList();
        isLoading = false;
      });
    } else {
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
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const UserProfilePage()),
                          );
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
                          child: const Icon(Icons.person, size: 28),
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
                        if (index == classes.length) {
                          return ClassCard(
                            classData: {'isAddCard': true},
                            onTap: _showCreateClassDialog,
                            isTeacher: true,
                          );
                        }

                        final classData = classes[index];
                        return ClassCard(
                          classData: classData,
                          isTeacher: true,
                          onTap: () {
                            final name = classData['name'];
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Selected: $name')),
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
