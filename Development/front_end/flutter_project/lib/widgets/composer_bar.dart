import 'package:flutter/material.dart';
import 'package:flutter_project/models/comment_models.dart';

class ComposerBar extends StatefulWidget {
  final CommentType current;
  final ValueChanged<CommentType> onChanged;
  final VoidCallback onSend;
  final TextEditingController controller;

  const ComposerBar({
    super.key,
    required this.current,
    required this.onChanged,
    required this.onSend,
    required this.controller,
  });

  @override
  State<ComposerBar> createState() => _ComposerBarState();
}

class _ComposerBarState extends State<ComposerBar> with TickerProviderStateMixin {
  late FocusNode _focusNode;
  bool _showTypes = false;

  // 与 TextField 样式匹配的行高/内边距参数（只改这里即可全局生效）
  static const _fontSize = 15.0;
  static const _lineHeight = 1.2;          // TextStyle.height
  static const _vPadding = 8.0;            // InputDecoration.contentPadding.vertical
  static const _hPadding = 12.0;           // 容器左右 padding
  static const _borderWidth = 2.0;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      if (mounted) setState(() => _showTypes = _focusNode.hasFocus);
    });
    // 文本变动时重新测量行数
    widget.controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = kTypeColor[widget.current]!;

    return SafeArea(
      top: false,
      child: Container(
        color: kCanvasBrown,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 分类按钮 —— 仅聚焦时显示，尺寸更小
            if (_showTypes)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: CommentType.values.map((t) {
                    final selected = t == widget.current;
                    final c = kTypeColor[t]!;
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ChoiceChip(
                        label: Text(
                          typeLabel(t),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: selected ? Colors.black : c,
                          ),
                        ),
                        selected: selected,
                        onSelected: (_) => widget.onChanged(t),
                        selectedColor: c.withOpacity(0.5),
                        backgroundColor: Colors.white,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        shape: StadiumBorder(side: BorderSide(color: c, width: 1.5)),
                      ),
                    );
                  }).toList(),
                ),
              ),
            if (_showTypes) const SizedBox(height: 8),

            // ===== 输入 + 发表（1→2→3 行，自增；超过 3 行内部滚动）=====
            Row(
              children: [
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // 计算可用宽度（去掉左右 padding）
                      final maxTextWidth = constraints.maxWidth - _hPadding * 2;

                      // 用 TextPainter 计算当前文本行数
                      int _calcLines(String text) {
                        if (text.isEmpty) return 1;
                        final painter = TextPainter(
                          text: TextSpan(
                            text: text,
                            style: const TextStyle(fontSize: _fontSize, height: _lineHeight),
                          ),
                          textDirection: TextDirection.ltr,
                          maxLines: 999,
                        )..layout(maxWidth: maxTextWidth);
                        return painter.computeLineMetrics().length.clamp(1, 999);
                      }

                      final linesNeeded = _calcLines(widget.controller.text);
                      final linesShown = linesNeeded.clamp(1, 3); // 1、2、3 行三挡

                      // 计算目标高度 = 行高 * 行数 + 上下 contentPadding + 边框
                      // preferredLineHeight 更准确，但我们用公式：fontSize * lineHeight
                      final perLine = _fontSize * _lineHeight;
                      final targetHeight = perLine * linesShown + _vPadding * 2 + _borderWidth * 2;

                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        curve: Curves.easeOut,
                        height: targetHeight, // 👈 高度只取 1/2/3 行
                        decoration: ShapeDecoration(
                          color: Colors.white,
                          shape: StadiumBorder(side: BorderSide(color: borderColor, width: _borderWidth)),
                          shadows: const [
                            BoxShadow(color: Color(0x22000000), blurRadius: 6, offset: Offset(0, 3)),
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: _hPadding),
                        alignment: Alignment.center,
                        // 用 expands:true + 固定容器高度，超出 3 行时内部竖向滚动
                        child: TextField(
                          focusNode: _focusNode,
                          controller: widget.controller,
                          keyboardType: TextInputType.multiline,
                          textInputAction: TextInputAction.newline,
                          expands: true,              // 👈 撑满容器高度
                          minLines: null,
                          maxLines: null,             // 👈 交给外层高度控制；内部可滚动
                          scrollPhysics: const BouncingScrollPhysics(),
                          textAlignVertical: TextAlignVertical.center,
                          style: const TextStyle(fontSize: _fontSize, height: _lineHeight),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: '写点什么…',
                            contentPadding: EdgeInsets.symmetric(vertical: _vPadding),
                          ),
                          strutStyle: const StrutStyle(
                            forceStrutHeight: true,
                            height: _lineHeight,
                            leading: 0,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    minimumSize: const Size(0, 40),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    textStyle: const TextStyle(fontSize: 13),
                  ),
                  onPressed: widget.onSend,
                  child: const Text('发表'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
