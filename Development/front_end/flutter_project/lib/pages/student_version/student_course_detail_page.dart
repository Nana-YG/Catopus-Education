import 'package:flutter/material.dart';
import 'package:flutter_project/pages/comment_boards_area.dart';
import 'package:flutter_project/utils/chapter_path_painter.dart';
import 'package:flutter_project/generated/app_localizations.dart';

class CourseDetailPage extends StatefulWidget {
  final String classId;   // 班级ID
  final String className; // 课程名称
  final int taskCount;    // 章节/任务数量

  const CourseDetailPage({
    super.key,
    required this.className,
    required this.classId,
    required this.taskCount,
  });

  @override
  State<CourseDetailPage> createState() => _CourseDetailPageState();
}

class _CourseDetailPageState extends State<CourseDetailPage> {
  String? selectedNote; // 当前选中的便签

  @override
  void initState() {
    super.initState();
    // 默认显示课程任务（地图）
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final l10n = AppLocalizations.of(context)!;
      setState(() => selectedNote = l10n.courseDetail_materials);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;
    final screenHeight = size.height;

    const baseWidth = 2160.0;
    const baseHeight = 1440.0;
    final scaleX = screenWidth / baseWidth;
    final scaleY = screenHeight / baseHeight;

    return Scaffold(
      backgroundColor: const Color(0xFFFDF9EC),
      body: Stack(
        children: [
          // 背景
          Positioned.fill(
            child: Image.asset(
              'assets/images/bg_combined.png',
              fit: BoxFit.cover,
              alignment: Alignment.topLeft,
            ),
          ),

          // 左上：班级名 + 便签列
          Positioned(
            top: 100 * scaleY,
            left: 130 * scaleX,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Transform.rotate(
                  angle: 0.09,
                  child: Text(
                    widget.className,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 64 * scaleX,
                      fontFamily: 'Manrope',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                SizedBox(height: 40 * scaleY),
                Transform.translate(
                  offset: Offset(-85 * scaleX, 0),
                  child: _buildStickyNotesColumn(scaleX, l10n),
                ),
              ],
            ),
          ),

          // 左上返回
          Positioned(
            top: 40 * scaleY,
            left: 40 * scaleX,
            child: IconButton(
              icon: Icon(Icons.arrow_back, size: 36 * scaleX),
              tooltip: l10n.common_back,
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // 右侧主体区域：根据选中的便签切换（评论板 或 地图 或 设置）
          Positioned(
            top: 50 * scaleY,
            left: 600 * scaleX,
            child: SizedBox(
              width: 1300 * scaleX,
              height: 1350 * scaleY,
              child: _buildRightArea(l10n, scaleX),
            ),
          ),
        ],
      ),
    );
  }

  /* =======================================================================
   * 左侧便签列（Materials / Comment Board / Settings）
   * ======================================================================= */
  Widget _buildStickyNotesColumn(double scaleX, AppLocalizations l10n) {
    return SizedBox(
      width: 260 * scaleX,
      height: 500 * scaleX,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 课程任务（地图）
          Positioned(
            top: 0,
            left: 0 * scaleX,
            child: _sticky(
              imagePath: 'assets/images/sticky_yellow.png',
              label: l10n.courseDetail_materials,
              textRotation: -0.19,
              scaleX: scaleX,
              onTap: () => setState(() => selectedNote = l10n.courseDetail_materials),
              textOffset: Offset(4 * scaleX, 8 * scaleX),
            ),
          ),
          // 评论板（与老师一致，右侧内嵌，去掉“评论板”标题）
          Positioned(
            top: 185 * scaleX,
            left: 90 * scaleX,
            child: _sticky(
              imagePath: 'assets/images/sticky_red.png',
              label: l10n.courseDetail_commentBoard,
              textRotation: 0.26,
              scaleX: scaleX,
              onTap: () => setState(() => selectedNote = l10n.courseDetail_commentBoard),
            ),
          ),
          // 设置（占位）
          Positioned(
            top: 360 * scaleX,
            left: 26 * scaleX,
            child: _sticky(
              imagePath: 'assets/images/sticky_blue.png',
              label: l10n.courseDetail_settings,
              textRotation: -0.26,
              scaleX: scaleX,
              onTap: () => setState(() => selectedNote = l10n.courseDetail_settings),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sticky({
    required String imagePath,
    required String label,
    required double textRotation,
    required double scaleX,
    required VoidCallback onTap,
    Offset? textOffset,
    double textWidthFactor = 0.72,
  }) {
    final isSelected = selectedNote == label;
    final double hitWidth = 370 * scaleX;
    final double hitHeight = 300 * scaleX;

    String _autoBreak(String s) {
      if (!s.contains(' ')) return s;
      final mid = (s.length / 2).round();
      int bestIdx = -1, bestDist = 1 << 30;
      for (int i = 0; i < s.length; i++) {
        if (s[i] == ' ') {
          final d = (i - mid).abs();
          if (d < bestDist) { bestDist = d; bestIdx = i; }
        }
      }
      return bestIdx == -1 ? s : '${s.substring(0, bestIdx)}\n${s.substring(bestIdx + 1)}';
    }

    final displayLabel = _autoBreak(label);

    return SizedBox(
      width: hitWidth,
      height: hitHeight,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: hitWidth,
                height: hitHeight,
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: Image.asset(imagePath),
                ),
              ),
              Transform.translate(
                offset: textOffset ?? Offset.zero,
                child: Transform.rotate(
                  angle: textRotation,
                  child: SizedBox(
                    width: hitWidth * textWidthFactor,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        displayLabel,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        softWrap: true,
                        style: TextStyle(
                          fontSize: 42 * scaleX,
                          fontFamily: 'Manrope',
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w400,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /* =======================================================================
   * 右侧区域：根据便签选择切换内容
   * - Materials：显示地图（章节路径）
   * - Comment Board：显示与老师一致的评论板（去掉“评论板”标题）
   * - Settings：占位
   * ======================================================================= */
  Widget _buildRightArea(AppLocalizations l10n, double scaleX) {
    final note = selectedNote ?? l10n.courseDetail_materials;

    if (note == l10n.courseDetail_commentBoard) {
      // ✅ 学生端评论板与教师一致：右侧内嵌 + 无“评论板”标题
      return _RightCommentBoardsPane(classId: widget.classId);
    }

    if (note == l10n.courseDetail_settings) {
      return const Center(
        child: Text(
          'Settings',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
        ),
      );
    }

    // 默认：课程任务（地图）
    return _RightTasksMap(
      taskCount: widget.taskCount,
      scaleX: scaleX,
      title: l10n.courseDetail_materials,
    );
  }
}

/* ========================= 右侧：评论板（与老师一致，无标题） ========================= */
class _RightCommentBoardsPane extends StatelessWidget {
  final String classId;
  const _RightCommentBoardsPane({required this.classId});

  @override
  Widget build(BuildContext context) {
    return CommentBoardsArea(
      classId: classId,
      title: '',                    // ← 去掉“评论板”字样
      outerControlsHorizontal: true // ← 保持侧边布局的适配
    );
  }
}

/* ========================= 右侧：课程任务地图（水平直线+节点） ========================= */
class _RightTasksMap extends StatelessWidget {
  final int taskCount;
  final double scaleX;
  final String title;

  const _RightTasksMap({
    super.key,
    required this.taskCount,
    required this.scaleX,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    // 顶部标题（保留“课程任务/Materials”字样）
    return Column(
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

        // 地图主体
        Expanded(child: _ChapterPath(scaleX: scaleX, count: taskCount)),
      ],
    );
  }
}

class _ChapterPath extends StatelessWidget {
  final double scaleX;
  final int count;
  const _ChapterPath({required this.scaleX, required this.count});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final double boxWidth = 1080 * scaleX;
    final double boxHeight = 900 * scaleX;

    final double nodeSize = 35 * scaleX;
    final double nodeRadius = nodeSize / 2;

    final double spacing = 180 * scaleX; // 固定间距
    final double sidePad = 60 * scaleX;  // 左右留白

    final int safeCount = count.clamp(3, 10);
    if (safeCount <= 0) return const SizedBox.shrink();

    final double contentWidth =
        sidePad + (safeCount > 1 ? (safeCount - 1) * spacing : 0) + sidePad;
    final double lineY = boxHeight * 0.5;

    final List<Offset> points = List.generate(
      safeCount,
      (i) => Offset(sidePad + i * spacing, lineY),
    );

    Widget content(double width) {
      return SizedBox(
        width: width,
        height: boxHeight,
        child: Stack(
          children: [
            // 直线
            CustomPaint(
              size: Size(width, boxHeight),
              painter: StraightLinePathPainter(points: points, scale: scaleX),
            ),
            // 节点 + 文案（点击节点不做任何事，不会打开评论板）
            ...List.generate(safeCount, (index) {
              final pos = points[index];
              final isUnlocked = true;

              return Positioned(
                left: pos.dx - nodeRadius - 5,
                top: pos.dy - nodeRadius,
                child: Column(
                  children: [
                    // 不绑定任何 onTap（满足“点击章节不打开评论板”）
                    Container(
                      width: nodeSize,
                      height: nodeSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isUnlocked ? Colors.white : Colors.grey[300],
                        border: Border.all(color: Colors.black),
                      ),
                    ),
                    SizedBox(height: 6 * scaleX),
                    Text(
                      l10n.courseDetail_chapterN(index + 1),
                      style: TextStyle(
                        fontSize: 28 * scaleX,
                        fontWeight: FontWeight.w500,
                        color: isUnlocked
                            ? Colors.black
                            : Colors.grey.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      );
    }

    return SizedBox(
      width: boxWidth,
      height: boxHeight,
      child: contentWidth > boxWidth
          ? SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: content(contentWidth),
            )
          : content(boxWidth),
    );
  }
}
