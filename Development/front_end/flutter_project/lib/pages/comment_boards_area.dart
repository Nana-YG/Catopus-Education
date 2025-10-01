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

    // ✅ 只保留顶层评论（不是回复）
    final topLevel = list.where((e) {
      final m = e as Map<String, dynamic>;
      final r = m['replyTo'];
      return r == null || (r is String && r.isEmpty);
    }).toList();

    // ✅ 按时间倒序（如果后端未排序）
    topLevel.sort((a, b) {
      final ta = DateTime.tryParse((a['timestamp'] ?? '').toString()) ??
          DateTime.fromMillisecondsSinceEpoch(0);
      final tb = DateTime.tryParse((b['timestamp'] ?? '').toString()) ??
          DateTime.fromMillisecondsSinceEpoch(0);
      return tb.compareTo(ta); // 新在前
    });

    // 只预览前 4 条
    return topLevel.take(4).map((e) {
      final m = e as Map<String, dynamic>;
      return _CommentPreview(
        commentId: m['commentId'] ?? '',
        content: (m['content'] ?? '').toString(),
      );
    }).toList();
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

  void _openBoard(_BoardBrief board) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CommentBoardDetailPage(
          boardId: board.boardId,
          boardTitle: board.title,
        ),
      ),
    );

    // 回来后刷新：清除该板子的预览缓存 + 重新拉列表
    setState(() {
      _peekCache.remove(board.boardId); // 让预览重拉
      _future = _fetchBoards(); // 刷新板子列表
    });
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

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final availableH = constraints.maxHeight;
                      final availableW = constraints.maxWidth;

                      // 1) 统一的最小/最大值（别太高，窄屏才不炸）
                      const double minBoardHeight = 260.0;
                      const double maxBoardHeight = 640.0;
                      const double minBoardWidth =
                          180.0; // 原来 280 太大，窄屏容易 upper<lower

                      // 2) 先算高度，再由 3:4 比例推宽度
                      final double boardHeight = (availableH * 1)
                          .clamp(minBoardHeight, maxBoardHeight);

                      // 3) 计算当前视口允许的“最大宽度上界”，并确保 >= 下界
                      //    注意把左右 padding / 分隔大概预留掉一些，避免过度估计
                      final double viewportMaxWidth =
                          (availableW * 0.72); // 可按需调 0.6~0.8
                      final double safeUpperWidth =
                          viewportMaxWidth < minBoardWidth
                              ? minBoardWidth
                              : viewportMaxWidth;

                      // 4) 由高度得到的理想宽度，再做安全 clamp
                      final double idealWidth = boardHeight * 0.75;
                      final double boardWidth =
                          idealWidth.clamp(minBoardWidth, safeUpperWidth);

                      return ListView.separated(
                        key: const PageStorageKey('boards-h-scroll'),
                        scrollDirection: Axis.horizontal,
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        itemCount: boards.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (_, i) {
                          final b = boards[i];

// 基于 boardId 稳定“随机”选择 1 或 2
                          final bgAsset = (b.boardId.hashCode & 1) == 0
                              ? 'assets/images/board1.png'
                              : 'assets/images/board2.png';
                          return SizedBox(
                            height: availableH,
                            width: boardWidth,
                            child: Center(
                              child: GestureDetector(
                                onTap: () => _openBoard(b),
                                onLongPress: _isTeacher
                                    ? () => _deleteBoard(b.boardId)
                                    : null,
                                child: _BoardCardWithPeek(
                                  width: boardWidth,
                                  height: boardHeight,
                                  title: b.title,
                                  loadPeek: () => _fetchPeek(b.boardId),
                                  bgAsset: bgAsset, // 👈 传入
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
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
  final String bgAsset;

  const _BoardCardWithPeek({
    required this.width,
    required this.height,
    required this.title,
    required this.loadPeek,
    required this.bgAsset,
  });

  @override
  Widget build(BuildContext context) {
    // 以一个“设计基准宽度”来算比例，520 是我选的基准，可以按你图片比例稍微调
    const double baseW = 400;
    final double s = (width / baseW).clamp(0.65, 1.8); // 放宽缩放上限，板子变大时更跟手

    final double titleTop = height * 0.13;
    final double titleLeft = width * 0.13;

// ===== 新增：根据板子大小推导“预览区”和“单卡尺寸/间距/可见数量” =====
    final double peekAreaTop = height * 0.30;
    final double peekAreaLeft = width * 0.15;
    final double peekAreaWidth = width * 0.70;
    final double peekAreaHeight = height * 0.55;

// 单卡最小高度随缩放，给个上下限
    final double tagMinHeight = (60 * s).clamp(50, 160);
// 卡片之间的垂直间隔
    final double tagSpacing = (12 * s).clamp(8, 20);

// 允许的最大可见数量（根据“可用高度 / (卡高 + 间隔)”来算）
    final int maxVisibleBySpace =
        (peekAreaHeight / (tagMinHeight + tagSpacing)).floor().clamp(1, 8);

// 宽度稍微窄一点避免溢出
    final double tagMaxWidth = width * 0.46;

// 根据板子大小决定每条最多显示几行：板子大就多一行
    final int tagMaxLines = s >= 1.15 ? 4 : 2;

// 字号也跟随缩放
    final double tagFontSize = (14 * s).clamp(11, 20);

    return Stack(
      children: [
        Image.asset(
          bgAsset,
          width: width,
          height: height,
          fit: BoxFit.contain,
        ),

        // 顶部白色“标题纸条”——字号/内边距跟随 s
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
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 18 * s, // 原来用 width 比例会在极端宽度时跳；用 s 更稳
                  vertical: 12 * s,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0x33000000),
                      blurRadius: 8 * s,
                      offset: Offset(0, 3 * s),
                    ),
                  ],
                ),
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  softWrap: true,
                  style: TextStyle(
                    fontSize: (22 * s).clamp(12, 36), // ← 随宽度变化
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                    height: 1.12,
                  ),
                ),
              ),
            ),
          ),
        ),

        // 右侧三条“评论预览便签”——字号/边框/边距全用 s 驱动
        Positioned(
          top: peekAreaTop,
          left: peekAreaLeft,
          child: SizedBox(
            width: peekAreaWidth,
            height: peekAreaHeight,
            child: FutureBuilder<List<_CommentPreview>>(
              future: loadPeek(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return SizedBox(
                    width: 24 * s,
                    height: 24 * s,
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  );
                }
                final items = snap.data ?? const [];
                if (items.isEmpty) return const SizedBox();

                // ✅ 数量随“可用高度”变化
                final int itemCount = items.length.clamp(0, maxVisibleBySpace);

                return ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: itemCount,
                  separatorBuilder: (_, __) => SizedBox(height: tagSpacing),
                  itemBuilder: (_, i) {
                    final it = items[i];
                    return _CommentTag(
                      text: it.content,
                      maxWidth: tagMaxWidth,
                      minHeight: tagMinHeight,
                      maxLines: tagMaxLines,
                      fontSize: tagFontSize,
                      padding: EdgeInsets.symmetric(
                        horizontal: 12 * s,
                        vertical: 8 * s,
                      ),
                      borderWidth: (1.5 * s).clamp(1, 2),
                      shadowBlur: 6 * s,
                      shadowDy: 3 * s,
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

  // 新增：可控的缩放参数
  final double? fontSize;
  final EdgeInsets? padding;
  final double? borderWidth;
  final double? shadowBlur;
  final double? shadowDy;

  const _CommentTag({
    required this.text,
    required this.maxWidth,
    required this.minHeight,
    this.maxLines = 2,
    this.fontSize,
    this.padding,
    this.borderWidth,
    this.shadowBlur,
    this.shadowDy,
  });

  @override
  Widget build(BuildContext context) {
    final double bw = borderWidth ?? 1.5;
    final double sb = shadowBlur ?? 6;
    final double sd = shadowDy ?? 3;

    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: minHeight, maxWidth: maxWidth),
      child: Container(
        padding:
            padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(0),
          border: Border.all(color: const Color(0xFFCCCCCC), width: bw),
          boxShadow: [
            BoxShadow(
              color: const Color(0x22000000),
              blurRadius: sb,
              offset: Offset(0, sd),
            ),
          ],
        ),
        child: Text(
          text,
          maxLines: maxLines,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: fontSize ?? 13, // ← 这里用传进来的 fontSize
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
