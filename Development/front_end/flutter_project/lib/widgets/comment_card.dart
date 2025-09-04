import 'package:flutter/material.dart';
import 'package:flutter_project/models/comment_models.dart';
import 'package:flutter_project/utils/avatar_service.dart';
import 'package:flutter_project/pages/avatar_editor_page.dart'; // AvatarPainter

class CommentCard extends StatelessWidget {
  final Comment comment;
  final CommentType type; // 右下角显示
  final int? repliesCount;

  const CommentCard({
    super.key,
    required this.comment,
    required this.type,
    this.repliesCount,
  });

  @override
  Widget build(BuildContext context) {
    final color = kTypeColor[type]!;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: color, width: 2),
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
              color: Color(0x22000000), blurRadius: 10, offset: Offset(0, 4))
        ],
      ),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      constraints: const BoxConstraints(minHeight: 80, maxHeight: 120),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 头像：从后端取并缓存
          FutureBuilder<String?>(
            future: fetchAvatarHexFor(comment.username),
            builder: (context, snap) {
              final hex = snap.data;
              return Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: color, width: 3),
                  color: Colors.white,
                ),
                child: ClipOval(
                  child: (snap.connectionState == ConnectionState.waiting)
                      ? Center(
                          child: SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: color)))
                      : (hex != null && hex.isNotEmpty)
                          ? CustomPaint(painter: AvatarPainter(hex))
                          : Icon(Icons.person, size: 22, color: color),
                ),
              );
            },
          ),
          const SizedBox(width: 12),

          // 文本内容
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _TagPill(text: typeLabel(type), color: color),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text('@${comment.username}',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w600)),
                    ),
                    Text(_fmt(comment.timestamp),
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade600)),
                  ],
                ),
                const SizedBox(height: 6),
                Expanded(
                  child: Text(
                    comment.content,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 15, height: 1.25),
                  ),
                ),
                Row(
                  children: [
                    const Spacer(),
                    if (repliesCount != null) ...[
                      // 👈 只在非空时显示
                      Text('Replies',
                          style: TextStyle(
                              color: Colors.grey.shade700, fontSize: 13)),
                      const SizedBox(width: 6),
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          shape: BoxShape.circle,
                          border:
                              Border.all(color: Colors.grey.shade500, width: 1),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '$repliesCount',
                          style: const TextStyle(
                              fontSize: 11, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
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
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text,
          style: TextStyle(
              color: color, fontWeight: FontWeight.w800, fontSize: 12)),
    );
  }
}
