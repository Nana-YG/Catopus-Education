import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_project/generated/app_localizations.dart';
import 'package:flutter_project/pages/game_test.dart';
import 'package:flutter_project/utils/constant.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_project/utils/class_card.dart';
import 'package:flutter_project/pages/test_ha_pages.dart';

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

  @override
  void initState() {
    super.initState();
    _loadClasses();
  }

  Future<void> _loadClasses() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username') ?? '';
    final token = prefs.getString('token') ?? '';

    final response = await http.get(
      Uri.parse('$baseApiUrl/course/joinedClassList'),
      headers: {
        'Username': username,
        'Token': token,
      },
    );

    if (!mounted) return;

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      final classNames = result['classNames'] as List;
      print("📦 收到课程列表: $classNames");

      setState(() {
        classes = classNames.map((name) => {'name': name}).toList();
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
          'classId': classId, // ✅ 使用 classId
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
      content: Text(AppLocalizations.of(context)!.pleaseFillAllFields),
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
      appBar: AppBar(
   title: Text('${AppLocalizations.of(context)!.studentPrefix}: ${widget.studentName}'),

        actions: [
          IconButton(
            icon: const Icon(Icons.videogame_asset),
            tooltip: 'Game Test',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const GameWebViewPage(), // ✅ 替换成你的游戏页面
                ),
              );
            },
          ),
        ],
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
              itemCount: classes.isEmpty ? 1 : classes.length + 1,
              itemBuilder: (context, index) {
                if (classes.isEmpty || index == classes.length) {
                  return ClassCard(
                    classData: {'isAddCard': true},
                    onTap: _showJoinClassDialog,
                  );
                }

                final classData = classes[index];
                final className = classData['name'];

                return ClassCard(
                  classData: classData,
                  onTap: () {
                    if (className == "Chemistry 303") {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TestHaPage(),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Selected: $className')),
                      );
                    }
                  },
                );
              },
            ),
    );
  }
}
