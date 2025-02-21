import 'package:flutter/material.dart';
import 'package:flutter_project/components/character_display.dart';

class TestHaPage extends StatefulWidget {
  final Offset initialPosition;
  const TestHaPage({super.key, this.initialPosition = const Offset(0.5, 0.5)});

  @override
  _TestHaPageState createState() => _TestHaPageState();
}

class _TestHaPageState extends State<TestHaPage> {
  bool isLabMode = false;
  late Offset _position;

  @override
  void initState() {
    super.initState();
    _position = widget.initialPosition;
  }

  void toggleMode() {
    setState(() {
      isLabMode = !isLabMode;
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
          // 背景
          if (isLabMode)
            Positioned.fill(
              child: Image.asset(
                "assets/images/background/实验室-器材组装场景.png",
                fit: BoxFit.cover,
              ),
            ),

          // 显示角色（非实验室模式）
          if (!isLabMode)
            showCharacter("孩子-哈！", "left", "assets/images/孩子-哈！.png"),

          // 可拖动的烧杯（实验室模式下才可见）
          if (isLabMode)
            Positioned(
              left: _position.dx.clamp(0, screenWidth - screenWidth * 0.3),
              top: _position.dy.clamp(0, screenHeight - screenHeight * 0.3),
              child: GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    _position = Offset(
                      (_position.dx + details.delta.dx)
                          .clamp(0, screenWidth - screenWidth * 0.3),
                      (_position.dy + details.delta.dy)
                          .clamp(0, screenHeight - screenHeight * 0.3),
                    );
                  });
                },
                child: showCharacter("烧杯", "left", "assets/images/烧杯.png"),
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
