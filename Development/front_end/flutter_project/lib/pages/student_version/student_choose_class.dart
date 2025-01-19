import 'package:flutter/material.dart';
import 'package:flutter_project/utils/class_card.dart';

class StudentChooseClassPage extends StatelessWidget {
  final String studentName;
  final List<dynamic> classes;

  const StudentChooseClassPage({
    super.key,
    required this.studentName,
    required this.classes, // 接收学生课程数据
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
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Selected: ${classes[index]['name']}')),
                    );
                  },
                );
              },
            ),
    );
  }
}
