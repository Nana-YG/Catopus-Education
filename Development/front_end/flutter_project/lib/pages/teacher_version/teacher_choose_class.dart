import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_project/generated/app_localizations.dart';
import 'package:flutter_project/utils/class_card.dart';
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

  String selectedPackage = 'BASIC'; // 默认值
  final List<String> packageOptions = ['BASIC', 'MATH101', 'CHEM102'];

  @override
  void initState() {
    super.initState();
    _loadTeacherClasses();
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
      print("🧾 Raw response: ${response.body}");
      final result = jsonDecode(response.body);
      final courseList = result['courses'] as List;
      print("📦 收到课程列表: $courseList");

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
    final outerContext = context;

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
                DropdownButtonFormField<String>(
                  value: selectedPackage,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.coursePackage,
                  ),
                  items: packageOptions.map((pkg) {
                    return DropdownMenuItem<String>(
                      value: pkg,
                      child: Text(pkg),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedPackage = value;
                      });
                    }
                  },
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
                  ScaffoldMessenger.of(outerContext).showSnackBar(
                    SnackBar(
                      content: Text(
                          AppLocalizations.of(context)!.pleaseFillAllFields),
                    ),
                  );
                  return;
                }

                Navigator.pop(dialogContext);
                _createCourse(name, selectedPackage, key);
              },
              child: Text(AppLocalizations.of(context)!.submit),
            ),
          ],
        );
      },
    );
  }

  Future<void> _createCourse(String name, String pkg, String joinKey) async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username') ?? '';
    final token = prefs.getString('token') ?? '';

    final url = Uri.parse('$baseApiUrl/course/createClass');
    final body = {
      'className': name,
      'coursePackage': pkg,
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
        final classId = responseBody['classId'] ?? 'N/A';
        final className = responseBody['className'] ?? name;
        final joinKeyReturned = responseBody['joinKey'] ?? joinKey;

        if (!mounted) return;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return AlertDialog(
              title: Text(AppLocalizations.of(context)!.success),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      '${AppLocalizations.of(context)!.className}: $className'),
                  const SizedBox(height: 8),
                  Text('Class ID: $classId'),
                  const SizedBox(height: 8),
                  Text(
                      '${AppLocalizations.of(context)!.joinKey}: $joinKeyReturned'),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    await _loadTeacherClasses();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
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
    final crossAxisCount = (screenWidth / 200).floor();

    return Scaffold(
      appBar: AppBar(
        title: Text(
            '${AppLocalizations.of(context)!.teacherPrefix}: ${widget.teacherName}'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 3 / 4,
              ),
              itemCount: classes.length + 1,
              itemBuilder: (context, index) {
                if (index == classes.length) {
                  return ClassCard(
                    classData: {'isAddCard': true},
                    onTap: _showCreateClassDialog,
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
    );
  }
}
