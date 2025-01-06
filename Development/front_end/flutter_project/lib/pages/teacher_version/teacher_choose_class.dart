import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TeacherChooseClassPage extends StatefulWidget {
  final String teacherName;

  const TeacherChooseClassPage({super.key, required this.teacherName});

  @override
  _TeacherChooseClassPageState createState() => _TeacherChooseClassPageState();
}

class _TeacherChooseClassPageState extends State<TeacherChooseClassPage> {
  List<dynamic> _classes = [];
  // 这是一个暂时的数据模拟器
  Future<void> loadMockData() async {
    final String response =
        await rootBundle.loadString('lib/temp_data/mock_login_data.json');
    final data = json.decode(response);

    final teacher = data['users'].firstWhere(
      (user) => user['username'] == widget.teacherName,
      orElse: () => null,
    );

    if (teacher != null && teacher['classes'] != null) {
      setState(() {
        _classes = teacher['classes'];
      });
    }
  }

  @override
  void initState() {
    super.initState();
    loadMockData();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = (screenWidth / 200).floor(); // 动态计算每行卡片数量

    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Class'),
      ),
      body: _classes.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount, // 动态计算每行卡片数量
                crossAxisSpacing: 16, // 卡片之间的水平间距
                mainAxisSpacing: 16, // 卡片之间的垂直间距
                childAspectRatio: 3 / 4, // 卡片的宽高比
              ),
              itemCount: _classes.length,
              itemBuilder: (context, index) {
                final classData = _classes[index];
                if (classData is String) {
                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        classData,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                } else if (classData is Map) {
                  final hasImage = classData.containsKey('image') &&
                      (classData['image'] ?? '').isNotEmpty;

                  return GestureDetector(
                    onTap: () {
                      // 点击卡片之后的处理
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Selected: ${classData['name']}')),
                      );
                    },
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        mainAxisAlignment: hasImage
                            ? MainAxisAlignment.start
                            : MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (hasImage)
                            Expanded(
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(16),
                                ),
                                child: Image.network(
                                  classData['image'],
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                ),
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              classData['name'],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                } else {
                  return const SizedBox();
                }
              },
            ),
    );
  }
}
