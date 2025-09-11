// lib/pages/comment_reply_detail_page.dart
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_project/models/comment_models.dart';
import 'package:flutter_project/utils/constant.dart'; // baseApiUrl
import 'package:flutter_project/widgets/comment_card.dart';
import 'package:flutter_project/widgets/composer_bar.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// 进入本页需要：所在 boardId + 被点击的“父评论”对象
class CommentReplyDetailPage extends StatefulWidget {
  final String boardId;
  final Comment parent;
  const CommentReplyDetailPage({
    super.key,
    required this.boardId,
    required this.parent,
  });

  @override
  State<CommentReplyDetailPage> createState() => _CommentReplyDetailPageState();
}

class _CommentReplyDetailPageState extends State<CommentReplyDetailPage> {
  late Future<List<Comment>> _futureReplies;
  final TextEditingController _controller = TextEditingController();
  CommentType _current = CommentType.defaultType;

  bool _isTeacher = false;
  String? _username;

  @override
  void initState() {
    super.initState();
    _readRole();
    _futureReplies = _fetchReplies();
  }

  Future<void> _readRole() async {
    final prefs = await SharedPreferences.getInstance();
    _username = prefs.getString('username') ?? '';
    final accountType = (prefs.getString('accountType') ?? '').toUpperCase();
    final role = (prefs.getString('role') ?? '').toLowerCase();
    _isTeacher = accountType == 'TEACHER' || role == 'teacher';
    if (mounted) setState(() {});
  }

  /// 拉取该 board 全部评论并筛选出 replyTo = parentId 的作为“回复”
  Future<List<Comment>> _fetchReplies() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username') ?? '';
    final token = prefs.getString('token') ?? '';

    final uri =
        Uri.parse('$baseApiUrl/comments/get-comments/${widget.boardId}');
    final res =
        await http.get(uri, headers: {'Username': username, 'Token': token});
    if (res.statusCode != 200) {
      throw Exception('加载失败：${res.statusCode} ${res.body}');
    }
    final detail = BoardDetail.fromJson(jsonDecode(res.body));
    final pid = widget.parent.commentId;
    return detail.comments.where((c) => c.replyTo == pid).toList();
  }

  /// 发表回复：replyTo = parentId
  Future<void> _postReply() async {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('请输入内容')));
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username') ?? '';
    final token = prefs.getString('token') ?? '';
    final uri =
        Uri.parse('$baseApiUrl/comments/post-comment/${widget.boardId}');

    final body = {
      "attitude": typeToWire(_current),
      "content": text,
      "timestamp": DateTime.now().toUtc().toIso8601String(),
      "replyTo": widget.parent.commentId,
    };

    final res = await http.post(
      uri,
      headers: {
        'Username': username,
        'Token': token,
        'Content-Type': 'application/json'
      },
      body: jsonEncode(body),
    );

    if (!mounted) return;

    if (res.statusCode == 200) {
      _controller.clear();

      // ✅ 关键：不要把异步放进 setState 回调里
      final next = _fetchReplies(); // 先拿到 Future
      setState(() {
        // setState 里只做同步赋值
        _futureReplies = next;
      });
      await next; // 如需，等刷新结束
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('发送失败：${res.statusCode} ${res.body}')),
      );
    }
  }

  // 谁可以删除：老师任意；学生仅限本人
  bool _canDelete(Comment c) {
    if (_isTeacher) return true;
    final u = _username ?? '';
    return u.isNotEmpty && c.username == u;
  }

// 删除评论
  Future<void> _deleteComment(Comment c) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('删除评论'),
        content: const Text('确认删除这条评论吗？此操作不可恢复。'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('取消')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('删除')),
        ],
      ),
    );
    if (ok != true) return;

    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username') ?? '';
    final token = prefs.getString('token') ?? '';

    // 如果你的后端删除路由不同，请把下面这行改成你实际的接口
    final uri = Uri.parse(
      '$baseApiUrl/comments/${widget.boardId}/delete/${c.commentId}',
    );

// 后端需要 username 和 role；保留 Token 也可以（若你网关要用）
    final roleHeader = _isTeacher ? 'teacher' : 'student';
    final res = await http.delete(
      uri,
      headers: {
        'Username': username,
        'role': roleHeader,
        'Token': token, // 如果你网关用不到也可去掉
      },
    );
    if (!mounted) return;

    if (res.statusCode == 200) {
      // 删的是父评论：直接返回上一页
      if (c.commentId == widget.parent.commentId) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('已删除该评论')));
        return;
      }
      // 否则仅刷新当前回复列表
      final next = _fetchReplies();
      setState(() {
        // ✅ 块级闭包，不返回任何值
        _futureReplies = next;
      });
      await next; // （可选）等刷新完成再提示
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('已删除')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('删除失败：${res.statusCode} ${res.body}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final parent = widget.parent;
    final parentType = wireToType(parent.attitude);

    return Scaffold(
      backgroundColor: kCanvasBrown,
      resizeToAvoidBottomInset: false,

      // === 整页一个滚动区域 + 悬浮返回按钮 ===
      body: Stack(
        children: [
          MediaQuery.removeViewInsets(
            context: context,
            removeBottom: true,
            child: SafeArea(
              top: true,
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: FutureBuilder<List<Comment>>(
                  future: _futureReplies,
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snap.hasError) {
                      return Center(
                        child: Text('加载失败：${snap.error}',
                            style: const TextStyle(color: Colors.white)),
                      );
                    }

                    final replies = snap.data ?? const <Comment>[];
                    // 统一放进一个 ListView：0=父评论，1=“回复 n”标题，2..=回复项
                    final total = replies.length + 2;

                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      itemCount: total,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          // 父评论
                          return CommentCard(
                            comment: parent,
                            type: parentType,
                            repliesCount: null,
                            showDelete: _canDelete(parent),
                            onDelete: () => _deleteComment(parent),
                          );
                        }
                        if (index == 1) {
                          // “回复 n” 标题
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const Text(
                                '回复',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(width: 6),
                              _Bubble(text: '${replies.length}'),
                            ],
                          );
                        }
                        // 回复项
                        final c = replies[index - 2];
                        final t = wireToType(c.attitude);
                        return CommentCard(
                          comment: c,
                          type: t,
                          repliesCount: null,
                          showDelete: _canDelete(c),
                          onDelete: () => _deleteComment(c),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ),

          // 悬浮返回按钮（位置不变，可点）
          Positioned(
            left: 12,
            top: 8 + MediaQuery.of(context).padding.top,
            child: SizedBox(
              width: 44,
              height: 44,
              child: Material(
                color: Colors.white,
                shape: const CircleBorder(),
                elevation: 2,
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => Navigator.pop(context),
                  child: const Center(
                    child: Icon(Icons.arrow_back, color: Colors.black),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),

      // === 底部输入栏（原样保留） ===
      bottomNavigationBar: AnimatedPadding(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        padding: EdgeInsets.only(
          bottom: () {
            final kb = MediaQuery.of(context).viewInsets.bottom;
            return kb > 0 ? math.max(0.0, kb - 8.0) : 16.0;
          }(),
        ),
        child: ComposerBar(
          current: _current,
          onChanged: (t) => setState(() => _current = t),
          onSend: _postReply,
          controller: _controller,
        ),
      ),
    );
  }
}

/// 小圆角数字气泡
class _Bubble extends StatelessWidget {
  final String text;
  const _Bubble({required this.text});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w700)),
    );
  }
}
