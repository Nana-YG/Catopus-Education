import 'package:flutter/material.dart';
import 'package:flutter_project/utils/color.dart';

class ClassCard extends StatelessWidget {
  final Map<String, dynamic> classData;
  final VoidCallback onTap;
  final bool isTeacher;

  const ClassCard({
    super.key,
    required this.classData,
    required this.onTap,
    this.isTeacher = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool isAddCard = classData['isAddCard'] == true;
    final String name = classData['name'] ?? '';
    final String classId = classData['classId'] ?? '';
    final String joinKey = classData['joinKey'] ?? '';

    return GestureDetector(
      onTap: onTap,
      child: AspectRatio(
        aspectRatio: 1, // 强制正方形
        child: Container(
          decoration: isAddCard
              ? ShapeDecoration(
                  color: isAddCard
                      ? AppColors.background
                      : Colors.white, // ✅ 设置为白色
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(23.38), // ✅ 同课程卡
                  ),
                  shadows: const [
                    // ✅ 添加阴影
                    BoxShadow(
                      color: Color(0x3F000000),
                      blurRadius: 15,
                      offset: Offset(0, 0),
                    )
                  ],
                )
              : ShapeDecoration(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(23.38),
                  ),
                  shadows: const [
                    BoxShadow(
                      color: Color(0x3F000000),
                      blurRadius: 15,
                      offset: Offset(0, 0),
                    )
                  ],
                ),
          padding: const EdgeInsets.all(24),
          child: isAddCard
              ? const Center(
                  child: Icon(Icons.add, size: 60, color: Colors.grey),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (isTeacher) ...[
                      const SizedBox(height: 16),
                      Text(
                        'Class ID: $classId',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Join Key: $joinKey',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ],
                ),
        ),
      ),
    );
  }
}
