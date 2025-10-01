import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_project/models/comment_models.dart';
import 'package:flutter_project/utils/constant.dart'; // baseApiUrl
import 'package:flutter_project/widgets/comment_card.dart';
import 'package:flutter_project/widgets/composer_bar.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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

  // 仅用于“新增主题评论”弹层
  CommentType _newPostType = CommentType.defaultType;
  final TextEditingController _newPostController = TextEditingController();

  bool _isTeacher = false;
  String? _me;

  // 线程展开状态（父评论 id）
  final Set<String> _expandedThreads = {};
  // “在这条评论下回复”的输入框展开状态（评论 id）
  final Set<String> _openReplyBoxes = {};
  // 每条评论的内联回复输入与类型
  final Map<String, TextEditingController> _replyCtrls = {};
  final Map<String, CommentType> _replyTypes = {};

  @override
  void initState() {
    super.initState();
    _future = _fetchBoard();
    _readRole();
  }

  Future<void> _readRole() async {
    final p = await SharedPreferences.getInstance();
    final accountType = (p.getString('accountType') ?? '').toUpperCase();
    final role = (p.getString('role') ?? '').toLowerCase();
    _me = p.getString('username') ?? '';
    if (!mounted) return;
    setState(() {
      _isTeacher = accountType == 'TEACHER' || role == 'teacher';
    });
  }

  Future<BoardDetail> _fetchBoard() async {
    final p = await SharedPreferences.getInstance();
    final username = p.getString('username') ?? '';
    final token = p.getString('token') ?? '';
    final uri = Uri.parse('$baseApiUrl/comments/get-comments/${widget.boardId}');
    final res = await http.get(uri, headers: {'Username': username, 'Token': token});
    if (res.statusCode != 200) {
      if (res.statusCode == 401) throw Exception('未登录或登录已过期（401）');
      if (res.statusCode == 403) throw Exception('没有权限访问该评论板（403）');
      throw Exception('加载失败：${res.statusCode} ${res.body}');
    }
    return BoardDetail.fromJson(jsonDecode(res.body));
  }

  Future<void> _refresh() async {
    final next = _fetchBoard();   // 先拿 Future
    setState(() => _future = next); // 同步赋值
    await next;                     // setState 外 await
  }

  bool _canDelete(Comment c) => _isTeacher || ((_me ?? '').isNotEmpty && c.username == _me);

  /* ----------------  发表  ---------------- */

  // 新建“主题评论”（replyTo=null）
  Future<void> _openNewPostSheet() async {
    _newPostController.clear();
    _newPostType = CommentType.defaultType;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 12, right: 12, top: 8,
          ),
          child: Material(
            borderRadius: BorderRadius.circular(12),
            color: kCanvasBrown,
            child: ComposerBar(
              current: _newPostType,
              onChanged: (t) => _newPostType = t,
              controller: _newPostController,
              onSend: () async {
                final text = _newPostController.text.trim();
                if (text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请输入内容')));
                  return;
                }
                await _postComment(text: text, type: _newPostType, replyTo: null);
                if (!mounted) return;
                Navigator.pop(ctx);
              },
            ),
          ),
        );
      },
    );
  }

  // 在某条（父/子）评论下回复
  Future<void> _sendInlineReply({
    required String parentId, // 顶层父评论 id（线程 id）
    required String targetId, // 实际被回复的那条 id（父/子皆可）
  }) async {
    final text = _replyCtrls[targetId]?.text.trim() ?? '';
    final type = _replyTypes[targetId] ?? CommentType.defaultType;
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请输入内容')));
      return;
    }
    final p = await SharedPreferences.getInstance();
    final username = p.getString('username') ?? '';
    final token = p.getString('token') ?? '';
    final uri = Uri.parse('$baseApiUrl/comments/post-comment/${widget.boardId}');
    final body = {
      "attitude": typeToWire(type),
      "content": text,
      "timestamp": DateTime.now().toUtc().toIso8601String(),
      "replyTo": targetId,
    };
    final res = await http.post(
      uri,
      headers: {'Username': username, 'Token': token, 'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    if (res.statusCode == 200) {
      _replyCtrls[targetId]?.clear();
      setState(() {
        _openReplyBoxes.remove(targetId); // 收起本输入框
        _expandedThreads.add(parentId);   // 确保父线程展开
      });
      await _refresh();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('发送失败：${res.statusCode} ${res.body}')),
      );
    }
  }

  Future<void> _postComment({
    required String text,
    required CommentType type,
    required String? replyTo,
  }) async {
    final p = await SharedPreferences.getInstance();
    final username = p.getString('username') ?? '';
    final token = p.getString('token') ?? '';
    final uri = Uri.parse('$baseApiUrl/comments/post-comment/${widget.boardId}');
    final body = {
      "attitude": typeToWire(type),
      "content": text,
      "timestamp": DateTime.now().toUtc().toIso8601String(),
      "replyTo": replyTo,
    };

    final res = await http.post(
      uri,
      headers: {'Username': username, 'Token': token, 'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (res.statusCode == 200) {
      await _refresh();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('发送失败：${res.statusCode} ${res.body}')),
      );
    }
  }

  /* ----------------  删除  ---------------- */

  Future<void> _deleteComment(Comment c) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('删除评论'),
        content: const Text('确认删除这条评论吗？此操作不可恢复。'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('取消')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('删除')),
        ],
      ),
    );
    if (ok != true) return;

    final p = await SharedPreferences.getInstance();
    final username = _me ?? p.getString('username') ?? '';
    final token = p.getString('token') ?? '';
    final uri = Uri.parse('$baseApiUrl/comments/${widget.boardId}/delete/${c.commentId}');
    final res = await http.delete(uri, headers: {
      'Username': username,
      'role': _isTeacher ? 'teacher' : 'student',
      'Token': token,
    });

    if (res.statusCode == 200) {
      await _refresh();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('已删除')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('删除失败：${res.statusCode} ${res.body}')),
      );
    }
  }

  /* ----------------  分组（关键：按顶层父评论）  ---------------- */

  // 按“顶层父评论”的 id 分组：无论回复多少层，都归入同一父线程。
  Map<String, List<Comment>> _groupByRoot(List<Comment> all) {
    final byId = {for (final c in all) c.commentId: c};

    String? rootOf(Comment c) {
      var cur = c;
      while (cur.replyTo != null && cur.replyTo!.isNotEmpty) {
        final parent = byId[cur.replyTo!];
        if (parent == null) break;
        if (parent.replyTo == null || parent.replyTo!.isEmpty) {
          return parent.commentId; // 顶层父
        }
        cur = parent;
      }
      return null;
    }

    final map = <String, List<Comment>>{};
    for (final c in all) {
      if (c.replyTo == null || c.replyTo!.isEmpty) continue; // 跳过顶层
      final rootId = rootOf(c);
      if (rootId == null) continue;
      (map[rootId] ??= []).add(c);
    }
    for (final list in map.values) {
      // 升序：最早在前 → 折叠时显示 first
      list.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    }
    return map;
  }

  // 对该父线程内的所有“子孙评论”按时间升序，给每个作者累加编号。
  // 返回：commentId -> index（该作者在此父线程下的第几条）
  Map<String, int> _buildIndexMap(List<Comment> children) {
    final sorted = [...children]..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    final countByUser = <String, int>{};
    final indexById = <String, int>{};

    for (final c in sorted) {
      final next = (countByUser[c.username] ?? 0) + 1;
      countByUser[c.username] = next;
      indexById[c.commentId] = next;
    }
    return indexById;
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.boardTitle.isNotEmpty ? widget.boardTitle : '评论板主题';

    return Scaffold(
      backgroundColor: kCanvasBrown,
      resizeToAvoidBottomInset: false,

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        onPressed: _openNewPostSheet,
        child: const Icon(Icons.add),
      ),

      body: SafeArea(
        top: true,
        bottom: false,
        child: CustomScrollView(
          slivers: [
            // 顶部标题条
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Row(
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
                    Transform.rotate(
                      angle: -0.06,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          boxShadow: [BoxShadow(color: Color(0x33000000), blurRadius: 10, offset: Offset(0, 4))],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Text('# ', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
                          ],
                        ),
                      ),
                    ),
                    Transform.rotate(
                      angle: -0.06,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        color: Colors.white,
                        child: Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                      ),
                    ),
                    const Spacer(),
                    if (_isTeacher)
                      PopupMenuButton<String>(
                        color: Colors.white,
                        onSelected: (v) {
                          if (v == 'delete_board') _deleteBoard();
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem(value: 'delete_board', child: Text('删除评论板')),
                        ],
                      ),
                  ],
                ),
              ),
            ),

            // 内容列表
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
                            Text('加载失败：${snap.error}', style: const TextStyle(color: Colors.white)),
                            const SizedBox(height: 12),
                            FilledButton(onPressed: () async => _refresh(), child: const Text('重试')),
                          ],
                        ),
                      );
                    }

                    final all = snap.data!.comments;

                    // id -> 用户名（用于“C ▶ B”）
                    final nameById = {for (final c in all) c.commentId: c.username};

                    // 顶层父 & 线程子孙
                    final repliesByRoot = _groupByRoot(all);
                    final topLevel = all.where((c) => c.replyTo == null || c.replyTo!.isEmpty).toList();

                    if (topLevel.isEmpty) {
                      return RefreshIndicator(
                        color: Colors.black,
                        onRefresh: _refresh,
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.only(bottom: 140),
                          children: const [
                            SizedBox(height: 200),
                            Center(child: Text('还没有评论，点右下角 + 发表一条吧～', style: TextStyle(color: Colors.white))),
                          ],
                        ),
                      );
                    }

                    return RefreshIndicator(
                      color: Colors.black,
                      onRefresh: _refresh,
                      child: ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.only(bottom: 140),
                        itemCount: topLevel.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 14),
                        itemBuilder: (_, i) {
                          final parent = topLevel[i];
                          final children = repliesByRoot[parent.commentId] ?? const <Comment>[];
                          final expanded = _expandedThreads.contains(parent.commentId);

                          // 折叠时显示“最早一条”
                          final hasPreview = children.isNotEmpty;
                          final preview = hasPreview ? children.first : null;
                          final hidden = children.length > 1 ? (children.length - 1) : 0;

                          // 计算该父线程下每条评论的“作者序号”
                          final indexOf = _buildIndexMap(children);

                          final color = kTypeColor[wireToType(parent.attitude)]!;

                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: color, width: 2),
                              boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 10, offset: Offset(0, 4))],
                            ),
                            padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // 父评论
                                CommentCard(
                                  comment: parent,
                                  type: wireToType(parent.attitude),
                                  repliesCount: children.length,
                                  showDelete: _canDelete(parent),
                                  onDelete: () => _deleteComment(parent),
                                  actionsInline: true,
                                  // 父评论不显示路径/序号
                                  replyToUsername: null,
                                  fromIndex: null,
                                  toIndex: null,
                                  onReply: () => setState(() => _openReplyBoxes.toggle(parent.commentId)),
                                  replyOpened: _openReplyBoxes.contains(parent.commentId),
                                ),
                                if (_openReplyBoxes.contains(parent.commentId))
                                  _InlineReply(
                                    color: kTypeColor[_replyTypes[parent.commentId] ?? CommentType.defaultType]!,
                                    controller: _replyCtrls[parent.commentId] ??= TextEditingController(),
                                    current: _replyTypes[parent.commentId] ??= CommentType.defaultType,
                                    onTypeChanged: (t) => setState(() => _replyTypes[parent.commentId] = t),
                                    onSend: () => _sendInlineReply(
                                      parentId: parent.commentId,
                                      targetId: parent.commentId,
                                    ),
                                  ),

                                const SizedBox(height: 8),

                                // 折叠态：仅 1 条预览（最早）
                                if (!expanded && preview != null) ...[
                                  CommentCard(
                                    comment: preview,
                                    type: wireToType(preview.attitude),
                                    showDelete: _canDelete(preview),
                                    onDelete: () => _deleteComment(preview),
                                    actionsInline: true,
                                    replyToUsername: (preview.replyTo == parent.commentId) ? null : nameById[preview.replyTo],
                                    fromIndex: indexOf[preview.commentId],
                                    toIndex: (preview.replyTo == parent.commentId) ? null : indexOf[preview.replyTo],
                                    onReply: () => setState(() => _openReplyBoxes.toggle(preview.commentId)),
                                    replyOpened: _openReplyBoxes.contains(preview.commentId),
                                  ),
                                  if (_openReplyBoxes.contains(preview.commentId))
                                    _InlineReply(
                                      color: kTypeColor[_replyTypes[preview.commentId] ?? CommentType.defaultType]!,
                                      controller: _replyCtrls[preview.commentId] ??= TextEditingController(),
                                      current: _replyTypes[preview.commentId] ??= CommentType.defaultType,
                                      onTypeChanged: (t) => setState(() => _replyTypes[preview.commentId] = t),
                                      onSend: () => _sendInlineReply(
                                        parentId: parent.commentId,   // 线程 id
                                        targetId: preview.commentId,  // 被回复的那条
                                      ),
                                    ),
                                  const SizedBox(height: 6),
                                ],

                                // 展开/折叠按钮（显示折叠数量）
                                if (children.isNotEmpty)
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: TextButton.icon(
                                      style: TextButton.styleFrom(foregroundColor: Colors.black87),
                                      onPressed: () {
                                        setState(() {
                                          expanded
                                              ? _expandedThreads.remove(parent.commentId)
                                              : _expandedThreads.add(parent.commentId);
                                        });
                                      },
                                      icon: Icon(expanded ? Icons.expand_less : Icons.expand_more),
                                      label: Text(
                                        expanded
                                            ? '收起 ${hidden > 0 ? hidden : children.length} 条回复'
                                            : (hidden > 0 ? '展开其余 $hidden 条回复' : '展开 1 条回复'),
                                      ),
                                    ),
                                  ),

                                // 展开态：所有子评论
                                if (expanded) ...[
                                  ...children.map((c) {
                                    return Padding(
                                      padding: const EdgeInsets.only(left: 0.0, bottom: 6),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                        children: [
                                          CommentCard(
                                            comment: c,
                                            type: wireToType(c.attitude),
                                            repliesCount: null,
                                            showDelete: _canDelete(c),
                                            onDelete: () => _deleteComment(c),
                                            actionsInline: true,
                                            replyToUsername: (c.replyTo == parent.commentId) ? null : nameById[c.replyTo],
                                            fromIndex: indexOf[c.commentId],
                                            toIndex: (c.replyTo == parent.commentId) ? null : indexOf[c.replyTo],
                                            onReply: () => setState(() => _openReplyBoxes.toggle(c.commentId)),
                                            replyOpened: _openReplyBoxes.contains(c.commentId),
                                          ),
                                          if (_openReplyBoxes.contains(c.commentId))
                                            _InlineReply(
                                              color: kTypeColor[_replyTypes[c.commentId] ?? CommentType.defaultType]!,
                                              controller: _replyCtrls[c.commentId] ??= TextEditingController(),
                                              current: _replyTypes[c.commentId] ??= CommentType.defaultType,
                                              onTypeChanged: (t) => setState(() => _replyTypes[c.commentId] = t),
                                              onSend: () => _sendInlineReply(
                                                parentId: parent.commentId,
                                                targetId: c.commentId,
                                              ),
                                            ),
                                        ],
                                      ),
                                    );
                                  }),
                                ],
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
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
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('取消')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('删除')),
        ],
      ),
    );
    if (ok != true) return;

    final p = await SharedPreferences.getInstance();
    final username = p.getString('username') ?? '';
    final token = p.getString('token') ?? '';
    final uri = Uri.parse('$baseApiUrl/comments/board/${widget.boardId}');
    final res = await http.delete(uri, headers: {'Username': username, 'Token': token});
    if (!mounted) return;

    if (res.statusCode == 200) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('评论板已删除')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('删除失败：${res.statusCode} ${res.body}')),
      );
    }
  }
}
/// 内联小回复输入框（贴设计紧凑风格）
/// 放在 comment_board_detail_page.dart 文件底部，和 _ActionsRow/_ReplyCrumb 同级（类外）
class _InlineReply extends StatelessWidget {
  final Color color;
  final TextEditingController controller;
  final CommentType current;
  final ValueChanged<CommentType> onTypeChanged;
  final VoidCallback onSend;

  const _InlineReply({
    required this.color,
    required this.controller,
    required this.current,
    required this.onTypeChanged,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, right: 0, top: 2),
      child: Row(
        children: [
          // 选择类型
          PopupMenuButton<CommentType>(
            tooltip: '选择类型',
            icon: Icon(Icons.label_important_outline, color: color),
            onSelected: onTypeChanged,
            itemBuilder: (_) => CommentType.values.map((t) {
              return PopupMenuItem(
                value: t,
                child: Row(
                  children: [
                    Container(
                      width: 10, height: 10,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: kTypeColor[t]!,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Text(typeLabel(t)),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(width: 6),

          // 文本框
          Expanded(
            child: Container(
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: StadiumBorder(side: BorderSide(color: color, width: 2)),
                shadows: const [
                  BoxShadow(color: Color(0x22000000), blurRadius: 6, offset: Offset(0, 3)),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 3,
                decoration: const InputDecoration(
                  isDense: true,
                  hintText: '回复…',
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // 发送
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              minimumSize: const Size(0, 40),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              textStyle: const TextStyle(fontSize: 13),
            ),
            onPressed: onSend,
            child: const Text('发送'),
          ),
        ],
      ),
    );
  }
}


/* ================= 小扩展：Set 的 toggle ================= */
extension on Set<String> {
  void toggle(String id) => contains(id) ? remove(id) : add(id);
}
