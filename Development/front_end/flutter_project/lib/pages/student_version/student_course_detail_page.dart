import 'package:flutter/material.dart';
import 'package:flutter_project/utils/chapter_path_painter.dart';
import 'package:flutter_project/widgets/comment_board.dart';

class CourseDetailPage extends StatefulWidget {
  final String className;

  const CourseDetailPage({super.key, required this.className});

  @override
  State<CourseDetailPage> createState() => _CourseDetailPageState();
}

class _CourseDetailPageState extends State<CourseDetailPage> {
  String? selectedNote; // 当前选中的贴纸

  @override
  Widget build(BuildContext context) {
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
          Positioned(
            top: 0 * scaleY,
            left: 0 * scaleX,
            child: Image.asset(
              'assets/images/Rectangle 168.png',
              width: 550 * scaleX,
              fit: BoxFit.contain,
            ),
          ),
          Positioned(
            top: 0 * scaleY,
            left: 10 * scaleX,
            child: Image.asset(
              'assets/images/Rectangle 173.png',
              width: 570 * scaleX,
              fit: BoxFit.contain,
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
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Positioned(
            top: 100 * scaleY,
            left: 800 * scaleX,
            child: _buildChapterPath(scaleX),
          ),
          Positioned(
            top: 40 * scaleY,
            right: 40 * scaleX,
            child: Row(
              children: [
                Icon(Icons.vpn_key_rounded,
                    color: Colors.pinkAccent, size: 36 * scaleX),
                SizedBox(width: 8 * scaleX),
                Text(
                  'x 5',
                  style: TextStyle(
                    fontSize: 24 * scaleX,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showCommentBoard(int chapterNumber) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Dismiss",
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
              child: CommentBoard(chapterNumber: chapterNumber),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStickyNotesColumn(double scaleX) {
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
              imagePath: 'assets/images/Rectangle 159.png',
              label: 'Materials',
              textRotation: -0.19,
              scaleX: scaleX,
            ),
          ),
          Positioned(
            top: 185 * scaleX,
            left: 90 * scaleX,
            child: _buildStickyNoteImage(
              imagePath: 'assets/images/Rectangle 169.png',
              label: 'Achievement',
              textRotation: 0.26,
              scaleX: scaleX,
            ),
          ),
          Positioned(
            top: 360 * scaleX,
            left: 26 * scaleX,
            child: _buildStickyNoteImage(
              imagePath: 'assets/images/Rectangle 170.png',
              label: 'Settings',
              textRotation: -0.26,
              scaleX: scaleX,
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
  }) {
    final isSelected = selectedNote == label;

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            selectedNote = null;
          } else {
            selectedNote = label;
          }
        });
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(
            imagePath,
            width: 370 * scaleX,
            fit: BoxFit.contain,
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
    );
  }

  Widget _buildChapterPath(double scaleX) {
    const int chapterCount = 12;

    final rawPoints = [
      Offset(50, 150),
      Offset(130, 50),
      Offset(180, 180),
      Offset(260, 290),
      Offset(350, 370),
      Offset(470, 380),
      Offset(580, 330),
      Offset(660, 260),
      Offset(750, 200),
      Offset(850, 250),
      Offset(940, 340),
      Offset(1020, 400),
    ];

// 放缩
    final points =
        rawPoints.map((p) => Offset(p.dx * scaleX, p.dy * scaleX)).toList();

// 构造 spline（不指定 startHandle/endHandle）
    final spline = CatmullRomSpline(points);

// 生成插值点，首尾直接用原始点
    final chapterPoints = [
      points.first,
      ...List.generate(
        chapterCount - 2,
        (i) => spline.transform((i + 1) / (chapterCount - 1)),
      ),
      points.last,
    ];

    return SizedBox(
      width: 1200 * scaleX,
      height: 600 * scaleX,
      child: Stack(
        children: [
          // 曲线路径绘制
          CustomPaint(
            size: Size(1200 * scaleX, 600 * scaleX),
            painter: ChapterPathPainter(points: points, scale: scaleX),
          ),

          // 按钮在线上
          ...List.generate(chapterCount, (index) {
            final pos = chapterPoints[index];
            final isUnlocked = index < 9;

            return Positioned(
              left: pos.dx - 12 * scaleX - 40 * scaleX, // 左移 10px（根据需要调节）

              top: pos.dy - 12 * scaleX,
              child: Column(
                children: [
                  GestureDetector(
                    onTap:
                        isUnlocked ? () => _showCommentBoard(index + 1) : null,
                    child: Container(
                      width: 24 * scaleX,
                      height: 24 * scaleX,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isUnlocked ? Colors.white : Colors.grey[300],
                        border: Border.all(color: Colors.black),
                      ),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Chapter ${index + 1}',
                    style: TextStyle(
                      fontSize: 20 * scaleX,
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
}
