import 'package:flutter/material.dart';
import 'package:flutter_project/generated/app_localizations.dart';
import 'package:flutter_project/pages/student_version/student_choose_class.dart';

class StudentTermsPage extends StatefulWidget {
  final String username;
  final String token;

  const StudentTermsPage({super.key, required this.username, required this.token});

  @override
  _StudentTermsPageState createState() => _StudentTermsPageState();
}

class _StudentTermsPageState extends State<StudentTermsPage> {
  bool _agreed = false; // 是否同意条款

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double baseWidth = 2160;
    double scaleX = screenWidth / baseWidth;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20 * scaleX),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                AppLocalizations.of(context)!.studentTermsTitle,
                style: TextStyle(fontSize: 32 * scaleX, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20 * scaleX),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    AppLocalizations.of(context)!.studentTermsContent,
                    style: TextStyle(fontSize: 20 * scaleX),
                    textAlign: TextAlign.left,
                  ),
                ),
              ),
              SizedBox(height: 20 * scaleX),
              Row(
                children: [
                  Checkbox(
                    value: _agreed,
                    onChanged: (bool? value) {
                      setState(() {
                        _agreed = value ?? false;
                      });
                    },
                  ),
                  Text(AppLocalizations.of(context)!.agreeStudentTerms, style: TextStyle(fontSize: 18 * scaleX)),
                ],
              ),
              SizedBox(height: 20 * scaleX),
              ElevatedButton(
                onPressed: _agreed
                    ? () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => StudentChooseClassPage(
                              studentName: widget.username
                            ),
                          ),
                        );
                      }
                    : null, // 禁用按钮，直到用户勾选同意
                style: ElevatedButton.styleFrom(
                  backgroundColor: _agreed ? Colors.blue : Colors.grey,
                ),
                child: Text(AppLocalizations.of(context)!.continueButton, style: TextStyle(fontSize: 20 * scaleX)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
