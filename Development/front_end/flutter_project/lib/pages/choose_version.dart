import 'package:flutter/material.dart';
import 'teacher_version/teacher_login.dart';
import 'student_version/student_login.dart';
import 'package:flutter_project/test.dart';

class ChooseVersionPage extends StatelessWidget {
  const ChooseVersionPage({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double buttonWidth = screenWidth * 0.4;
    double buttonHeight = screenHeight * 0.2;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Version'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Are you?',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  width: buttonWidth,
                  height: buttonHeight,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.greenAccent,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () async {
                      fetchLogin();

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TeacherLoginPage(),
                        ),
                      );
                    },
                    child: Text(
                      'Teacher',
                      style: TextStyle(
                        fontSize: buttonHeight * 0.15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: buttonWidth,
                  height: buttonHeight,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orangeAccent,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () async {
                      fetchLogin();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const StudentLoginPage(),
                        ),
                      );
                    },
                    child: Text(
                      'Student',
                      style: TextStyle(
                        fontSize: buttonHeight * 0.15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
