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
    final spline = CatmullRomSpline(points);

    const int segments = 600;
    final interpolatedPoints = List.generate(
      segments + 1,
      (i) => spline.transform(i / segments),
    );

    path.moveTo(interpolatedPoints[0].dx, interpolatedPoints[0].dy);

    for (int i = 0; i < interpolatedPoints.length - 1; i++) {
      final p0 = interpolatedPoints[i];
      final p1 = interpolatedPoints[i + 1];

      final control1 = Offset(
        (2 * p0.dx + p1.dx) / 3,
        (2 * p0.dy + p1.dy) / 3,
      );
      final control2 = Offset(
        (p0.dx + 2 * p1.dx) / 3,
        (p0.dy + 2 * p1.dy) / 3,
      );

      path.cubicTo(
        control1.dx, control1.dy,
        control2.dx, control2.dy,
        p1.dx, p1.dy,
      );
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
class StraightLinePathPainter extends CustomPainter {
  final List<Offset> points;
  final double scale;

  StraightLinePathPainter({required this.points, required this.scale});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    final paint = Paint()
      ..color = Colors.brown
      ..strokeWidth = 8 * scale
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < points.length - 1; i++) {
      canvas.drawLine(points[i], points[i + 1], paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
class SmoothLinePathPainter extends CustomPainter {
  final List<Offset> points;
  final double scale;

  SmoothLinePathPainter({required this.points, required this.scale});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    final paint = Paint()
      ..color = Colors.brown
      ..strokeWidth = 8 * scale
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(points[0].dx, points[0].dy);

    if (points.length == 2) {
      // 二次贝塞尔：中点控制点
      final control = Offset(
        (points[0].dx + points[1].dx) / 2,
        (points[0].dy + points[1].dy) / 2 - 100 * scale, // 往上抬点弯曲
      );
      path.quadraticBezierTo(control.dx, control.dy, points[1].dx, points[1].dy);
    } else if (points.length == 3) {
      // 三次贝塞尔：两个控制点靠近中间点
      final control1 = Offset(
        (points[0].dx + points[1].dx) / 2,
        (points[0].dy + points[1].dy) / 2 - 80 * scale,
      );
      final control2 = Offset(
        (points[1].dx + points[2].dx) / 2,
        (points[1].dy + points[2].dy) / 2 - 80 * scale,
      );
      path.cubicTo(
        control1.dx,
        control1.dy,
        control2.dx,
        control2.dy,
        points[2].dx,
        points[2].dy,
      );
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

