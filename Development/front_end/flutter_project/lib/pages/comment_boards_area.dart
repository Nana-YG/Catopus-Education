import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_project/pages/comment_board_detail_page.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_project/utils/constant.dart'; // baseApiUrl

class CommentBoardsArea extends StatefulWidget {
  final String classId;
  final String title;
  final bool outerControlsHorizontal; // 👈 新增

  const CommentBoardsArea({
    super.key,
    required this.classId,
    required this.title,
    this.outerControlsHorizontal = false,
  });

  @override
  State<CommentBoardsArea> createState() => _CommentBoardsAreaState();
}

class _CommentBoardsAreaState extends State<CommentBoardsArea> {
  late Future<List<_BoardBrief>> _future;
  bool _isTeacher = false;
  String? _lastError;
  final Map<String, Future<List<_CommentPreview>>> _peekCache = {}; // 👈 新增
  Future<List<_CommentPreview>> _fetchPeek(String boardId) {
    // 有缓存直接复用
    if (_peekCache[boardId] != null) return _peekCache[boardId]!;

    final fut = _doFetchPeek(boardId);
    _peekCache[boardId] = fut;
    return fut;
  }

  Future<List<_CommentPreview>> _doFetchPeek(String boardId) async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username') ?? '';
    final token = prefs.getString('token') ?? '';

    final uri = Uri.parse('$baseApiUrl/comments/get-comments/$boardId');
    final res =
        await http.get(uri, headers: {'Username': username, 'Token': token});

    if (res.statusCode != 200) {
      debugPrint('peek failed: $boardId -> ${res.statusCode} ${res.body}');
      return const [];
    }
    final map = jsonDecode(res.body) as Map<String, dynamic>;
    final List list = (map['comments'] as List? ?? []);
    // 仅取前 4 条，按时间新→旧（后端如已排序可省略）
    final previews = list.take(4).map((e) {
      final m = e as Map<String, dynamic>;
      return _CommentPreview(
        commentId: m['commentId'] ?? '',
        content: (m['content'] ?? '').toString(),
      );
    }).toList();
    return previews;
  }

  @override
  void initState() {
    super.initState();
    _readRole();
    _future = _fetchBoards();
  }

  Future<void> _readRole() async {
    final prefs = await SharedPreferences.getInstance();
    // 优先使用后端返回并在登录时保存的 accountType（TEACHER / STUDENT）
    final accountType = (prefs.getString('accountType') ?? '').toUpperCase();
    // 兜底使用 role（teacher / student）
    final role = (prefs.getString('role') ?? '').toLowerCase();

    final isTeacher = accountType == 'TEACHER' || role == 'teacher';
    setState(() => _isTeacher = isTeacher);
  }

  Future<List<_BoardBrief>> _fetchBoards() async {
    debugPrint('CommentBoards - fetchBoards classId = ${widget.classId}');
    _lastError = null;

    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username') ?? '';
    final token = prefs.getString('token') ?? '';

    final uri = Uri.parse('$baseApiUrl/comments/boards/${widget.classId}');
    final res = await http.get(
      uri,
      headers: {
        'Username': username,
        'Token': token,
      },
    );

    if (res.statusCode != 200) {
      _lastError = '加载评论板失败：${res.statusCode} ${res.body}';
      throw Exception(_lastError);
    }

    final List data = jsonDecode(res.body);
    return data
        .map((e) => _BoardBrief(
              boardId: e['boardId'] as String,
              title: (e['title'] as String?) ?? '',
            ))
        .toList();
  }

  Future<void> _createBoard() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username') ?? '';
    final token = prefs.getString('token') ?? '';
    final controller = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('新建评论板'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: '请输入主题标题'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('创建'),
          ),
        ],
      ),
    );

    if (ok != true) return;

    final title = controller.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('标题不能为空')));
      return;
    }

    final uri = Uri.parse(
      '$baseApiUrl/comments/newboard/${widget.classId}?title=${Uri.encodeQueryComponent(title)}',
    );

    final res = await http.post(
      uri,
      headers: {
        'Username': username,
        'Token': token,
      },
    );

    if (res.statusCode == 200) {
      // 刷新列表
      setState(() {
        _future = _fetchBoards();
      });
      // 额外体验：轻微提示
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('创建成功')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('创建失败：${res.statusCode} ${res.body}')),
      );
    }
  }

  Future<void> _deleteBoard(String boardId) async {
    if (!_isTeacher) return;
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username') ?? '';
    final token = prefs.getString('token') ?? '';

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('删除评论板'),
        content: const Text('确定要删除这个评论板吗？此操作不可恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (ok != true) return;

    // 按你的接口说明：Delete a Board (Teacher) DELETE /board/{boardId}
    // 你的其它接口都在 /comments 下，这里我们也加上 /comments 前缀
    final uri = Uri.parse('$baseApiUrl/comments/board/$boardId');

    final res = await http.delete(
      uri,
      headers: {
        'Username': username,
        'Token': token,
      },
    );

    if (res.statusCode == 200) {
      setState(() {
        _future = _fetchBoards();
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('已删除')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('删除失败：${res.statusCode} ${res.body}')),
      );
    }
  }

  void _openBoard(_BoardBrief board) {
    // 跳转到评论板详情页
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CommentBoardDetailPage(
          boardId: board.boardId,
          boardTitle: board.title,
        ),
      ),
    );
  }

  Future<void> _onPullRefresh() async {
    setState(() => _future = _fetchBoards());
    await _future; // 等待刷新结束再收起指示器
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 列表
            Expanded(
              child: FutureBuilder<List<_BoardBrief>>(
                future: _future,
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snap.hasError) {
                    return _ErrorView(
                      message: _lastError ?? '加载失败',
                      onRetry: () => setState(() => _future = _fetchBoards()),
                    );
                  }
                  final boards = snap.data ?? const [];
                  if (boards.isEmpty) {
                    return const Center(child: Text('还没有评论板'));
                  }

                  return RefreshIndicator(
                    onRefresh: _onPullRefresh,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        // 根据高度自适应评论板尺寸
                        final h = constraints.maxHeight.clamp(360.0, 720.0);
                        final boardHeight = (h * 0.8).clamp(420.0, 560.0);
                        // 按你 PNG 比例大约 3:4 来计算宽度
                        final boardWidth = boardHeight * 0.75;

                        return ListView.separated(
                          key: const PageStorageKey('boards-h-scroll'),
                          physics: const AlwaysScrollableScrollPhysics(),
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          itemCount: boards.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 16),
                          itemBuilder: (_, i) {
                            final b = boards[i];
                            return GestureDetector(
                              onTap: () => _openBoard(b),
                              onLongPress: _isTeacher
                                  ? () => _deleteBoard(b.boardId)
                                  : null,
                              child: _BoardCardWithPeek(
                                width: boardWidth,
                                height: boardHeight,
                                title: b.title,
                                loadPeek: () =>
                                    _fetchPeek(b.boardId), // 👈 用来加载评论预览
                              ),
                            );
                          },
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),

        // 仅老师显示“+”
        if (_isTeacher)
          Positioned(
            right: 16,
            bottom: 16,
            child: FloatingActionButton(
              onPressed: _createBoard,
              child: const Icon(Icons.add),
            ),
          ),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          FilledButton(onPressed: onRetry, child: const Text('重试')),
        ],
      ),
    );
  }
}

class _BoardBrief {
  final String boardId;
  final String title;
  _BoardBrief({required this.boardId, required this.title});
}

class _BoardCardWithPeek extends StatelessWidget {
  final double width;
  final double height;
  final String title;
  final Future<List<_CommentPreview>> Function() loadPeek;

  const _BoardCardWithPeek({
    required this.width,
    required this.height,
    required this.title,
    required this.loadPeek,
  });

  @override
  Widget build(BuildContext context) {
    final titleTop = height * 0.13;
    final titleLeft = width * 0.13;

    return Stack(
      children: [
        // 背景 PNG
        Image.asset(
          'assets/images/board.png',
          width: width,
          height: height,
          fit: BoxFit.contain,
        ),

        // 标题（白色纸条，可多行）
        Positioned(
          top: titleTop,
          left: titleLeft,
          child: Transform.rotate(
            angle: -0.09,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: width * 0.25,
                maxWidth: width * 0.75,
              ),
              child: IntrinsicWidth(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: width * 0.04,
                    vertical: width * 0.025,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x33000000),
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    softWrap: true,
                    style: TextStyle(
                      fontSize: (width * 0.075).clamp(16.0, 24.0),
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                      height: 1.15,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        // 评论预览：右侧竖排白色标签（正放，不倾斜）
        Positioned(
          // 放在板子右侧中部区域；可按需微调
          top: height * 0.30,
          left: width * 0.15,
          child: SizedBox(
            width: width * 0.7, // 标签列宽度
            height: height * 0.55,
            child: FutureBuilder<List<_CommentPreview>>(
              future: loadPeek(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  );
                }
                final items = snap.data ?? const [];
                if (items.isEmpty) {
                  return const SizedBox(); // 没评论就不占位
                }
                // 固定最多展示 3~4 个小标签；每个标签固定高，内容溢出省略
                return ListView.separated(
                  physics: const NeverScrollableScrollPhysics(), // 卡片内不滚动，整页横向滚
                  shrinkWrap: true,
                  itemCount: items.length.clamp(0, 4),
                  separatorBuilder: (_, __) => SizedBox(height: height * 0.02),
                  itemBuilder: (_, i) {
                    final it = items[i];
                    return _CommentTag(
                      text: it.content,
                      // 大小随卡片适配
                      maxWidth: width * 0.38,
                      minHeight: height * 0.13,
                      maxLines: 2, // 最多 2 行
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _CommentTag extends StatelessWidget {
  final String text;
  final double maxWidth;
  final double minHeight;
  final int maxLines;

  const _CommentTag({
    required this.text,
    required this.maxWidth,
    required this.minHeight,
    this.maxLines = 2,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: minHeight, maxWidth: maxWidth),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(0), // 直角可改为 0
          border: Border.all(color: const Color(0xFFCCCCCC), width: 1.5),
          boxShadow: const [
            BoxShadow(
              color: Color(0x22000000),
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Text(
          text,
          maxLines: maxLines,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 13,
            height: 1.25,
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

/// 只用于列表预览的精简模型
class _CommentPreview {
  final String commentId;
  final String content;
  _CommentPreview({required this.commentId, required this.content});
}
