import 'package:flutter/material.dart';

class TestHaPage extends StatefulWidget {
  @override
  _TestHaPageState createState() => _TestHaPageState();
}

class _TestHaPageState extends State<TestHaPage> {
  bool isChildImage = true; // 用于跟踪当前图片状态

  void toggleImage() {
    setState(() {
      isChildImage = !isChildImage; // 切换状态
    });
  }

  @override
  Widget build(BuildContext context) {
    // 获取屏幕宽度和高度
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(title: Text(isChildImage ? "孩子-哈!" : "烧杯")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Center(
              child: Image.asset(
                isChildImage
                    ? "assets/images/孩子-哈！.png"
                    : "assets/images/烧杯.png",
                width: screenWidth * 1, // 让图片宽度适应屏幕
                height: screenHeight * 1, // 让图片高度适应屏幕
                fit: BoxFit.contain, // 保持原始比例
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: toggleImage,
            child: Text(isChildImage ? "显示烧杯" : "显示孩子-哈!"),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
