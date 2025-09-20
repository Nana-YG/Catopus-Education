import 'package:flutter/material.dart';
import 'package:flutter_project/generated/app_localizations.dart';
import 'package:flutter_project/widgets/comment_boards_holder.dart';
// 只导入 LeftTab 类型和 LeftRail 组件
import 'package:flutter_project/widgets/left_rail.dart' show LeftRail, LeftTab;
import 'package:flutter_project/widgets/right_plain_student_area.dart';

class TeacherCourseDetailPage extends StatefulWidget {
  final String classId;
  final String className;
  final int taskCount;

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
  // ✅ 用枚举而不是 String
  LeftTab _selected = LeftTab.primary;

  @override
  void initState() {
    super.initState();
    // 老师默认选中第一个标签（班级管理）
    _selected = LeftTab.primary;
  }

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
              final double screenW = constraints.maxWidth;
              final double scale = (screenW / 1440).clamp(0.6, 1.5);
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
                    // 左栏（固定宽度）
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: leftRailWidth,
                        maxWidth: leftRailWidth,
                      ),
                      child: LeftRail(
                        className: widget.className,
                        railWidth: leftRailWidth,
                        // ✅ 现在拿到的是枚举
                        onSelect: (tab) => setState(() => _selected = tab),
                      ),
                    ),

                    // 右栏
                    Expanded(
                      child: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: rightMaxWidth,
                            minHeight: 600,
                          ),
                          child: _buildRightArea(l10n),
                        ),
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
        // 老师：第一个标签 = 班级管理
        return RightPlainStudentArea(
          title: l10n.courseDetail_classManagement,
          classId: widget.classId,
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
