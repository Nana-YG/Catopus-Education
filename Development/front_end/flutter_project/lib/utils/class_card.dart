import 'package:flutter/material.dart';

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
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: isAddCard ? Colors.grey[200] : Colors.white,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: isAddCard
                ? const Icon(Icons.add, size: 48, color: Colors.grey)
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(' $name',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      if (isTeacher) ...[
                        const SizedBox(height: 8),
                        Text('Class ID: $classId',
                            style: const TextStyle(fontSize: 14)),
                        const SizedBox(height: 4),
                        Text('Join Key: $joinKey',
                            style: const TextStyle(fontSize: 14)),
                      ],
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
