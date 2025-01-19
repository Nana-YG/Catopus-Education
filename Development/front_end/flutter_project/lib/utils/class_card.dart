import 'package:flutter/material.dart';

class ClassCard extends StatelessWidget {
  final Map<String, dynamic> classData;
  final VoidCallback onTap;

  const ClassCard({
    super.key,
    required this.classData,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = classData.containsKey('image') &&
        (classData['image'] ?? '').isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment:
              hasImage ? MainAxisAlignment.start : MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (hasImage)
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: Image.network(
                    classData['image'],
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                classData['name'],
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
