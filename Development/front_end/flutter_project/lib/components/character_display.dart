import 'package:flutter/material.dart';

/// 角色显示组件
class CharacterDisplay extends StatelessWidget {
  final String characterName;
  final String position;
  final String imagePath;

  const CharacterDisplay({
    super.key,
    required this.characterName,
    required this.position,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    // 计算默认的 left 位置
    double leftOffset;
    double topOffset = screenHeight * 0.06; // 统一上偏移量

    if (position == "left") {
      leftOffset = screenWidth * 0.1; // 左侧角色
    } else if (position == "right") {
      leftOffset = screenWidth * 0.55; // 右侧角色
    } else {
      leftOffset = screenWidth * 0.35; // 居中
    }

    return Positioned(
      left: leftOffset,
      top: topOffset,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            imagePath,
            width: screenWidth * 0.4,
            height: screenHeight * 0.8,
            fit: BoxFit.contain,
          ),
          Text(characterName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

/// Helper Function: 直接返回 `CharacterDisplay` 组件
Widget showCharacter(String name, String position, String imagePath) {
  return CharacterDisplay(
    characterName: name,
    position: position,
    imagePath: imagePath,
  );
}
