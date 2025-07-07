// avatar_editor_page.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_project/utils/constant.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class AvatarEditorPage extends StatefulWidget {
  final String? initialAvatarString;

  const AvatarEditorPage({super.key, this.initialAvatarString});

  @override
  State<AvatarEditorPage> createState() => _AvatarEditorPageState();
}

class _AvatarEditorPageState extends State<AvatarEditorPage> {
  static const int gridSize = 10;
  List<Color> pixels = List.generate(gridSize * gridSize, (_) => Colors.white);

  Color currentColor = Colors.black;
  bool isDrawing = false;
  final GlobalKey _gridKey = GlobalKey();
  @override
  void initState() {
    super.initState();

    final str = widget.initialAvatarString;
    print('🎯 Received initialAvatarString: $str');

    if (str != null) {
      final regex = RegExp(r'#([0-9a-fA-F]{6})');
      final matches = regex.allMatches(str);
      final colorList =
          matches.map((m) => Color(int.parse('0xFF${m.group(1)}'))).toList();

      if (colorList.length == gridSize * gridSize) {
        pixels = colorList;
        print("✅ 成功加载头像颜色，数量: ${colorList.length}");
      } else {
        print("❗颜色数量不对，只有 ${colorList.length} 个");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Avatar'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () async {
              final avatarStringForUpload = pixels
                  .map((c) =>
                      c.value.toRadixString(16).padLeft(8, '0').substring(2))
                  .join();

              final avatarStringForUI = pixels
                  .map((c) =>
                      '#${c.value.toRadixString(16).padLeft(8, '0').substring(2)}')
                  .join();

              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('avatarString', avatarStringForUpload);

              final token = prefs.getString('token');
              final username = prefs.getString('username');

              if (token != null && username != null) {
                final response = await http.post(
                  Uri.parse('$baseApiUrl/login/profile-picture'),
                  headers: {
                    'Content-Type': 'application/json',
                    'Username': username,
                    'Token': token,
                  },
                  body: jsonEncode({
                    'profilePicture': avatarStringForUpload,
                  }),
                );

                if (response.statusCode == 200) {
                  print("头像上传成功");
                } else {
                  print(
                      "Upload failed: ${response.statusCode} ${response.body}");
                  print("Sending avatarString: $avatarStringForUpload");
                }
              }

              Navigator.pop(context, avatarStringForUI);
            },
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: LayoutBuilder(
            builder: (context, constraints) {
              double canvasWidth = constraints.maxWidth * 0.6;
              canvasWidth = canvasWidth > 320 ? 320 : canvasWidth;
              double squareSize = canvasWidth / gridSize;

              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🧹 Clear 按钮区域
                  Column(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            pixels = List.generate(
                                gridSize * gridSize, (_) => Colors.white);
                          });
                        },
                        icon: const Icon(Icons.clear),
                        label: const Text("Clear"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[700],
                          foregroundColor: Colors.white,
                          minimumSize: const Size(80, 36),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(width: 20),

                  // 🎨 画布区域
                  SizedBox(
                    key: _gridKey,
                    width: canvasWidth,
                    height: canvasWidth,
                    child: GestureDetector(
                      onPanStart: (_) => setState(() => isDrawing = true),
                      onPanEnd: (_) => setState(() => isDrawing = false),
                      onPanCancel: () => setState(() => isDrawing = false),
                      onPanUpdate: (details) {
                        final box = _gridKey.currentContext!.findRenderObject()
                            as RenderBox;
                        final localPos =
                            box.globalToLocal(details.globalPosition);

                        final int x = localPos.dx ~/ squareSize;
                        final int y = localPos.dy ~/ squareSize;

                        if (x >= 0 &&
                            x < gridSize &&
                            y >= 0 &&
                            y < gridSize &&
                            isDrawing) {
                          int index = y * gridSize + x;
                          setState(() => pixels[index] = currentColor);
                        }
                      },
                      child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.zero,
                        itemCount: gridSize * gridSize,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: gridSize,
                        ),
                        itemBuilder: (context, index) {
                          return Container(
                            margin: const EdgeInsets.all(0.5),
                            decoration: BoxDecoration(
                              color: pixels[index],
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  const SizedBox(width: 20),

                  // 🎨 颜料盘区域（垂直排列）
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      _buildColorChoice(Colors.black),
                      _buildColorChoice(Colors.white),
                      _buildColorChoice(Colors.red),
                      _buildColorChoice(Colors.green),
                      _buildColorChoice(Colors.blue),
                      _buildColorChoice(Colors.yellow),
                      _buildColorChoice(Colors.orange),
                      _buildColorChoice(Colors.purple),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildColorChoice(Color color) {
    return GestureDetector(
      onTap: () => setState(() => currentColor = color),
      child: Container(
        width: 30,
        height: 30,
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
              color: currentColor == color ? Colors.black : Colors.grey),
        ),
      ),
    );
  }
}

class AvatarPainter extends CustomPainter {
  final String avatarString;
  final int gridSize = 10;

  AvatarPainter(this.avatarString);

  @override
  void paint(Canvas canvas, Size size) {
    final pixelColors = <Color>[];
    final regex = RegExp(r'#([0-9a-fA-F]{6})');
    for (final match in regex.allMatches(avatarString)) {
      final hex = match.group(1)!;
      pixelColors.add(Color(int.parse('0xFF$hex')));
    }

    final double squareSize = size.width / gridSize;
    final paint = Paint();

    for (int y = 0; y < gridSize; y++) {
      for (int x = 0; x < gridSize; x++) {
        final int index = y * gridSize + x;
        if (index >= pixelColors.length) continue;
        paint.color = pixelColors[index];
        canvas.drawRect(
          Rect.fromLTWH(x * squareSize, y * squareSize, squareSize, squareSize),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
