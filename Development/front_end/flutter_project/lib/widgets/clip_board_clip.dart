import 'package:flutter/material.dart';

class ClipBoardClip extends StatelessWidget {
  final double boardWidth;

  const ClipBoardClip({super.key, required this.boardWidth});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: boardWidth,
      height: 60, // 高度取决于黑夹子高度+灰色钩子
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          // 灰色圆角钩子
          Positioned(
            top: 10,
            child: Container(
              width: 120,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.transparent,
                border: Border.all(
                  color: const Color(0xFFB8B8B8),
                  width: 7,
                ),
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),

          // 黑色夹子主体
          Positioned(
            top: 0,
            child: Container(
              width: 100,
              height: 25,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
