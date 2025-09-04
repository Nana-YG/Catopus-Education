import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_project/generated/app_localizations.dart';
import 'package:flutter_project/pages/avatar_editor_page.dart';
import 'package:flutter_project/pages/comment_boards_area.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_project/utils/constant.dart'; // baseApiUrl
// 如需用你自己的像素头像，可引入 AvatarPainter 并在 _StudentAvatar 中替换
// import 'package:flutter_project/pages/avatar_editor_page.dart';

class TeacherCourseDetailPage extends StatefulWidget {
  final String classId; // 班级ID
  final String className; // 班级名称
  final int taskCount; // 老师版不用地图，可忽略

  const TeacherCourseDetailPage({
    super.key,
    required this.classId,
    required this.className,
    required this.taskCount,
  });

  @override
  State<TeacherCourseDetailPage> createState() =>
      _TeacherCourseDetailPageState();
}

class _TeacherCourseDetailPageState extends State<TeacherCourseDetailPage> {
  String? selectedNote; // 左侧便签高亮状态
  @override
  void initState() {
    super.initState();
    // 这里设置默认值
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final l10n = AppLocalizations.of(context)!;
      setState(() {
        selectedNote = l10n.courseDetail_classManagement; // 默认选中“班级管理”
      });
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
          Positioned.fill(
            child: Image.asset(
              'assets/images/bg_combined.png',
              fit: BoxFit.cover,
              alignment: Alignment.topLeft,
            ),
          ),
          // 左上角标题 + 便签列
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
          // 返回按钮
          Positioned(
            top: 40 * scaleY,
            left: 40 * scaleX,
            child: IconButton(
              icon: Icon(Icons.arrow_back, size: 36 * scaleX),
              tooltip: l10n.common_back,
              onPressed: () => Navigator.pop(context),
            ),
          ),
          // 右侧主体：按你给的图，居中标题 + 头像网格 + 最后一个是虚线“+”
          Positioned(
            top: 50 * scaleY,
            left: 600 * scaleX,
            child: SizedBox(
              width: 1300 * scaleX,
              height: 1350 * scaleY,
              child: _buildRightArea(l10n), // 👈 改为调用一个方法
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStickyNotesColumn(double scaleX, AppLocalizations l10n) {
    return SizedBox(
      width: 260 * scaleX,
      height: 500 * scaleX,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 便签1：班级管理
          Positioned(
            top: 0,
            left: 0 * scaleX,
            child: _buildStickyNoteImage(
              imagePath: 'assets/images/sticky_yellow.png',
              label: l10n.courseDetail_classManagement,
              textRotation: -0.19,
              scaleX: scaleX,
              textOffset: Offset(4 * scaleX, 8 * scaleX),
              onTap: () {
                setState(
                    () => selectedNote = l10n.courseDetail_classManagement);
              },
            ),
          ),
          // 便签2：评论板
          Positioned(
            top: 185 * scaleX,
            left: 90 * scaleX,
            child: _buildStickyNoteImage(
              imagePath: 'assets/images/sticky_red.png',
              label: l10n.courseDetail_commentBoard,
              textRotation: 0.26,
              scaleX: scaleX,
              onTap: () {
                setState(() => selectedNote = l10n.courseDetail_commentBoard);
              },
            ),
          ),
          // 便签3：设置
          Positioned(
            top: 360 * scaleX,
            left: 26 * scaleX,
            child: _buildStickyNoteImage(
              imagePath: 'assets/images/sticky_blue.png',
              label: l10n.courseDetail_settings,
              textRotation: -0.26,
              scaleX: scaleX,
              onTap: () {
                setState(() => selectedNote = l10n.courseDetail_settings);
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
    VoidCallback? onTap,
    Offset? textOffset, // 可选：额外微调位置
    double textWidthFactor = 0.72, // 文本最大宽度相对整张便签的比例
  }) {
    final isSelected = selectedNote == label;
    final double hitWidth = 370 * scaleX;
    final double hitHeight = 300 * scaleX;

    // 英文太长时，尝试在中间空格处断成两行（如 "Class Management"）
    String _autoBreak(String s) {
      if (!s.contains(' ')) return s;
      // 找最接近中点的空格并替换为换行
      final mid = (s.length / 2).round();
      int bestIdx = -1;
      int bestDist = 1 << 30;
      for (int i = 0; i < s.length; i++) {
        if (s[i] == ' ') {
          final d = (i - mid).abs();
          if (d < bestDist) {
            bestDist = d;
            bestIdx = i;
          }
        }
      }
      if (bestIdx == -1) return s;
      return s.substring(0, bestIdx) + '\n' + s.substring(bestIdx + 1);
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
              // 贴纸图片
              SizedBox(
                width: hitWidth,
                height: hitHeight,
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: Image.asset(imagePath),
                ),
              ),
              // 文本：限制宽度 + 居中 + 最多两行 + 可微调偏移
              Transform.translate(
                offset: textOffset ?? Offset(0, 0),
                child: Transform.rotate(
                  angle: textRotation,
                  child: SizedBox(
                    width: hitWidth * textWidthFactor, // 关键：限制文字宽度
                    child: FittedBox(
                      fit: BoxFit.scaleDown, // 若两行仍略宽，自动等比缩小
                      child: Text(
                        displayLabel,
                        textAlign: TextAlign.center,
                        softWrap: true,
                        maxLines: 2,
                        overflow: TextOverflow.visible,
                        style: TextStyle(
                          fontSize: 42 * scaleX,
                          fontFamily: 'Manrope',
                          fontWeight:
                              isSelected ? FontWeight.w800 : FontWeight.w400,
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

  Widget _buildRightArea(AppLocalizations l10n) {
    // 防御：如果 selectedNote 还没初始化，默认显示班级管理
    final note = selectedNote ?? l10n.courseDetail_classManagement;

    if (note == l10n.courseDetail_classManagement) {
      // 班级管理（你原来的区域）
      return _RightPlainStudentArea(
        title: l10n.courseDetail_classManagement,
        classId: widget.classId,
      );
    } else if (note == l10n.courseDetail_commentBoard) {
      // 评论板（使用你独立文件里的 CommentBoardsArea）
      return const DecoratedBox(
        decoration: BoxDecoration(color: Colors.transparent),
        child: Padding(
          padding: EdgeInsets.only(top: 0), // 需要可微调
          child: _CommentBoardsHolder(), // 👈 包一层以便热切换动画
        ),
      );
    } else if (note == l10n.courseDetail_settings) {
      // 设置页（先占位，后续你再填）
      return Center(
        child: Text(
          l10n.courseDetail_settings,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
        ),
      );
    }

    // 兜底：还是显示班级管理
    return _RightPlainStudentArea(
      title: l10n.courseDetail_classManagement,
      classId: widget.classId,
    );
  }
}

class _CommentBoardsHolder extends StatelessWidget {
  const _CommentBoardsHolder();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final parentState =
        context.findAncestorStateOfType<_TeacherCourseDetailPageState>();
    final classId = parentState?.widget.classId ?? '';

    return CommentBoardsArea(
      classId: classId,
      title: l10n.courseDetail_commentBoard, // 顶部标题
    );
  }
}

/* ===========================
   右侧无卡片的纯展示区域 + 学生网格（参考你的截图）
   =========================== */

class _RightPlainStudentArea extends StatelessWidget {
  final String title;
  final String classId;

  const _RightPlainStudentArea({
    required this.title,
    required this.classId,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 顶部标题：居中显示（和截图一致）
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Text(
            title, // 建议 l10n 为“管理班级”
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(child: _StudentGrid(classId: classId)),
      ],
    );
  }
}

class _StudentGrid extends StatefulWidget {
  final String classId;
  const _StudentGrid({required this.classId});

  @override
  State<_StudentGrid> createState() => _StudentGridState();
}

class _StudentGridState extends State<_StudentGrid> {
  late Future<List<_StudentBrief>> _future;

  @override
  void initState() {
    super.initState();
    _future = _fetchStudents();
  }

  Future<List<_StudentBrief>> _fetchStudents() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username') ?? '';
    final token = prefs.getString('token') ?? '';

    final uri = Uri.parse('$baseApiUrl/course/inClassStudents');
    final resp = await http.get(uri, headers: {
      'Username': username,
      'Token': token,
      'classId': widget.classId,
    });

    if (resp.statusCode != 200) {
      throw Exception('加载学生失败: ${resp.statusCode} ${resp.body}');
    }

    final jsonMap = jsonDecode(resp.body);
    final List<dynamic> students = jsonMap['studentList'] ?? [];

    final list = <_StudentBrief>[];
    for (final s in students) {
      final studentUsername = s.toString();
      final avatar = await _fetchAvatarHex(studentUsername, token);
      list.add(_StudentBrief(
        userIdOrUsername: studentUsername,
        avatarHex: avatar, // "#RRGGBB#RRGGBB..." 形式（若你的头像是像素色块字符串）
      ));
    }
    return list;
  }

  Future<String?> _fetchAvatarHex(String studentUsername, String token) async {
    final uri = Uri.parse('$baseApiUrl/login/profile-picture');
    final res = await http.get(uri, headers: {
      'Username': studentUsername,
      'Token': token,
    });

    if (res.statusCode != 200) return null;

    final body = jsonDecode(res.body);
    final raw = body['profilePicture'];
    if (raw == null || raw.toString().isEmpty) return null;

    final str = raw.toString();
    return RegExp(r'^#').hasMatch(str)
        ? str
        : str.replaceAllMapped(RegExp(r'.{6}'), (m) => '#${m.group(0)}');
  }

  Future<void> _remove(String userIdOrUsername) async {
    final l10n = AppLocalizations.of(context)!;

    final ok = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'confirm-remove',
      barrierColor: Colors.black.withOpacity(0.15), // 半透明遮罩
      pageBuilder: (_, __, ___) {
        return const SizedBox.shrink();
      },
      transitionBuilder: (ctx, anim, __, ___) {
        // 轻微缩放+透明过渡
        final curved =
            CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 1.5, sigmaY: 1.5),
          child: Opacity(
            opacity: anim.value,
            child: Transform.scale(
              scale: 0.98 + 0.02 * curved.value,
              child: Center(
                child: _RemoveConfirmDialog(
                  title: l10n.removeStudentTitle, // 例如：确定要将这个学生移除本班级吗？
                  confirmText: l10n.removeConfirm, // 例如：确定移除
                  cancelText: l10n.common_cancel, // 例如：取消
                  onConfirm: () => Navigator.of(ctx).pop(true),
                  onCancel: () => Navigator.of(ctx).pop(false),
                ),
              ),
            ),
          ),
        );
      },
    );

    if (ok != true) return;

    // === 原先的删除请求逻辑保留 ===
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username') ?? '';
    final token = prefs.getString('token') ?? '';

    final uri = Uri.parse(
      '$baseApiUrl/course/removeStudent'
      '?classId=${Uri.encodeQueryComponent(widget.classId)}'
      '&userId=${Uri.encodeQueryComponent(userIdOrUsername)}',
    );

    final res = await http.delete(uri, headers: {
      'Username': username,
      'Token': token,
    });

    if (res.statusCode == 200) {
      setState(() => _future = _fetchStudents());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.removedSuccess)),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  '${AppLocalizations.of(context)!.removeFailed}: ${res.statusCode} ${res.body}')),
        );
      }
    }
  }

  void _onAdd() async {
    // TODO: 这里写你的“添加学生”交互（比如输入加入码 / 选择学生 / 扫码等）
    // 先给个占位提示
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('点击了添加学生')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<_StudentBrief>>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return Center(child: Text('加载失败：${snap.error}'));
        }
        final students = snap.data ?? const [];

        // 为了让“+”按钮始终出现在最后，构造显示总数 = 学生数 + 1
        final itemCount = students.length + 1;

        return LayoutBuilder(
          builder: (context, constraints) {
            // 目标单元格宽度（你可以微调 140 这个基准）
            const double targetTileWidth = 140;

            // 先算出列数，限制在 5~10 列之间
            final crossAxisCount =
                (constraints.maxWidth / targetTileWidth).floor().clamp(5, 10);

            // 实际每格可用宽度（含间距的近似）
            final tileWidth = constraints.maxWidth / crossAxisCount;

            // 根据单元格宽度得出头像直径，限制在 48~72 之间
            final double avatarSize = (tileWidth * 0.38).clamp(60, 72);
            // 👉 更紧凑的间距：随头像缩放，但保留最小 8
            final double gap = (avatarSize * 0.1).clamp(1, 14);

            return GridView.builder(
              padding: const EdgeInsets.only(right: 8, bottom: 8),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: gap, // ↓ 上下间距
                crossAxisSpacing: gap, // ↓ 左右间距
                childAspectRatio: 0.94,
              ),
              itemCount: itemCount,
              itemBuilder: (context, i) {
                if (i == students.length) {
                  return _AddTile(onTap: _onAdd, avatarSize: avatarSize);
                }
                final s = students[i];
                return _StudentTile(
                  student: s,
                  onRemove: () => _remove(s.userIdOrUsername),
                  avatarSize: avatarSize, // 👈 传入
                  nameWidth: (tileWidth * 0.78).toDouble(), // 👈 文本区域跟着缩放
                );
              },
            );
          },
        );
      },
    );
  }
}

class _RemoveConfirmDialog extends StatelessWidget {
  final String title;
  final String confirmText;
  final String cancelText;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const _RemoveConfirmDialog({
    required this.title,
    required this.confirmText,
    required this.cancelText,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // 主体卡片：更窄但固定高度更高
        Container(
          width: 400, // 窄一些
          height: 200, // ✅ 固定更高的高度
          padding: const EdgeInsets.fromLTRB(28, 28, 28, 28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A000000),
                blurRadius: 28,
                offset: Offset(0, 10),
              )
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween, // ✅ 内容上下分布
            children: [
              // 中间提示词
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                  height: 1.6,
                ),
              ),

              // 底部按钮行
              Row(
                children: [
                  // 确定移除 —— 文字+下划线
                  Expanded(
                    child: TextButton(
                      onPressed: onConfirm,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        foregroundColor: Colors.black,
                      ),
                      child: Text(
                        confirmText,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 50),
                  // 取消 —— 黑底白字，圆角矩形
                  Expanded(
                    child: FilledButton(
                      onPressed: onCancel,
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      child: Text(
                        cancelText,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // 右上角关闭按钮
        Positioned(
          right: -8,
          top: -8,
          child: GestureDetector(
            onTap: onCancel,
            child: Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(Icons.close, size: 18, color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/* ===========
   数据模型
   =========== */
class _StudentBrief {
  final String userIdOrUsername; // studentList 返回的用户名/ID
  final String? avatarHex; // "#RRGGBB#RRGGBB..."（可为空）

  _StudentBrief({required this.userIdOrUsername, required this.avatarHex});
}

/* ===========
   学生头像格子（纯头像 + 右上角黑色“-”）
   =========== */
class _StudentTile extends StatelessWidget {
  final _StudentBrief student;
  final VoidCallback onRemove;
  final double avatarSize; // 👈 新增
  final double? nameWidth; // 👈 可选：名字显示宽度

  const _StudentTile({
    required this.student,
    required this.onRemove,
    required this.avatarSize,
    this.nameWidth,
  });

  @override
  Widget build(BuildContext context) {
    final name = student.userIdOrUsername;
    final hasAvatar =
        student.avatarHex != null && student.avatarHex!.isNotEmpty;

    final iconSize = avatarSize * 0.48;

    return Column(
      mainAxisSize: MainAxisSize.min,
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
                border:
                    Border.all(color: Colors.black.withOpacity(0.8), width: 1),
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
                  width: avatarSize * 0.26, // 跟随头像缩放
                  height: avatarSize * 0.26,
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.remove,
                      size: avatarSize * 0.16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: nameWidth ?? (avatarSize * 1.3),
          child: Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: (avatarSize * 0.22).clamp(13, 16), // 原 0.17 -> 0.22
              fontWeight: FontWeight.w600,
              height: 1.15, // 紧凑行高
            ),
          ),
        ),
      ],
    );
  }
}

/* ===========
   “添加学生” 虚线圆按钮（右下角/最后一格）
   =========== */
class _AddTile extends StatelessWidget {
  final VoidCallback onTap;
  final double avatarSize; // 👈 新增
  const _AddTile({required this.onTap, required this.avatarSize});

  @override
  Widget build(BuildContext context) {
    final plusSize = avatarSize * 0.33;
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: CustomPaint(
            size: Size(avatarSize, avatarSize),
            painter: _DashedCirclePainter(
                color: Colors.black38, strokeWidth: 1.5, dash: 6, gap: 4),
            child: SizedBox(
              width: avatarSize,
              height: avatarSize,
              child: Center(
                  child:
                      Icon(Icons.add, size: plusSize, color: Colors.black45)),
            ),
          ),
        ),
        const SizedBox(height: 8),
        const SizedBox(width: 1, child: Text('')),
      ],
    );
  }
}

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
    for (final PathMetric metric in source.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        final double len = (distance + dashLength).clamp(0.0, metric.length);
        dest.addPath(metric.extractPath(distance, len), Offset.zero);
        distance = len + gapLength;
      }
    }
    return dest;
  }

  @override
  bool shouldRepaint(covariant _DashedCirclePainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.dash != dash ||
        oldDelegate.gap != gap;
  }
}
