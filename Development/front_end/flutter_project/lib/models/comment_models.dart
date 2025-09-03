import 'package:flutter/material.dart';

/// 画布背景色
const kCanvasBrown = Color(0xFF815E25);

/// 四种评论类型
enum CommentType { defaultType, idea, challenge, supplement }

/// 每种类型的主色
const kTypeColor = {
  CommentType.defaultType: Color(0xFFBDBDBD), // 灰
  CommentType.idea:        Color(0xFFD4AF37), // 金黄
  CommentType.challenge:   Color(0xFFE53935), // 红
  CommentType.supplement:  Color(0xFF2E7D32), // 绿
};

/// UI 展示用中文标签
String typeLabel(CommentType t) => switch (t) {
  CommentType.defaultType => '默认',
  CommentType.idea        => '加入新点子',
  CommentType.challenge   => '反对/挑战',
  CommentType.supplement  => '补充说明',
};

/// 与后端传输的字符串
String typeToWire(CommentType t) => switch (t) {
  CommentType.defaultType => 'default',
  CommentType.idea        => 'idea',
  CommentType.challenge   => 'challenge',
  CommentType.supplement  => 'supplement',
};

/// 从后端字符串还原到枚举
CommentType wireToType(String s) {
  switch (s) {
    case 'idea':       return CommentType.idea;
    case 'challenge':  return CommentType.challenge;
    case 'supplement': return CommentType.supplement;
    case 'default':
    default:           return CommentType.defaultType;
  }
}

/// ====== 数据模型 ======
class BoardDetail {
  final String boardId;
  final String classId;
  final String title;
  final List<Comment> comments;

  BoardDetail({
    required this.boardId,
    required this.classId,
    required this.title,
    required this.comments,
  });

  factory BoardDetail.fromJson(Map<String, dynamic> json) {
    final List list = (json['comments'] as List? ?? []);
    return BoardDetail(
      boardId: json['boardId'] ?? '',
      classId: json['classId'] ?? '',
      title: json['title'] ?? '',
      comments: list.map((e) => Comment.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}

class Comment {
  final String commentId;
  final String username;
  final String attitude; // 'default' | 'idea' | 'challenge' | 'supplement'
  final String content;
  final String timestamp;
  final String? replyTo;

  Comment({
    required this.commentId,
    required this.username,
    required this.attitude,
    required this.content,
    required this.timestamp,
    required this.replyTo,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      commentId: json['commentId'] ?? '',
      username: json['username'] ?? '',
      attitude: json['attitude'] ?? 'default',
      content: json['content'] ?? '',
      timestamp: json['timestamp'] ?? '',
      replyTo: json['replyTo'],
    );
  }
}
