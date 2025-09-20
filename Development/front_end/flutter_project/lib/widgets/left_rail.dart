// left_rail.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_project/generated/app_localizations.dart';
import 'package:flutter_project/widgets/sticky_notes.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 左栏三个标签的语义枚举（不要用字符串做状态了）
enum LeftTab { primary, comment, settings }

class LeftRail extends StatefulWidget {
  final String className;
  final double railWidth;
  final ValueChanged<LeftTab> onSelect; // ← 改成枚举

  const LeftRail({
    super.key,
    required this.className,
    required this.railWidth,
    required this.onSelect,
  });

  @override
  State<LeftRail> createState() => _LeftRailState();
}

class _LeftRailState extends State<LeftRail> {
  bool _isTeacher = false;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _readRole();
  }

  Future<void> _readRole() async {
    final prefs = await SharedPreferences.getInstance();
    final accountType = (prefs.getString('accountType') ?? '').toUpperCase();
    final role = (prefs.getString('role') ?? '').toLowerCase();
    final isTeacher = accountType == 'TEACHER' || role == 'teacher';
    if (!mounted) return;
    setState(() {
      _isTeacher = isTeacher;
      _loaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final size = MediaQuery.of(context).size;
    final bool isiOS = !kIsWeb && (defaultTargetPlatform == TargetPlatform.iOS);
    final double railW = widget.railWidth;

// Web 想更松一点；iOS 想更紧一点
    final double leftPad =
        (railW * (kIsWeb ? 0.06 : 0.04)).clamp(10.0, kIsWeb ? 28.0 : 20.0);
    final double topPad =
        (size.height * 0.015 + (kIsWeb ? 4.0 : 0.0)).clamp(8.0, 24.0);

// 返回键更大一点在 Web 才不挤；iOS 稍小
    final double backSize =
        (railW * (kIsWeb ? 0.09 : 0.075)).clamp(18.0, kIsWeb ? 28.0 : 24.0);

// iOS 字体整体 0.92 缩放，并且收紧上限
    final double baseTitle = ((size.width * 0.013) + (railW * 0.08));
    final double titleFont =
        (baseTitle * (isiOS ? 0.92 : 1.0)).clamp(16.0, isiOS ? 30.0 : 34.0);

// 轻微倾斜：Web 稍微更大；iOS 更小
    double _lerp(double a, double b, double t) => a + (b - a) * t;
    final double w = size.width.clamp(360.0, 1600.0);
    final double t = (w - 360.0) / (1600.0 - 360.0);
    final double rotateAngle =
        _lerp(isiOS ? 0.04 : 0.05, kIsWeb ? 0.12 : 0.10, t);

// 限制系统文字放大，避免 iOS 动态字体把标题挤爆（仍保留可读性）
    final textScaler = MediaQuery.of(context).textScaler;
    final cappedScaler = textScaler.clamp(maxScaleFactor: isiOS ? 1.10 : 1.20);

    if (!_loaded) {
      return SizedBox(
        width: widget.railWidth,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    // 第一个便签显示的文案随身份变化，但对外传出去的“值”永远是 LeftTab.primary
    final String firstLabel = _isTeacher
        ? l10n.courseDetail_classManagement
        : l10n.courseDetail_materials;

    // 限制左栏中部可用高度，给便签做等比缩放
    final double allowedH =
        (MediaQuery.of(context).size.height * 0.60).clamp(320.0, 720.0);

    return SizedBox(
      width: widget.railWidth,
      child: Stack(
        children: [
          // 顶部：返回 + 课程名（按钮贴左，标题有内边距）
          Positioned(
            top: topPad,
            left: 0, // ← 贴紧左侧
            right: leftPad, // ← 右侧仍保留你的自适应留白
            child: MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaler: cappedScaler),
              child: SizedBox(
                height: (backSize + 16).clamp(backSize + 8, 48), // 给按钮留足命中高度
                child: Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    // 1) 返回按钮：紧贴左侧
                    _BackButtonInline(
                      size: backSize,
                      onTap: () => Navigator.pop(context),
                      tooltip:
                          MaterialLocalizations.of(context).backButtonTooltip,
                    ),

                    // 2) 标题：在按钮命中区右侧开始，保持 Web 更宽的“间隙”
                    Padding(
                      padding: EdgeInsets.only(
                        left:
                            ((backSize + 16).clamp(backSize + 8, 44) // 按钮命中区宽度
                                +
                                (kIsWeb ? 14.0 : 8.0)), // 额外间隙（Web 更宽）
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Transform.rotate(
                              angle: rotateAngle,
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  widget.className,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: titleFont,
                                    fontFamily: 'Manrope',
                                    fontWeight: FontWeight.w700,
                                    height: 1.05,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 中部：便签（垂直居中）
          Center(
            child: SizedBox(
              width: widget.railWidth,
              child: StickyNotesScaled(
                railWidth: widget.railWidth,
                maxAreaHeight: allowedH,
                classLabel: firstLabel,
                commentLabel: l10n.courseDetail_commentBoard,
                settingsLabel: l10n.courseDetail_settings,
                onTapClass: () => widget.onSelect(LeftTab.primary),
                onTapComment: () => widget.onSelect(LeftTab.comment),
                onTapSettings: () => widget.onSelect(LeftTab.settings),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BackButtonInline extends StatelessWidget {
  final double size;
  final VoidCallback onTap;
  final String? tooltip;
  const _BackButtonInline(
      {required this.size, required this.onTap, this.tooltip});

  @override
  Widget build(BuildContext context) {
    final double hit = (size + 16).clamp(size + 8, 44);
    return Semantics(
      button: true,
      label: tooltip ?? 'Back',
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: hit,
          height: hit,
          child: Center(
              child: Icon(Icons.arrow_back, size: size, color: Colors.black87)),
        ),
      ),
    );
  }
}
