import 'package:flutter/material.dart';
import 'package:flutter_project/widgets/student_grid.dart';

class RightPlainStudentArea extends StatelessWidget {
  final String title;
  final String classId;

  const RightPlainStudentArea({
    super.key,
    required this.title,
    required this.classId,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(child: StudentGrid(classId: classId)),
      ],
    );
  }
}
