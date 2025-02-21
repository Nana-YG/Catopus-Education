import 'package:flutter/material.dart';
import 'package:flutter_project/utils/class_card.dart';
import 'package:flutter_project/pages/test_ha_pages.dart'; // 确保路径正确

class StudentChooseClassPage extends StatelessWidget {
  final String studentName;
  final List<dynamic> classes;

  const StudentChooseClassPage({
    super.key,
    required this.studentName,
    required this.classes,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = (screenWidth / 200).floor();

    return Scaffold(
      appBar: AppBar(
        title: Text('Student: $studentName'),
      ),
      body: classes.isEmpty
          ? const Center(child: Text('No classes available'))
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 3 / 4,
              ),
              itemCount: classes.length,
              itemBuilder: (context, index) {
                return ClassCard(
                  classData: classes[index],
                  onTap: () {
                    String className = classes[index]['name'];

                    if (className == "Chemistry 303") {
                      // 跳转到 test_ha_pages.dart
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TestHaPage(),
                        ),
                      );
                    } else {
                      // 其他课程弹出提示
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
