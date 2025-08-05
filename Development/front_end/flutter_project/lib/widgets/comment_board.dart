import 'package:flutter/material.dart';
import 'package:flutter_project/widgets/clip_board_clip.dart'; // 根据你的实际路径修改

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
                  // 主咖啡色板子（右移）
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
                          // 白纸或变色纸区域
                          Positioned(
                            top: 10,
                            left: 10,
                            right: 10,
                            bottom: 10,
                            child: Container(
                              decoration: BoxDecoration(
                                color: selectedType != null
                                    ? commentColors[selectedType]!
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
                              child: selectedType == null
                                  ? _buildDefaultView()
                                  : _buildCommentEditor(),
                            ),
                          ),

                          // 板夹夹子
                          Align(
                            alignment: Alignment.topCenter,
                            child: Transform.translate(
                              offset: const Offset(0, -10),
                              child: ClipBoardClip(boardWidth: boardWidth),
                            ),
                          ),

                          // 加号按钮（初始显示）
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

                  // 左侧外扩标签栏
                  // 左侧标签栏，贴在咖啡色大板的左边缘
                  if (selectedType != null)
                    Positioned(
                      left: 60 - 50, // extraLeftSpace - tab 宽度
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

  Widget _buildDefaultView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const CircleAvatar(radius: 20, backgroundColor: Color(0xFFE7D9FF)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Comments for Chapter ${widget.chapterNumber}\nXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX？',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Expanded(
          child: GridView.count(
            crossAxisCount: 2,
            childAspectRatio: 0.9,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: List.generate(4, (index) {
              final colors = [
                Colors.yellow,
                Colors.lightBlueAccent,
                Colors.redAccent,
                Colors.grey,
              ];
              return _buildNoteCard(colors[index]);
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildCommentEditor() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const CircleAvatar(radius: 20, backgroundColor: Color(0xFFE7D9FF)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Comments for Chapter ${widget.chapterNumber}\nXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX？',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          '留下你的新评论吧',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(6),
              color: Colors.white,
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
                      print('发布评论：当前类型 $selectedType');
                      // 可切换为退出模式：
                      // setState(() => selectedType = null);
                    },
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
      ],
    );
  }

  Widget _buildVerticalTabs() {
    return Column(
      children: [
        _buildTab(CommentType.random, Icons.note, Colors.white),
        _buildTab(CommentType.idea, Icons.lightbulb, Colors.amber),
        _buildTab(CommentType.objection, Icons.block, Colors.redAccent),
        _buildTab(
            CommentType.supplement, Icons.add_comment, Colors.lightBlueAccent),
      ],
    );
  }

  Widget _buildTab(CommentType type, IconData icon, Color color) {
    final isSelected = selectedType == type;
    return GestureDetector(
      onTap: () {
        print("点击切换为：$type");
        setState(() {
          selectedType = type;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        width: 50,
        height: 60,
        decoration: BoxDecoration(
          color: color.withOpacity(isSelected ? 1.0 : 0.7),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(10),
            bottomLeft: Radius.circular(10),
          ),
          border: isSelected ? Border.all(color: Colors.black, width: 2) : null,
        ),
        child: Icon(icon, size: 20, color: Colors.white),
      ),
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
            child: CircleAvatar(
              radius: 8,
              backgroundColor: dotColor,
            ),
          ),
          const Positioned(
            bottom: 0,
            right: 0,
            child: Icon(Icons.chat_bubble_outline, size: 18),
          ),
          const Padding(
            padding: EdgeInsets.only(top: 16, right: 20),
            child: Text(
              'XXXXXXXXXXXX XXXXXXXXXXXXXX XXXXXXXXXXXXX XXXXXXXXXXX',
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
