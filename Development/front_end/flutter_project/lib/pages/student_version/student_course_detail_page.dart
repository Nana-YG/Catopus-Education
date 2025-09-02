import 'package:flutter/material.dart';
import 'package:flutter_project/utils/chapter_path_painter.dart';
import 'package:flutter_project/widgets/comment_board.dart';
import 'package:flutter_project/generated/app_localizations.dart';

class CourseDetailPage extends StatefulWidget {
  final String classId; // ✅ 新增
  final String className; // 课程名称
  final int taskCount; // ✅ 新增：任务数（章节数）

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
  String? selectedNote; // 当前选中的贴纸

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double baseWidth = 2160;
    double baseHeight = 1440;

    double scaleX = screenWidth / baseWidth;
    double scaleY = screenHeight / baseHeight;

    return Scaffold(
      backgroundColor: const Color(0xFFFDF9EC),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/bg_combined.png',
              fit: BoxFit.cover, // 或者 contain，看你的合成图比例
              alignment: Alignment.topLeft, // 合成图以左上为基准
            ),
          ),
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
                  child: _buildStickyNotesColumn(scaleX),
                ),
              ],
            ),
          ),
          Positioned(
            top: 40 * scaleY,
            left: 40 * scaleX,
            child: IconButton(
              icon: Icon(Icons.arrow_back, size: 36 * scaleX),
              tooltip: l10n.common_back, // ← 本地化
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Positioned(
            top: 100 * scaleY,
            left: 650 * scaleX,
            child: _buildChapterPath(scaleX),
          ),
        ],
      ),
    );
  }

  void _showCommentBoard(int chapterNumber) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: AppLocalizations.of(context)!.common_dismiss,
      barrierColor: Colors.black.withOpacity(0.1),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (_, __, ___) => const SizedBox.shrink(),
      transitionBuilder: (context, animation, secondaryAnimation, _) {
        final media = MediaQuery.of(context);
        final screenWidth = media.size.width;
        final screenHeight = media.size.height;
        final padding = media.padding;

        final boardWidth = screenWidth * 0.7;
        final boardHeight = screenHeight * 0.85;

        return FadeTransition(
          opacity: animation,
          child: Align(
            alignment: Alignment.centerRight,
            child: Container(
              width: boardWidth,
              height: boardHeight,
              margin: EdgeInsets.only(
                right: padding.right > 0 ? padding.right : 20,
              ),
              child: CommentBoard(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStickyNotesColumn(double scaleX) {
    final l10n = AppLocalizations.of(context)!;
    return SizedBox(
      width: 260 * scaleX,
      height: 500 * scaleX,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: 0,
            left: 0 * scaleX,
            child: _buildStickyNoteImage(
              imagePath: 'assets/images/sticky_yellow.png',
              label: l10n.courseDetail_materials,
              textRotation: -0.19,
              scaleX: scaleX,
              onTap: () {
                // 课程任务被点击：此处保留现状（地图本来就显示）
                // 需要行为的话写在这里（比如滚动到地图区域）
              },
            ),
          ),
          Positioned(
            top: 185 * scaleX,
            left: 90 * scaleX,
            child: _buildStickyNoteImage(
              imagePath: 'assets/images/sticky_red.png',
              label: l10n.courseDetail_commentBoard,
              textRotation: 0.26,
              scaleX: scaleX,
              onTap: () {
                // 评论板被点击：直接打开评论板（不通过章节按钮）
                _showCommentBoard(0); // 约定 0 代表“全局/不指定章节”
              },
            ),
          ),
          Positioned(
            top: 360 * scaleX,
            left: 26 * scaleX,
            child: _buildStickyNoteImage(
              imagePath: 'assets/images/sticky_blue.png',
              label: l10n.courseDetail_settings,
              textRotation: -0.26,
              scaleX: scaleX,
              onTap: () {
                // TODO: 打开设置页（未来再接）
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStickyNoteImage({
    required String imagePath,
    required String label,
    required double textRotation,
    required double scaleX,
    VoidCallback? onTap, // ← 新增
  }) {
    final isSelected = selectedNote == label;
    final double hitWidth = 370 * scaleX;
    final double hitHeight = 300 * scaleX;

    return SizedBox(
      width: hitWidth,
      height: hitHeight,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // 保留原高亮逻辑
            setState(() => selectedNote = (isSelected ? null : label));
            // 调用自定义回调（用于打开评论板/其他）
            if (onTap != null) onTap(); // ← 调用外部传入
          },
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
              Transform.rotate(
                angle: textRotation,
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 42 * scaleX,
                    fontFamily: 'Manrope',
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w400,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChapterPath(double scaleX) {
    final l10n = AppLocalizations.of(context)!;

    // 可见区域（你原来就是 1700×900）
    final double boxWidth = 1080 * scaleX;
    final double boxHeight = 900 * scaleX; // 直线高度不用太大

    // 节点外观尺寸
    final double nodeSize = 35 * scaleX;
    final double nodeRadius = nodeSize / 2;

    // 固定间距 & 两侧留白（你只需要改 spacing 就能控制“固定距离”）
    final double spacing = 180 * scaleX; // ←← 固定间距（自己调）
    final double sidePad = 60 * scaleX; // 左右留白

    final int count = widget.taskCount.clamp(3, 10);
    if (count <= 0) return const SizedBox.shrink();

    // “内容总宽度” = 左留白 + 间距*(count-1) + 右留白
    final double contentWidth =
        sidePad + (count > 1 ? (count - 1) * spacing : 0) + sidePad;

    // 如果内容比容器窄，就居中；否则让它按自身宽度渲染（外层可横向滚动）

    // 直线的 Y（居中）
    final double lineY = boxHeight * 0.5;

    // 生成“固定间距”的水平直线点
    final List<Offset> points = List.generate(
      count,
      (i) => Offset(sidePad + i * spacing, lineY),
    );

    Widget content(double width) {
      return SizedBox(
        width: width,
        height: boxHeight,
        child: Stack(
          children: [
            // 直线路径
            CustomPaint(
              size: Size(width, boxHeight),
              painter: StraightLinePathPainter(points: points, scale: scaleX),
            ),
            // 节点 + 文案
            ...List.generate(count, (index) {
              final pos = points[index];
              final isUnlocked = index < 9;

              return Positioned(
                left: pos.dx - nodeRadius - 5,
                top: pos.dy - nodeRadius,
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: null,
                      child: Container(
                        width: nodeSize,
                        height: nodeSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isUnlocked ? Colors.white : Colors.grey[300],
                          border: Border.all(color: Colors.black),
                        ),
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

    // 如果内容超过可见宽度 → 横向滚动；不超过 → 居中显示
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
