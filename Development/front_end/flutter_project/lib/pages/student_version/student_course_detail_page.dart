import 'package:flutter/material.dart';
import 'package:flutter_project/generated/app_localizations.dart';
import 'package:flutter_project/widgets/left_rail.dart' show LeftRail, LeftTab;
import 'package:flutter_project/widgets/comment_boards_holder.dart';

class StudentCourseDetailPage extends StatefulWidget {
  final String classId;
  final String className;
  final int taskCount;

  const StudentCourseDetailPage({
    super.key,
    required this.classId,
    required this.className,
    required this.taskCount,
  });

  @override
  State<StudentCourseDetailPage> createState() =>
      _StudentCourseDetailPageState();
}

class _StudentCourseDetailPageState extends State<StudentCourseDetailPage> {
  LeftTab _selected = LeftTab.primary; // 默认选课程任务

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFFDF9EC),
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/bg_combined.png'),
              fit: BoxFit.fill,
              alignment: Alignment.topLeft,
            ),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              const double baseLeftRailWidth = 300;
              final double scale =
                  (constraints.maxWidth / 1440).clamp(0.6, 1.5);
              final double leftRailWidth = baseLeftRailWidth * scale;

              final double rightMaxWidth = constraints.maxWidth >= 1600
                  ? 1280
                  : constraints.maxWidth >= 1200
                      ? 1100
                      : 980;

              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: constraints.maxWidth >= 1200 ? 48 : 24,
                  vertical: constraints.maxHeight >= 900 ? 32 : 16,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 左侧菜单栏
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: leftRailWidth,
                        maxWidth: leftRailWidth,
                      ),
                      child: LeftRail(
                        className: widget.className,
                        railWidth: leftRailWidth,
                        onSelect: (tab) => setState(() => _selected = tab),
                      ),
                    ),

                    // 右侧区域
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, c) {
                          final double width = c.maxWidth >= rightMaxWidth
                              ? rightMaxWidth
                              : c.maxWidth;
                          return Align(
                            alignment: Alignment.topCenter,
                            child: SizedBox(
                              width: width,
                              height: c.maxHeight,
                              child: _buildRightArea(l10n),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildRightArea(AppLocalizations l10n) {
    switch (_selected) {
      case LeftTab.primary:
        return _RightTasksMapAdaptive(
          taskCount: widget.taskCount,
          title: l10n.courseDetail_materials,
        );
      case LeftTab.comment:
        return CommentBoardsHolder(classId: widget.classId);
      case LeftTab.settings:
        return Center(
          child: Text(
            l10n.courseDetail_settings,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
          ),
        );
    }
  }
}

/* ================== 右侧：课程任务地图 ================== */
class _RightTasksMapAdaptive extends StatelessWidget {
  final int taskCount;
  final String title;
  const _RightTasksMapAdaptive(
      {super.key, required this.taskCount, required this.title});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final double scaleX = (c.maxWidth / 1080).clamp(0.7, 1.4);

        return SizedBox.expand(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Expanded(
                child: _ChapterPath(
                  scaleX: scaleX,
                  count: taskCount,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/* ================== 章节路径（直线） ================== */
class _ChapterPath extends StatelessWidget {
  final double scaleX;
  final int count;
  const _ChapterPath({required this.scaleX, required this.count});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double boxWidth = constraints.maxWidth;
        final double boxHeight = constraints.maxHeight;

        final double nodeSize = 30;
        final double nodeRadius = nodeSize / 2;

        final int safeCount = (count <= 0) ? 3 : count.clamp(1, 10);

        // 在画布中均匀分布节点
        final double spacing = boxWidth / (safeCount + 1);

        // 垂直微调（>0 往下，<0 往上），按需改，比如 -6 或 +8
        const double verticalBias = 0;
        final double lineY = boxHeight * 0.5 + verticalBias;

        final List<Offset> points = List.generate(
          safeCount,
          (i) => Offset(spacing * (i + 1), lineY),
        );

        return SizedBox.expand(
          child: Stack(
            children: [
              // 直线路径（在圆与圆之间收边）
              CustomPaint(
                size: Size(boxWidth, boxHeight),
                painter: _StraightLinePathPainter(
                  points: points,
                  radius: nodeRadius,
                  gap: 1.0, // 额外再缩进 1px，避免视觉粘连；想要更开一点改 2~3
                  strokeWidth: 4,
                ),
              ),

              // 节点 + 文本
              ...List.generate(safeCount, (index) {
                final pos = points[index];
                return Positioned(
                  left: pos.dx - nodeRadius,
                  top: pos.dy - nodeRadius,
                  child: Column(
                    children: [
                      Container(
                        width: nodeSize,
                        height: nodeSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(color: Colors.black, width: 2),
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        // 用本地化的话换成 l10n.courseDetail_chapterN(index+1)
                        // 这里只演示固定英文字
                        '', // 不要文字就留空；需要就改成 'Chapter ${index + 1}'
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

/* ================== Painter：直线 ================== */
class _StraightLinePathPainter extends CustomPainter {
  final List<Offset> points;
  final double radius; // 圆半径
  final double gap; // 额外收边
  final double strokeWidth;

  _StraightLinePathPainter({
    required this.points,
    required this.radius,
    this.gap = 0,
    this.strokeWidth = 4,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final double inset = radius + gap;

    for (int i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];

      // 只画圆与圆之间的可见直线，左右各内缩一个半径（再加 gap）
      final start = Offset(p0.dx + inset, p0.dy);
      final end = Offset(p1.dx - inset, p1.dy);

      if (end.dx > start.dx) {
        canvas.drawLine(start, end, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _StraightLinePathPainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.radius != radius ||
        oldDelegate.gap != gap ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
