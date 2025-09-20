import 'package:flutter/material.dart';
import 'package:flutter_project/generated/app_localizations.dart';
import 'package:flutter_project/pages/comment_boards_area.dart';

class CommentBoardsHolder extends StatelessWidget {
  final String classId;
  const CommentBoardsHolder({super.key, required this.classId});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return DecoratedBox(
      decoration: const BoxDecoration(color: Colors.transparent),
      child: Padding(
        padding: const EdgeInsets.only(top: 0),
        child: CommentBoardsArea(
          classId: classId,
          title: l10n.courseDetail_commentBoard,
        ),
      ),
    );
  }
}
