import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_project/generated/app_localizations.dart';
import 'package:flutter_project/models/student_brief.dart';
import 'package:flutter_project/widgets/remove_confirm_dialog.dart';
import 'package:flutter_project/widgets/student_tile.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_project/utils/constant.dart';


class StudentGrid extends StatefulWidget {
  final String classId;
  const StudentGrid({super.key, required this.classId});

  @override
  State<StudentGrid> createState() => _StudentGridState();
}

class _StudentGridState extends State<StudentGrid> {
  late Future<List<StudentBrief>> _future;

  @override
  void initState() {
    super.initState();
    _future = _fetchStudents();
  }

  Future<List<StudentBrief>> _fetchStudents() async {
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

    final list = <StudentBrief>[];
    for (final s in students) {
      final studentUsername = s.toString();
      final avatar = await _fetchAvatarHex(studentUsername, token);
      list.add(StudentBrief(
        userIdOrUsername: studentUsername,
        avatarHex: avatar,
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
      barrierColor: Colors.black.withOpacity(0.15),
      pageBuilder: (_, __, ___) => const SizedBox.shrink(),
      transitionBuilder: (ctx, anim, __, ___) {
        final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 1.5, sigmaY: 1.5),
          child: Opacity(
            opacity: anim.value,
            child: Transform.scale(
              scale: 0.98 + 0.02 * curved.value,
              child: Center(
                child: RemoveConfirmDialog(
                  title: l10n.removeStudentTitle,
                  confirmText: l10n.removeConfirm,
                  cancelText: l10n.common_cancel,
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
          SnackBar(content: Text(
            '${AppLocalizations.of(context)!.removeFailed}: ${res.statusCode} ${res.body}',
          )),
        );
      }
    }
  }

  void _onAdd() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('点击了添加学生')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<StudentBrief>>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return Center(child: Text('加载失败：${snap.error}'));
        }
        final students = snap.data ?? const [];

        final itemCount = students.length + 1;

        return LayoutBuilder(
  builder: (context, constraints) {
    // 你希望单个格子的“最大宽度”（可微调）
    const double maxTileExtent = 160; // 每格最多 160px 宽
    // 至少保证 2 列，避免超窄时只有 1 列
    final int columns = (constraints.maxWidth / maxTileExtent).floor().clamp(2, 12);
    // 实际计算出来的单格宽度
    final double tileWidth = constraints.maxWidth / columns;

    // 由 tileWidth 推出头像尺寸与间距（和你之前的比例一致）
    final double avatarSize = (tileWidth * 0.38).clamp(56, 80);
    final double gap = (avatarSize * 0.10).clamp(6, 14);

    return GridView.builder(
      padding: const EdgeInsets.only(right: 8, bottom: 8),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: maxTileExtent, // 👈 关键：由它自动决定列数
        mainAxisSpacing: gap,
        crossAxisSpacing: gap,
        childAspectRatio: 0.94, // 和原来一致
      ),
      itemCount: itemCount,
      itemBuilder: (context, i) {
        if (i == students.length) {
          return AddTile(onTap: _onAdd, avatarSize: avatarSize);
        }
        final s = students[i];
        return StudentTile(
          student: s,
          onRemove: () => _remove(s.userIdOrUsername),
          avatarSize: avatarSize,
          nameWidth: (tileWidth * 0.78).toDouble(),
        );
      },
    );
  },
);

      },
    );
  }
}
