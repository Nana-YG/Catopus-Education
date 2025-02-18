import 'package:flutter/material.dart';

class TestHaPage extends StatefulWidget {
  final Offset initialPosition; // 允许传入烧杯的初始位置
  const TestHaPage({super.key, this.initialPosition = const Offset(0.5, 0.5)});

  @override
  _TestHaPageState createState() => _TestHaPageState();
}

class _TestHaPageState extends State<TestHaPage> {
  bool isLabMode = false; // 是否处于实验室模式
  late Offset _position; // 烧杯的位置

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final screenWidth = MediaQuery.of(context).size.width;
      final screenHeight = MediaQuery.of(context).size.height;

      setState(() {
        _position = Offset(
          screenWidth * widget.initialPosition.dx,
          screenHeight * widget.initialPosition.dy,
        );
      });
    });
  }

  void toggleMode() {
    setState(() {
      isLabMode = !isLabMode; // 切换实验室和人物场景
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(title: Text(isLabMode ? "实验室场景" : "孩子-哈！")),
      body: Stack(
        children: [
          // 背景（实验室模式才显示）
          if (isLabMode)
            Positioned.fill(
              child: Image.asset(
                "assets/images/background/实验室-器材组装场景.png",
                fit: BoxFit.cover,
              ),
            ),

          // 人物（仅在非实验室模式下显示）
          if (!isLabMode)
            Positioned(
              left: screenWidth * 0.55, // 调整人物向右移动（55% 屏幕宽度）
              top: screenHeight * 0.06, // 稍微向下调整
              child: Image.asset(
                "assets/images/孩子-哈！.png",
                width: screenWidth * 0.4, // 让人物大小适应屏幕
                height: screenHeight * 0.8,
                fit: BoxFit.contain,
              ),
            ),

          // 可拖动的烧杯（仅在实验室模式下可见）
          if (isLabMode)
            Positioned(
              left: _position.dx.clamp(0, screenWidth - screenWidth * 0.3),
              top: _position.dy.clamp(0, screenHeight - screenHeight * 0.3),
              child: GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    _position = Offset(
                      (_position.dx + details.delta.dx).clamp(0, screenWidth - screenWidth * 0.3),
                      (_position.dy + details.delta.dy).clamp(0, screenHeight - screenHeight * 0.3),
                    );
                  });
                },
                child: Image.asset(
                  "assets/images/烧杯.png",
                  width: screenWidth * 0.8, // 让烧杯大小适应屏幕
                  height: screenHeight * 0.8,
                  fit: BoxFit.contain,
                ),
              ),
            ),

          // 切换按钮
          Positioned(
            bottom: screenHeight * 0.05,
            left: screenWidth / 2 - screenWidth * 0.15,
            child: ElevatedButton(
              onPressed: toggleMode,
              child: Text(isLabMode ? "回到孩子-哈！" : "进入实验室"),
            ),
          ),
        ],
      ),
    );
  }
}
