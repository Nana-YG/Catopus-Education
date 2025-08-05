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
    final int progress = classData['progress'] ?? -1;

    return GestureDetector(
      onTap: onTap,
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          decoration: ShapeDecoration(
            color: isAddCard ? AppColors.background : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            shadows: const [
              BoxShadow(
                color: Color(0x3F000000),
                blurRadius: 8,
                offset: Offset(0, 4),
              )
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: isAddCard
              ? const Center(
                  child: Icon(Icons.add, size: 60, color: Colors.grey),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // 课程名
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    // 中间图标
                    const Icon(
                      Icons.science_outlined,
                      size: 60,
                      color: Colors.black,
                    ),

                    // 进度条
                    if (!isTeacher && progress >= 0)
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Progress",
                                  style: TextStyle(fontSize: 14)),
                              Text(
                                "$progress%",
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: progress / 100,
                              backgroundColor: Colors.grey[300],
                              color: Colors.green,
                              minHeight: 10,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
        ),
      ),
    );
  }
}
