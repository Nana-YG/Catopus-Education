import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_project/models/student_brief.dart';
import 'package:flutter_project/pages/avatar_editor_page.dart' show AvatarPainter;

/// 单个学生格子
class StudentTile extends StatelessWidget {
  final StudentBrief student;
  final VoidCallback onRemove;
  final double avatarSize;
  final double? nameWidth;

  const StudentTile({
    super.key,
    required this.student,
    required this.onRemove,
    required this.avatarSize,
    this.nameWidth,
  });

  @override
  Widget build(BuildContext context) {
    final name = student.userIdOrUsername;
    final hasAvatar = student.avatarHex != null && student.avatarHex!.isNotEmpty;
    final iconSize = avatarSize * 0.48;

    return Column(
      mainAxisSize: MainAxisSize.min, // 以内容高度为准，避免被强行拉伸
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: avatarSize,
              height: avatarSize,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black.withOpacity(0.8), width: 1),
              ),
              child: ClipOval(
                child: hasAvatar
                    ? RepaintBoundary(
                        key: ValueKey(student.avatarHex),
                        child: CustomPaint(
                          painter: AvatarPainter(student.avatarHex!),
                          size: Size(avatarSize, avatarSize),
                        ),
                      )
                    : Icon(Icons.person, size: iconSize, color: Colors.black54),
              ),
            ),
            Positioned(
              right: -2,
              top: -2,
              child: GestureDetector(
                onTap: onRemove,
                child: Container(
                  width: avatarSize * 0.26,
                  height: avatarSize * 0.26,
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.remove, size: avatarSize * 0.16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6), // 稍微更紧凑，给格子留余量
        SizedBox(
          width: nameWidth ?? (avatarSize * 1.3),
          child: Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: (avatarSize * 0.22).clamp(13, 16),
              fontWeight: FontWeight.w600,
              height: 1.15,
            ),
          ),
        ),
      ],
    );
  }
}

/// “添加学生” 虚线圆按钮
class AddTile extends StatelessWidget {
  final VoidCallback onTap;
  final double avatarSize;

  const AddTile({
    super.key,
    required this.onTap,
    required this.avatarSize,
  });

  @override
  Widget build(BuildContext context) {
    final plusSize = avatarSize * 0.33;

    return Column(
      mainAxisSize: MainAxisSize.min, // 👈 以内容最小高度为准，避免溢出
      children: [
        GestureDetector(
          onTap: onTap,
          child: CustomPaint(
            size: Size(avatarSize, avatarSize),
            painter: _DashedCirclePainter(
              color: Colors.black38,
              strokeWidth: 1.5,
              dash: 6,
              gap: 4,
            ),
            child: SizedBox(
              width: avatarSize,
              height: avatarSize,
              child: Center(
                child: Icon(Icons.add, size: plusSize, color: Colors.black45),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),   // 比原来 8 更紧凑
        const SizedBox.shrink(),     // ✅ 不再放 Text，0 高度，不会挤爆格子
      ],
    );
  }
}

/// 虚线圆画笔
class _DashedCirclePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dash;
  final double gap;

  _DashedCirclePainter({
    required this.color,
    required this.strokeWidth,
    required this.dash,
    required this.gap,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = color;

    final Rect rect = Offset.zero & size;
    final Path path = Path()..addOval(rect.deflate(strokeWidth));
    final Path dashed = _dashPath(path, dash, gap);
    canvas.drawPath(dashed, paint);
  }

  Path _dashPath(Path source, double dashLength, double gapLength) {
    final Path dest = Path();
    for (final metric in source.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        final double next = (distance + dashLength).clamp(0.0, metric.length);
        dest.addPath(metric.extractPath(distance, next), Offset.zero);
        distance = next + gapLength;
      }
    }
    return dest;
  }

  @override
  bool shouldRepaint(covariant _DashedCirclePainter old) {
    return old.color != color ||
        old.strokeWidth != strokeWidth ||
        old.dash != dash ||
        old.gap != gap;
  }
}
