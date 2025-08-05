// 🎯 整合版 CommentBoard：comments 顶部展示，颜色只变输入框
import 'package:flutter/material.dart';
import 'package:flutter_project/widgets/clip_board_clip.dart';

class CommentBoard extends StatefulWidget {
  final int chapterNumber;
  const CommentBoard({super.key, required this.chapterNumber});

  @override
  State<CommentBoard> createState() => _CommentBoardState();
}

enum CommentType { random, idea, objection, supplement }

const Map<CommentType, Color> commentColors = {
  CommentType.random: Colors.white,
  CommentType.idea: Colors.yellow,
  CommentType.objection: Colors.redAccent,
  CommentType.supplement: Colors.lightBlueAccent,
};

class _CommentBoardState extends State<CommentBoard> {
  CommentType? selectedType;
  bool isViewingNoteDetail = false;

  String _getHintText() {
    switch (selectedType) {
      case CommentType.random:
        return "随机写下想法吧...";
      case CommentType.idea:
        return "输入你想到的新点子...";
      case CommentType.objection:
        return "写下你的反对意见...";
      case CommentType.supplement:
        return "补充一下上面的观点吧...";
      default:
        return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            const double extraLeftSpace = 60;
            final double usableWidth = constraints.maxWidth;
            final double usableHeight = constraints.maxHeight;
            final double boardWidth = usableWidth - extraLeftSpace;

            return Container(
              width: usableWidth,
              height: usableHeight,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    top: 10,
                    right: 10,
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: const CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.close, size: 18, color: Colors.black),
                      ),
                    ),
                  ),
                  Positioned(
                    left: extraLeftSpace,
                    child: Container(
                      width: boardWidth,
                      height: usableHeight,
                      decoration: BoxDecoration(
                        color: const Color(0xFF815E25),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          // 白纸区域（背景固定白色）
                          Positioned(
                            top: 10,
                            left: 10,
                            right: 10,
                            bottom: 10,
                            child: Container(
                              decoration: BoxDecoration(
                                color: selectedType != null &&
                                        !isViewingNoteDetail
                                    ? commentColors[selectedType]! // ✅ 仅写评论时变色
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 15,
                                    offset: const Offset(4, 4),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildHeader(),
                                  const SizedBox(height: 12),
                                  Expanded(
                                    child: selectedType == null
                                        ? _buildDefaultView()
                                        : isViewingNoteDetail
                                            ? _buildNoteDetailView()
                                            : _buildCommentEditor(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 12,
                            left: 12,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (selectedType != null &&
                                      isViewingNoteDetail) {
                                    // 之前只关掉 isViewingNoteDetail，现在连 type 一起清掉
                                    isViewingNoteDetail = false;
                                    selectedType = null;
                                  } else if (selectedType != null) {
                                    selectedType = null;
                                  } else {
                                    Navigator.of(context).pop();
                                  }
                                });
                              },
                              child: const CircleAvatar(
                                radius: 22,
                                backgroundColor: Colors.white,
                                child:
                                    Icon(Icons.arrow_back, color: Colors.black),
                              ),
                            ),
                          ),

                          Align(
                            alignment: Alignment.topCenter,
                            child: Transform.translate(
                              offset: const Offset(0, -10),
                              child: ClipBoardClip(boardWidth: boardWidth),
                            ),
                          ),

                          if (selectedType == null)
                            Positioned(
                              bottom: 30,
                              right: 30,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedType = CommentType.random;
                                  });
                                },
                                child: const CircleAvatar(
                                  radius: 26,
                                  backgroundColor: Colors.white,
                                  child: Icon(Icons.add, color: Colors.black),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  if (selectedType != null && !isViewingNoteDetail)
                    Positioned(
                      left: 10,
                      top: 50,
                      child: _buildVerticalTabs(),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const CircleAvatar(radius: 20, backgroundColor: Color(0xFFE7D9FF)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'Comments for Chapter ${widget.chapterNumber}\nXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX？',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultView() {
    return GridView.count(
      crossAxisCount: 2,
      children: List.generate(4, (index) {
        final colors = [
          Colors.yellow,
          Colors.lightBlueAccent,
          Colors.redAccent,
          Colors.grey
        ];
        return GestureDetector(
          onTap: () {
            setState(() {
              selectedType = CommentType.random;
              isViewingNoteDetail = true;
            });
          },
          child: _buildNoteCard(colors[index]),
        );
      }),
    );
  }

  Widget _buildCommentEditor() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              // ✅ 背景固定褐色
              color: const Color(0xFFF4F4F4),
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white, // ✅ 输入区域始终白色
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                children: [
                  Expanded(
                    child: TextField(
                      maxLines: null,
                      decoration: InputDecoration(
                        hintText: _getHintText(),
                        filled: true, // ✅ 填充背景
                        fillColor: Colors.white, // ✅ 填充为白色
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: ElevatedButton(
                      onPressed: () => setState(() => selectedType = null),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text("发表"),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNoteDetailView() {
    return Row(
      children: [
        // 左侧：主评论 + 所有回复（略缩小）
        Expanded(
          flex: 4,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 12,
                  offset: Offset(4, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 主评论（带头像）
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    CircleAvatar(
                        radius: 16, backgroundColor: Color(0xFFE7D9FF)),
                    SizedBox(width: 8),
                    Expanded(child: Text('主评论：XXX XXXX XXXX')),
                  ],
                ),
                const Divider(),
                const Text('所有回复：'),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView(
                    children: List.generate(
                      3,
                      (i) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const CircleAvatar(
                                radius: 14, backgroundColor: Colors.grey),
                            const SizedBox(width: 8),
                            Expanded(child: Text('回复 ${i + 1}：XXXXX XXXX')),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(width: 10),

        // 右侧：回复输入区域（略放大）
        Expanded(
          flex: 5,
          child: Column(
            children: [
              // 标签栏贴顶，按钮变小
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildTrapezoidTab(CommentType.random, Colors.white),
                    _buildTrapezoidTab(CommentType.idea, Colors.amber),
                    _buildTrapezoidTab(CommentType.objection, Colors.redAccent),
                    _buildTrapezoidTab(
                        CommentType.supplement, Colors.lightBlueAccent),
                  ],
                ),
              ),

              // 回复输入框
              // 回复输入框（保持白底，输入框内部变色）
              // 回复输入框外层（加阴影）
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 15,
                        offset: const Offset(6, 6),
                      ),
                    ],
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white, // 保持输入框白色
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: TextField(
                            maxLines: null,
                            decoration: InputDecoration.collapsed(
                              hintText: _getHintText(),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                selectedType = null;
                                isViewingNoteDetail = false;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                              elevation: 4, // ✅ 按钮也带轻微阴影
                              shadowColor: Colors.black.withOpacity(0.2),
                            ),
                            child: const Text("发表"),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNoteCard(Color dotColor) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(4),
        color: Colors.white,
      ),
      padding: const EdgeInsets.all(10),
      child: Stack(
        children: [
          Positioned(
              top: 0,
              left: 0,
              child: CircleAvatar(radius: 8, backgroundColor: dotColor)),
          const Positioned(
              bottom: 0,
              right: 0,
              child: Icon(Icons.chat_bubble_outline, size: 18)),
          const Padding(
            padding: EdgeInsets.only(top: 16, right: 20),
            child: Text('XXXXXXXXXXXX XXXXXXXXXXXXXX XXXXXXXXXXXXX XXXXXXXXXXX',
                style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalTabs() {
    return Column(
      children: [
        _buildSideTab(CommentType.random, Icons.note, Colors.white),
        _buildSideTab(CommentType.idea, Icons.lightbulb, Colors.amber),
        _buildSideTab(CommentType.objection, Icons.block, Colors.redAccent),
        _buildSideTab(
            CommentType.supplement, Icons.add_comment, Colors.lightBlueAccent),
      ],
    );
  }

  Widget _buildSideTab(CommentType type, IconData icon, Color color) {
    final isSelected = selectedType == type;
    return GestureDetector(
      onTap: () => setState(() => selectedType = type),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        width: 50,
        height: 60,
        decoration: BoxDecoration(
          color: color.withOpacity(isSelected ? 1.0 : 0.7),
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10), bottomLeft: Radius.circular(10)),
          border: isSelected ? Border.all(color: Colors.black, width: 2) : null,
        ),
        child: Icon(icon, size: 20, color: Colors.white),
      ),
    );
  }

  Widget _buildTrapezoidTab(CommentType type, Color color) {
    final isSelected = selectedType == type;
    return GestureDetector(
      onTap: () => setState(() => selectedType = type),
      child: Container(
        margin: const EdgeInsets.only(right: 6),
        width: 40,
        height: 30,
        decoration: BoxDecoration(
          color: color.withOpacity(isSelected ? 1.0 : 0.6),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(8),
            topRight: Radius.circular(8),
          ),
          border: isSelected ? Border.all(color: Colors.black, width: 2) : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 8,
              offset: Offset(2, 2),
            )
          ],
        ),
        alignment: Alignment.center,
        child: const Icon(Icons.edit, color: Colors.white, size: 20),
      ),
    );
  }
}
