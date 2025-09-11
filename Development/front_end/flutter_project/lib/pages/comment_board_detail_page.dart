import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_project/models/comment_models.dart';
import 'package:flutter_project/pages/comment_reply_detail_page.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math' as math;

import 'package:flutter_project/utils/constant.dart'; // baseApiUrl
import 'package:flutter_project/widgets/comment_card.dart';
import 'package:flutter_project/widgets/composer_bar.dart';

class CommentBoardDetailPage extends StatefulWidget {
  final String boardId;
  final String boardTitle;

  const CommentBoardDetailPage({
    super.key,
    required this.boardId,
    required this.boardTitle,
  });

  @override
  State<CommentBoardDetailPage> createState() => _CommentBoardDetailPageState();
}

class _CommentBoardDetailPageState extends State<CommentBoardDetailPage> {
  late Future<BoardDetail> _future;
  CommentType _current = CommentType.defaultType;
  final TextEditingController _controller = TextEditingController();

  bool _isTeacher = false;

  @override
  void initState() {
    super.initState();
    _future = _fetchBoard(); // 立即初始化，避免 late 报错
    _readRole().then((_) {
      if (mounted) setState(() {});
    });
  }

  /* ===== 鉴权信息 ===== */
  Future<void> _readRole() async {
    final prefs = await SharedPreferences.getInstance();
    final accountType = (prefs.getString('accountType') ?? '').toUpperCase();
    final role = (prefs.getString('role') ?? '').toLowerCase();

    // 👇 缓存当前登录用户名，供 _canDelete 使用
    _cachedUsername = prefs.getString('username') ?? '';

    // 计算教师身份
    final isTeacher = accountType == 'TEACHER' || role == 'teacher';

    if (mounted) {
      setState(() {
        _isTeacher = isTeacher;
      });
    }
  }

  /* ===== 拉取详情 ===== */
  Future<BoardDetail> _fetchBoard() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username') ?? '';
    final token = prefs.getString('token') ?? '';

    final uri =
        Uri.parse('$baseApiUrl/comments/get-comments/${widget.boardId}');
    final res =
        await http.get(uri, headers: {'Username': username, 'Token': token});

    if (res.statusCode != 200) {
      if (res.statusCode == 401) throw Exception('未登录或登录已过期（401）');
      if (res.statusCode == 403) throw Exception('没有权限访问该评论板（403）');
      throw Exception('加载失败：${res.statusCode} ${res.body}');
    }
    return BoardDetail.fromJson(jsonDecode(res.body));
  }

  /* ===== 发送评论（不带 replyTo） ===== */
  Future<void> _postComment() async {
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
      "replyTo": null, // 本页不做“回复某条”，固定 null
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
      final next = _fetchBoard();
      setState(() {
        _current = CommentType.defaultType;
        _future = next;
      });
      await next;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('发送失败：${res.statusCode} ${res.body}')),
      );
    }
  }

  /* ===== 工具 ===== */
  void _retry() {
    setState(() {
      _future = _fetchBoard();
    });
  }

  Future<void> _onPullRefresh() async {
    final next = _fetchBoard();
    setState(() {
      _future = next;
    });
    await next;
  }

  // 统计每条评论的回复数：replyTo == 该 commentId
  Map<String, int> _countReplies(List<Comment> list) {
    final map = <String, int>{};
    for (final c in list) {
      final parent = c.replyTo;
      if (parent == null || parent.isEmpty) continue;
      map[parent] = (map[parent] ?? 0) + 1;
    }
    return map;
  }

  // 谁可以删除：老师任意；学生仅限本人
  bool _canDelete(Comment c) {
    if (_isTeacher) return true;
    final me = _cachedUsername ?? '';
    return me.isNotEmpty && c.username == me;
  }

// 可选：把 username 缓存一下，避免每次读 SharedPreferences
  String? _cachedUsername;
  Future<void> _ensureUsername() async {
    if (_cachedUsername != null) return;
    final prefs = await SharedPreferences.getInstance();
    _cachedUsername = prefs.getString('username') ?? '';
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

    await _ensureUsername();
    final prefs = await SharedPreferences.getInstance();
    final username = _cachedUsername ?? '';
    final token = prefs.getString('token') ?? '';

    final uri = Uri.parse(
        '$baseApiUrl/comments/${widget.boardId}/delete/${c.commentId}');
    final res = await http.delete(
      uri,
      headers: {
        'Username': username,
        'role': _isTeacher ? 'teacher' : 'student',
        'Token': token, // 若网关不用可去掉
      },
    );

    if (!mounted) return;

    if (res.statusCode == 200) {
      // 直接刷新本页评论列表
      // ✅ 回调不返回值
      final next = _fetchBoard();
      setState(() {
        _future = next;
      });
      await next;

      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('已删除')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('删除失败：${res.statusCode} ${res.body}')),
      );
    }
  }

  /* ===== UI ===== */
  @override
  Widget build(BuildContext context) {
    final title = widget.boardTitle.isNotEmpty ? widget.boardTitle : '评论板主题';

    return Scaffold(
      backgroundColor: kCanvasBrown,

      // 让 body 不跟随键盘缩放；输入区我们自己用 AnimatedPadding 处理
      resizeToAvoidBottomInset: false,

      // 去掉 body 的 bottom inset，避免键盘再影响 body 尺寸
      body: MediaQuery.removeViewInsets(
        context: context,
        removeBottom: true,
        child: SafeArea(
          top: true,
          bottom: false,
          child: CustomScrollView(
            // 让列表在键盘出现时仍可滚到顶部标题，避免挤爆
            slivers: [
              // ===== 顶部栏（白色纸张标题）=====
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Material(
                        color: Colors.white,
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () => Navigator.pop(context),
                          child: const Padding(
                            padding: EdgeInsets.all(10),
                            child: Icon(Icons.arrow_back, color: Colors.black),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Transform.rotate(
                          angle: -0.06,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                    color: Color(0x33000000),
                                    blurRadius: 10,
                                    offset: Offset(0, 4))
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('# ',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 20)),
                                Flexible(
                                  child: Text(
                                    title,
                                    style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.black),
                                    softWrap: true,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (_isTeacher)
                        PopupMenuButton<String>(
                          color: Colors.white,
                          onSelected: (v) {
                            if (v == 'delete_board') _deleteBoard();
                          },
                          itemBuilder: (_) => const [
                            PopupMenuItem(
                                value: 'delete_board', child: Text('删除评论板')),
                          ],
                        ),
                    ],
                  ),
                ),
              ),

              // ===== 列表区域（会占据“剩余空间”，不足也不溢出）=====
              SliverFillRemaining(
                hasScrollBody: true,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: FutureBuilder<BoardDetail>(
                    future: _future,
                    builder: (context, snap) {
                      if (snap.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snap.hasError) {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('加载失败：${snap.error}',
                                  style: const TextStyle(color: Colors.white)),
                              const SizedBox(height: 12),
                              FilledButton(
                                  onPressed: _retry, child: const Text('重试')),
                            ],
                          ),
                        );
                      }

                      final data = snap.data!;
                      final all = data.comments;

// 1) 统计各顶层评论的回复数（保持你原来的实现也可以）
                      final repliesMap = _countReplies(all);

// 2) 只保留“顶层评论”（replyTo 为空或 null）
                      final topLevel = all
                          .where((c) => c.replyTo == null || c.replyTo!.isEmpty)
                          .toList();

// 3) 用顶层评论渲染列表
                      if (topLevel.isEmpty) {
                        return ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.only(bottom: 80),
                          children: const [
                            SizedBox(height: 200),
                            Center(
                                child: Text('还没有评论，来发一条吧～',
                                    style: TextStyle(color: Colors.white))),
                          ],
                        );
                      }

                      return ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.only(bottom: 80),
                        itemCount: topLevel.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (_, i) {
                          final c = topLevel[i]; // ✅ 注意这里改成用 topLevel
                          final t = wireToType(c.attitude);
                          final count = repliesMap[c.commentId] ?? 0;

                          return InkWell(
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => CommentReplyDetailPage(
                                    boardId: widget.boardId,
                                    parent: c,
                                  ),
                                ),
                              );
                              setState(() {
                                _future = _fetchBoard();
                              });
                            },
                            child: CommentCard(
                              comment: c,
                              type: t,
                              repliesCount: count,
                              showDelete: _canDelete(c),
                              onDelete: () => _deleteComment(c),
                              actionsInline: true, // ✅ 列表页需要“并排在右下角”
                            ),
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

      // ===== 底部输入栏：跟随键盘上移 =====
      bottomNavigationBar: AnimatedPadding(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        padding: EdgeInsets.only(
          bottom: () {
            final kb = MediaQuery.of(context).viewInsets.bottom;
            if (kb > 0) {
              return math.max(0.0, kb - 8.0); // 键盘时，贴紧但保留 8px
            } else {
              return 16.0; // 没键盘时留 16px 空隙
            }
          }(),
        ),
        child: ComposerBar(
          current: _current,
          onChanged: (t) => setState(() => _current = t),
          onSend: _postComment,
          controller: _controller,
        ),
      ),
    );
  }

  Future<void> _deleteBoard() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('删除评论板'),
        content: const Text('此操作不可恢复，确认删除该评论板吗？'),
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

    final uri = Uri.parse('$baseApiUrl/comments/board/${widget.boardId}');
    final res =
        await http.delete(uri, headers: {'Username': username, 'Token': token});

    if (!mounted) return;

    if (res.statusCode == 200) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('评论板已删除')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('删除失败：${res.statusCode} ${res.body}')),
      );
    }
  }
}
