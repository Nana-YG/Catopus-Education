import 'package:flutter/material.dart';
import 'package:flutter_project/pages/avatar_editor_page.dart';
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
    final List<dynamic> studentAvatars = classData['studentAvatars'] ?? [];

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

                    // 中间图标或头像
                    isTeacher
                        ? SizedBox(
                            height: 50,
                            // 宽度根据头像数量预估一下，最多显示 4 个 + 一个 "+N"
                            width: studentAvatars.length > 4
    ? 4 * 30.0 + 50 +10
    : studentAvatars.length * 30.0 + 20,

                            child: Stack(
                              children: [
                                for (int i = 0;
                                    i <
                                        (studentAvatars.length > 4
                                            ? 4
                                            : studentAvatars.length);
                                    i++)
                                  Positioned(
                                    left: i *
                                        30.0, // 每个头像偏移 30，头像宽度 50，所以有 20px 重叠
                                    child: Container(
                                      width: 50,
                                      height: 50,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Color(0x33000000),
                                            blurRadius: 6,
                                            offset: Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: ClipOval(
                                        child: studentAvatars[i] != null
                                            ? CustomPaint(
                                                painter: AvatarPainter(
                                                    studentAvatars[i]),
                                                size: const Size(50, 50),
                                              )
                                            : const Icon(Icons.person,
                                                size: 18, color: Colors.grey),
                                      ),
                                    ),
                                  ),

                                // 多余人数 "+N"
                                if (studentAvatars.length > 4)
                                  Positioned(
    left: 4 * 30.0 - 15,
    child: Container(
      width: 50,
      height: 50,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey,
        boxShadow: [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          '+${studentAvatars.length - 4}',
          style: const TextStyle(fontSize: 12, color: Colors.white),
        ),
      ),
    ),
  ),

                              ],
                            ),
                          )
                        : const Icon(
                            Icons.science_outlined,
                            size: 60,
                            color: Colors.black,
                          ),

                    // 教师端信息显示
                    if (isTeacher)
                      Column(
                        children: [
                          const SizedBox(height: 8),
                          Text(
                            'Class ID: $classId',
                            style: const TextStyle(fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Join Key: $joinKey',
                            style: const TextStyle(fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),

                    // 学生端进度条显示
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

  // ✅ 用于将十六进制颜色转为 int
  int _hexToColor(String hex) {
    try {
      hex = hex.replaceFirst('#', '');
      if (hex.length != 6) return 0xFF888888; // fallback 灰色
      return int.parse('FF$hex', radix: 16);
    } catch (_) {
      return 0xFF888888;
    }
  }
}
