import 'package:flutter/material.dart';

class StickyNotesScaled extends StatelessWidget {
  final double railWidth;
  final double maxAreaHeight; // 来自 LeftRail：左栏可用高度
  final String classLabel;
  final String commentLabel;
  final String settingsLabel;
  final VoidCallback onTapClass;
  final VoidCallback onTapComment;
  final VoidCallback onTapSettings;

  const StickyNotesScaled({
    super.key,
    required this.railWidth,
    required this.maxAreaHeight,
    required this.classLabel,
    required this.commentLabel,
    required this.settingsLabel,
    required this.onTapClass,
    required this.onTapComment,
    required this.onTapSettings,
  });

  @override
  Widget build(BuildContext context) {
    // 设计底稿尺寸（不渲染到屏幕，作为“自然尺寸”）
    const double baseW = 320;
    const double baseH = 528;

    // 让 FittedBox 决定缩放比例：谁更“紧”就按谁来，且不裁切
    return SizedBox(
      width: railWidth,
      height: maxAreaHeight,
      child: FittedBox(
        fit: BoxFit.contain,
        // 注：如果你希望三张便签**在左栏垂直正中**，外层 LeftRail 已经用 Center 包住；
        // 这里设成 centerLeft 更直观
        alignment: Alignment.centerLeft,
        child: _StickyCanvas(
          baseW: baseW,
          baseH: baseH,
          classLabel: classLabel,
          commentLabel: commentLabel,
          settingsLabel: settingsLabel,
          onTapClass: onTapClass,
          onTapComment: onTapComment,
          onTapSettings: onTapSettings,
        ),
      ),
    );
  }
}

class _StickyCanvas extends StatelessWidget {
  final double baseW;
  final double baseH;
  final String classLabel;
  final String commentLabel;
  final String settingsLabel;
  final VoidCallback onTapClass;
  final VoidCallback onTapComment;
  final VoidCallback onTapSettings;

  const _StickyCanvas({
    required this.baseW,
    required this.baseH,
    required this.classLabel,
    required this.commentLabel,
    required this.settingsLabel,
    required this.onTapClass,
    required this.onTapComment,
    required this.onTapSettings,
  });

  @override
  Widget build(BuildContext context) {
    // === 使用“相对位置 + 相对尺寸”而不是写死像素 ===
    // 便签尺寸占底稿的比例
    const double wRatio = 200 / 270; // ≈0.666
    const double hRatio = 150 / 400; // ≈0.326
    final double stickyW = baseW * wRatio;
    final double stickyH = baseH * hRatio;

    // 三张便签的左上角位置（相对 baseH / baseW）
    final _p1 = Offset(baseW * -0.07, baseH * 0.15); // 黄
    final _p2 = Offset(baseW * 0.08, baseH * 0.43); // 红
    final _p3 = Offset(baseW * -0.07, baseH * 0.61); // 蓝

    return SizedBox(
      width: baseW,
      height: baseH,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // ✅ 红色贴纸：显示“班级/课程”（原 classLabel）
          Positioned(
            left: _p1.dx,
            top: _p1.dy,
            child: _StickyCard(
              imagePath: 'assets/images/sticky_blue.png',
              width: stickyW,
              height: stickyH,
              label: classLabel,
              rotation: 0,
              fontSize: (stickyW * 0.11).clamp(12.0, 26.0),
              onTap: onTapClass,
            ),
          ),

          // ✅ 蓝色贴纸：显示“评论板”（原 commentLabel）
          Positioned(
            left: _p2.dx,
            top: _p2.dy,
            child: _StickyCard(
              imagePath: 'assets/images/sticky_red.png',
              width: stickyW,
              height: stickyH,
              label: commentLabel,
              rotation: 0,
              fontSize: (stickyW * 0.11).clamp(12.0, 26.0),
              onTap: onTapComment,
            ),
          ),
        ],
      ),
    );
  }
}

class _StickyCard extends StatelessWidget {
  final String imagePath;
  final double width;
  final double height;
  final String label;
  final double rotation;
  final double fontSize; // 👈 文本随缩放
  final VoidCallback onTap;

  const _StickyCard({
    required this.imagePath,
    required this.width,
    required this.height,
    required this.label,
    required this.rotation,
    required this.fontSize,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // 文字区域留点边距，比例写法
    final double horizontalPadding = width * 0.06;

    return SizedBox(
      width: width,
      height: height,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Transform.rotate(
                angle: rotation,
                child: Image.asset(
                  imagePath,
                  width: width,
                  height: height,
                  fit: BoxFit.contain,
                ),
              ),
              Transform.rotate(
                angle: rotation,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      label,
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                        height: 1.1,
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
}
