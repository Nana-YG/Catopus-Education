import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class StudentChooseClassPage extends StatefulWidget {
  final String studentName;

  const StudentChooseClassPage({super.key, required this.studentName});

  @override
  _StudentChooseClassPageState createState() => _StudentChooseClassPageState();
}

class _StudentChooseClassPageState extends State<StudentChooseClassPage> {
  List<dynamic> _classes = [];

  // 加载当前学生的班级信息
  Future<void> loadMockData() async {
    final String response =
        await rootBundle.loadString('lib/temp_data/mock_login_data.json');
    final data = json.decode(response);

    // 根据学生用户名获取班级信息
    final student = data['users'].firstWhere(
      (user) => user['username'] == widget.studentName,
      orElse: () => null,
    );

    if (student != null && student['classes'] != null) {
      setState(() {
        _classes = student['classes'];
      });
    }
  }

  @override
  void initState() {
    super.initState();
    loadMockData(); // 页面初始化时加载数据
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
          ? const Center(child: CircularProgressIndicator()) // 加载时显示指示器
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

                return GestureDetector(
                  onTap: () {
                    // 点击卡片的处理逻辑
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Selected: ${classData['name']}')),
                    );
                  },
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          classData['name'], // 课程名字
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
