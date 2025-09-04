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

  @override
  Widget build(BuildContext context) {
    final parent = widget.parent;
    final parentType = wireToType(parent.attitude);

    return Scaffold(
      backgroundColor: kCanvasBrown,
      resizeToAvoidBottomInset: false,

      body: Stack(
  children: [
    // === 主体内容 ===
    MediaQuery.removeViewInsets(
      context: context,
      removeBottom: true,
      child: SafeArea(
        top: true,
        bottom: false,
        child: CustomScrollView(
          slivers: [
            // 父评论卡片（与回复列表对齐）
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: CommentCard(
                  comment: parent,
                  type: parentType,
                  repliesCount: null, // 顶部不显示“Replies”
                ),
              ),
            ),

            // “回复 n”
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
                child: Row(
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
                    FutureBuilder<List<Comment>>(
                      future: _futureReplies,
                      builder: (_, snap) {
                        final n = snap.hasData ? snap.data!.length : 0;
                        return _Bubble(text: '$n');
                      },
                    ),
                  ],
                ),
              ),
            ),

            // 回复列表
            SliverFillRemaining(
              hasScrollBody: true,
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
                        child: Text(
                          '加载失败：${snap.error}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    }
                    final list = snap.data ?? const <Comment>[];
                    if (list.isEmpty) {
                      return ListView(
                        padding: const EdgeInsets.only(bottom: 80),
                        children: const [
                          SizedBox(height: 160),
                          Center(
                            child: Text(
                              '还没有回复，来发表一个吧～',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.only(bottom: 80),
                      itemCount: list.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (_, i) {
                        final c = list[i];
                        final t = wireToType(c.attitude);
                        return CommentCard(
                          comment: c,
                          type: t,
                          repliesCount: null, // 回复页不展示“回复数”
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    ),

    // === 悬浮返回按钮 ===
    Positioned(
      left: 12,
      top: 8 + MediaQuery.of(context).padding.top, // 避开状态栏
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


      // 底部输入：随键盘上移
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
