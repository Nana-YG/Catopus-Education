import 'package:flutter/material.dart';
import 'package:flutter_project/models/comment_models.dart';
import 'package:flutter_project/utils/avatar_service.dart';
import 'package:flutter_project/pages/avatar_editor_page.dart'; // AvatarPainter

class CommentCard extends StatelessWidget {
  final Comment comment;
  final CommentType type;

  /// 父评论可传总回复数；子评论传 null
  final int? repliesCount;

  final bool showDelete;
  final VoidCallback? onDelete;

  /// 删除按钮是否行内
  final bool actionsInline;

  /// 如果是“回复某条子评论”，显示「A ▶ B」
  final String? replyToUsername; // null 表示直接回复父评论或顶层父评论
  /// 本条评论在该父线程下的序号：1/2/3...
  final int? fromIndex;
  /// 被回复那条在该父线程下的序号（仅当 replyToUsername != null）
  final int? toIndex;

  /// 右下角「回复/收起回复」
  final VoidCallback? onReply;
  final bool replyOpened;

  /// 可选：限制内容最大行数；null 表示不限行（高度完全由内容决定）
  final int? maxContentLines;

  const CommentCard({
    super.key,
    required this.comment,
    required this.type,
    this.repliesCount,
    this.showDelete = false,
    this.onDelete,
    this.actionsInline = false,
    this.replyToUsername,
    this.fromIndex,
    this.toIndex,
    this.onReply,
    this.replyOpened = false,
    this.maxContentLines,
  });

  @override
  Widget build(BuildContext context) {
    final color = kTypeColor[type]!;
    final bool isTopLevel = replyToUsername == null && fromIndex == null;

    return Stack(
      children: [
        // =========== 主体卡片 ===========
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: color, width: 2),
            borderRadius: BorderRadius.circular(8),
            boxShadow: const [
              BoxShadow(color: Color(0x22000000), blurRadius: 10, offset: Offset(0, 4)),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),

          // 用 Stack 让父评论的 pill 能定位在右上角
          child: Stack(
            children: [
              // 主要内容列
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 头像
                  FutureBuilder<String?>(
                    future: fetchAvatarHexFor(comment.username),
                    builder: (context, snap) {
                      final hex = snap.data;
                      return Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: color, width: 2.5),
                          color: Colors.white,
                        ),
                        child: ClipOval(
                          child: (snap.connectionState == ConnectionState.waiting)
                              ? Center(
                                  child: SizedBox(
                                    width: 14,
                                    height: 14,
                                    child:
                                        CircularProgressIndicator(strokeWidth: 2, color: color),
                                  ),
                                )
                              : (hex != null && hex.isNotEmpty)
                                  ? CustomPaint(painter: AvatarPainter(hex))
                                  : Icon(Icons.person, size: 20, color: color),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 10),

                  // 文本列（高度由内容决定）
                  Flexible(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 第一行：名字路径（含序号）
                        _buildNamePath(),

                        const SizedBox(height: 4),

                        // ===== 父 / 子 两种布局 =====
                        if (isTopLevel) ...[
                          // 顶层父评论：
                          // 第二行：@User + 时间（时间放右侧）
                          Row(
                            children: [
                              // 轻量的时间可以放在右上角 pill 下方右侧，也可以不显示
                              const Spacer(),
                              Text(
                                _fmt(comment.timestamp),
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),

                          // 内容单独一行
                          Text(
                            comment.content,
                            maxLines: maxContentLines,
                            overflow: maxContentLines == null
                                ? TextOverflow.visible
                                : TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 15, height: 1.25),
                          ),
                        ] else ...[
                          // 子评论：
                          // 第二行：Pill 与 内容“同一行”
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _TagPill(text: typeLabel(type), color: color),
                              const SizedBox(width: 8),
                              // 内容和 pill 同行开始
                              Expanded(
                                child: Text(
                                  comment.content,
                                  maxLines: maxContentLines,
                                  overflow: maxContentLines == null
                                      ? TextOverflow.visible
                                      : TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 15, height: 1.25),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          // 子评论时间（可选显示在下一行右侧）
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              _fmt(comment.timestamp),
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey.shade600),
                            ),
                          ),
                        ],

                        const SizedBox(height: 6),

                        // 底部：回复数 + 删除 + 回复/收起（右对齐）
                        Row(
                          children: [
                            const Spacer(),
                            if (repliesCount != null) ...[
                              Text('Replies',
                                  style: TextStyle(
                                      color: Colors.grey.shade700, fontSize: 13)),
                              const SizedBox(width: 6),
                              Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: Colors.grey.shade500, width: 1),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  '$repliesCount',
                                  style: const TextStyle(
                                      fontSize: 10, fontWeight: FontWeight.w700),
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                            if (showDelete && actionsInline)
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(6),
                                  onTap: onDelete,
                                  child: const Padding(
                                    padding: EdgeInsets.all(4),
                                    child: Icon(Icons.delete_outline,
                                        size: 18, color: Colors.black87),
                                  ),
                                ),
                              ),
                            if (onReply != null) ...[
                              const SizedBox(width: 4),
                              TextButton.icon(
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.black87,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  visualDensity: VisualDensity.compact,
                                ),
                                onPressed: onReply,
                                icon: Icon(replyOpened ? Icons.close : Icons.reply,
                                    size: 18),
                                label: Text(replyOpened ? '收起回复' : '回复'),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // ===== 父评论：把类型 pill 固定到右上角 =====
              if (isTopLevel)
                Positioned(
                  right: 0,
                  top: 0,
                  child: _TagPill(text: typeLabel(type), color: color),
                ),
            ],
          ),
        ),

        // 非行内的右下角删除按钮（保持不变）
        if (showDelete && !actionsInline)
          Positioned(
            right: 6,
            bottom: 6,
            child: Material(
              color: Colors.white,
              shape: const CircleBorder(),
              elevation: 1,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onDelete,
                child: const Padding(
                  padding: EdgeInsets.all(6),
                  child: Icon(Icons.delete_outline,
                      size: 18, color: Colors.black87),
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// ===== 组装“名字 + 序号”路径行 =====
  Widget _buildNamePath() {
    // 顶层父评论（没有序号/没有被回复者）
    final isTopLevel = replyToUsername == null && fromIndex == null;
    if (isTopLevel) {
      return Row(
        children: [
          Text(
            '@${comment.username}',
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.grey.shade800,
              fontWeight: FontWeight.w700,
            ),
          ),
          // 父评论的时间放到右上角区域下方已经显示，这里不重复
        ],
      );
    }

    // 直接回复父评论：仅显示“自己 名字+序号”
    if (replyToUsername == null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _UserPill(text: comment.username),
          if (fromIndex != null) ...[
            const SizedBox(width: 4),
            _SmallIndex(fromIndex!),
          ],
        ],
      );
    }

    // 回复子评论：显示 “自己 名字+序号 ▶ 对方 名字+序号”
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _UserPill(text: comment.username),
        if (fromIndex != null) ...[
          const SizedBox(width: 4),
          _SmallIndex(fromIndex!),
        ],
        const SizedBox(width: 6),
        const Icon(Icons.play_arrow_rounded, size: 16, color: Color(0xFFBDBDBD)),
        const SizedBox(width: 6),
        _UserPill(text: replyToUsername!),
        if (toIndex != null) ...[
          const SizedBox(width: 4),
          _SmallIndex(toIndex!),
        ],
      ],
    );
  }

  String _fmt(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      String two(int n) => n.toString().padLeft(2, '0');
      return '${dt.year}-${two(dt.month)}-${two(dt.day)} ${two(dt.hour)}:${two(dt.minute)}';
    } catch (_) {
      return iso;
    }
  }
}

/* ======= 小部件们 ======= */

class _TagPill extends StatelessWidget {
  final String text;
  final Color color;
  const _TagPill({required this.text, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: color, width: 2),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(text, style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 12)),
    );
  }
}

class _UserPill extends StatelessWidget {
  final String text;
  const _UserPill({required this.text});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF7A7A7A))),
    );
  }
}

class _SmallIndex extends StatelessWidget {
  final int n;
  const _SmallIndex(this.n);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: const Color(0xFFEAEAEA),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFD5D5D5)),
      ),
      child: Text('$n', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF6F6F6F))),
    );
  }
}
