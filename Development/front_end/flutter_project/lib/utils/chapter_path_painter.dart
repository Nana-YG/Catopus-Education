import 'package:flutter/material.dart';
import 'dart:ui';

class ChapterPathPainter extends CustomPainter {
  final List<Offset> points;
  final double scale;

  ChapterPathPainter({required this.points, required this.scale});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..strokeWidth = 4 * scale
      ..style = PaintingStyle.stroke;

    final path = Path();
    final spline = CatmullRomSpline(points, startHandle: points.first, endHandle: points.last);

    const int segments = 300;
    final interpolatedPoints = List.generate(
      segments + 1,
      (i) => spline.transform(i / segments),
    );

    path.moveTo(interpolatedPoints[0].dx, interpolatedPoints[0].dy);
    for (int i = 1; i < interpolatedPoints.length; i++) {
      path.lineTo(interpolatedPoints[i].dx, interpolatedPoints[i].dy);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
