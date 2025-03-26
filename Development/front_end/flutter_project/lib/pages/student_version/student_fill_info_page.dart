import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_project/pages/student_version/student_choose_class.dart';
import 'package:flutter_project/pages/student_version/student_terms_page.dart';
import 'package:flutter_project/pages/teacher_version/teacher_choose_class.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_project/generated/app_localizations.dart';
import 'package:flutter_project/utils/constant.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StudentUserInfoPage extends StatefulWidget {
  final String username; // ✅ 添加用户名
  final String token; // ✅ 添加 token

  const StudentUserInfoPage(
      {super.key, required this.username, required this.token});

  @override
  _FillUserInfoPageState createState() => _FillUserInfoPageState();
}

class _FillUserInfoPageState extends State<StudentUserInfoPage> {
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _realNameController = TextEditingController();
  final TextEditingController _schoolController = TextEditingController();
  final TextEditingController _classController = TextEditingController();
  final TextEditingController _studentIDController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  String _selectedGender = "";

  List<String> _selectedSubjects = [];

  List<String> _subjects = []; // ✅ 先声明为空列表
  /// **提交用户信息到后端**
  Future<void> _submitUserInfo() async {
    if (_nicknameController.text.isEmpty ||
        _realNameController.text.isEmpty ||
        _schoolController.text.isEmpty ||
        _classController.text.isEmpty ||
        _studentIDController.text.isEmpty ||
        _ageController.text.isEmpty ||
        _selectedGender.isEmpty ||
        _selectedSubjects.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(AppLocalizations.of(context)!.pleaseFillAllFields)),
      );
      return;
    }
    Future<void> loginAfterSubmit(String username, String token) async {
      final checkUrl = Uri.parse("$baseApiUrl/login/check");
      final headers = {
        "Username": username,
        "Token": token,
      };

      try {
        final response = await http.get(checkUrl, headers: headers);

        print("🔹 [CHECK LOGIN] Status: ${response.statusCode}");
        print("🔹 [CHECK LOGIN] Body: ${response.body}");

        if (response.statusCode == 204) {
          // **用户信息不完整，仍然留在 `FillUserInfoPage`**
          print("❌ 用户信息仍然不完整");
        } else if (response.statusCode == 200) {
          // **用户信息完整，解析数据并跳转**
          var userInfo = jsonDecode(response.body);
          String role = username.startsWith('t') ? 'Teacher' : 'Student';

          if (role == 'Teacher') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => TeacherChooseClassPage(
                  teacherName: username,
                  classes: userInfo["classes"] ?? [],
                ),
              ),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => StudentTermsPage(
                  username: widget.username,
            token: widget.token,
                ),
              ),
            );
          }
        } else {
          print("❌ 服务器返回错误: ${response.statusCode}");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.networkError)),
          );
        }
      } catch (e) {
        print("❌ 登录检查失败: $e");
      }
    }

    final url = Uri.parse("$baseApiUrl/login/signup/setinfo");
    final headers = {
      "Content-Type": "application/json",
      "Username": widget.username,
      "Token": widget.token,
    };

    final body = jsonEncode({
      "nickname": _nicknameController.text,
      "realName": _realNameController.text,
      "school": _schoolController.text,
      "className": _classController.text,
      "studentId": _studentIDController.text,
      "gender": _selectedGender,
      "age": int.parse(_ageController.text),
      "subjects": _selectedSubjects.join(","),
      "studentConsent": true,
      "guardianConsent": true
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      print("🔹 [RESPONSE STATUS]: ${response.statusCode}");
      print("🔹 [RESPONSE BODY]: ${response.body}");

      if (response.body.isEmpty) {
        print("❌ 服务器返回了空响应");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.networkError)),
        );
        return;
      }

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text(AppLocalizations.of(context)!.registrationSuccessful)),
        );

        // ✅ **存储 token 以便自动登录**
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', widget.token);
        await prefs.setString('username', widget.username);

        // ✅ **提交成功后自动登录**
        await loginAfterSubmit(widget.username, widget.token);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(responseBody["error"] ??
                  AppLocalizations.of(context)!.registrationFailed)),
        );
      }
    } catch (e) {
      print("❌ 网络错误: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.networkError)),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    // ✅ 在 initState 之后访问 context
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _subjects = [
          AppLocalizations.of(context).history,
          AppLocalizations.of(context).geography,
          AppLocalizations.of(context).politics,
          AppLocalizations.of(context).physics,
          AppLocalizations.of(context).chemistry,
          AppLocalizations.of(context).biology,
          AppLocalizations.of(context).mathematics,
          AppLocalizations.of(context).psychology,
          AppLocalizations.of(context).sociology,
          AppLocalizations.of(context).economics,
          AppLocalizations.of(context).finance,
          AppLocalizations.of(context).literature,
          AppLocalizations.of(context).cs,
          AppLocalizations.of(context).other,
        ];
      });
    });
  }

  void _toggleSubject(String subject) {
    setState(() {
      if (_selectedSubjects.contains(subject)) {
        _selectedSubjects.remove(subject);
      } else {
        _selectedSubjects.add(subject);
      }
    });
  }

  Widget _buildGenderSelector(double scaleX) {
    double fontSize = 20 * scaleX;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppLocalizations.of(context).gender,
            style: TextStyle(fontSize: fontSize)),
        Wrap(
          spacing: 20 * scaleX, // 控制选项之间的间距
          runSpacing: 10 * scaleX, // 防止换行时紧贴
          children: [
            _buildGenderOption(
                AppLocalizations.of(context).male, fontSize, scaleX),
            _buildGenderOption(
                AppLocalizations.of(context).female, fontSize, scaleX),
            _buildGenderOption(
                AppLocalizations.of(context).preferNotToSay, fontSize, scaleX),
          ],
        ),
      ],
    );
  }

  Widget _buildGenderOption(String gender, double fontSize, double scaleX) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5 * scaleX), // 让每个选项都有适当的间距
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Transform.scale(
            scale: scaleX, // 让Radio按钮随着屏幕大小缩放
            child: Radio(
              value: gender,
              groupValue: _selectedGender,
              onChanged: (value) {
                setState(() {
                  _selectedGender = value.toString();
                });
              },
            ),
          ),
          Text(gender, style: TextStyle(fontSize: fontSize)),
        ],
      ),
    );
  }

  Widget _buildSubjectButtons(double scaleX) {
    if (_subjects.isEmpty) {
      return CircularProgressIndicator(); // ✅ 防止 UI 访问空数组导致崩溃
    }
    double fontSize = 18 * scaleX;
    return SizedBox(
      width: 450 * scaleX, // 让科目选项和输入框宽度一致
      child: Wrap(
        alignment: WrapAlignment.start, // 让选项对齐左侧
        spacing: 10 * scaleX, // 控制选项之间的水平间距
        runSpacing: 10 * scaleX, // 控制换行间距
        children: _subjects
            .map((subject) => GestureDetector(
                  onTap: () => _toggleSubject(subject),
                  child: Container(
                    width: 140 * scaleX, // 控制每个科目按钮的宽度，避免超出换行
                    padding: EdgeInsets.symmetric(
                        vertical: 10 * scaleX, horizontal: 10 * scaleX),
                    decoration: BoxDecoration(
                      color: _selectedSubjects.contains(subject)
                          ? Colors.blue
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(8 * scaleX),
                    ),
                    child: Center(
                      child: Text(
                        subject,
                        style: TextStyle(
                          color: _selectedSubjects.contains(subject)
                              ? Colors.white
                              : Colors.black,
                          fontSize: fontSize,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, double scaleX,
      {TextInputType keyboardType = TextInputType.text}) {
    double fontSize = 20 * scaleX;
    return SizedBox(
      width: 450 * scaleX,
      height: 68 * scaleX,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: TextStyle(fontSize: fontSize),
        decoration: InputDecoration(
          filled: true,
          fillColor: const Color(0xFFECECEC),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8 * scaleX),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 20 * scaleX),
          labelText: label,
          labelStyle: TextStyle(fontSize: fontSize),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double baseWidth = 2160;
    double scaleX = screenWidth / baseWidth;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: screenWidth,
            padding: EdgeInsets.symmetric(vertical: 20 * scaleX),
            decoration: const BoxDecoration(color: Colors.white),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  AppLocalizations.of(context).fillInfoTitle,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 48 * scaleX,
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 20 * scaleX),
                _buildTextField(_nicknameController,
                    AppLocalizations.of(context).nickname, scaleX),
                SizedBox(height: 20 * scaleX),
                _buildTextField(_realNameController,
                    AppLocalizations.of(context).realName, scaleX),
                SizedBox(height: 20 * scaleX),
                _buildTextField(_schoolController,
                    AppLocalizations.of(context).school, scaleX),
                SizedBox(height: 20 * scaleX),
                _buildTextField(_classController,
                    AppLocalizations.of(context).className, scaleX),
                SizedBox(height: 20 * scaleX),
                _buildTextField(_studentIDController,
                    AppLocalizations.of(context).studentID, scaleX),
                SizedBox(height: 20 * scaleX),
                _buildTextField(
                    _ageController, AppLocalizations.of(context).age, scaleX,
                    keyboardType: TextInputType.number),
                SizedBox(height: 20 * scaleX),
                SizedBox(
                  width: 450 * scaleX,
                  child: _buildGenderSelector(scaleX),
                ),
                SizedBox(height: 20 * scaleX),
                SizedBox(
                  width: 450 * scaleX, // 确保和输入框对齐
                  child: Text(
                    AppLocalizations.of(context).selectSubjects,
                    style: TextStyle(fontSize: 20 * scaleX),
                    textAlign: TextAlign.left,
                  ),
                ),
                SizedBox(height: 10 * scaleX),
                _buildSubjectButtons(scaleX),
                SizedBox(height: 40 * scaleX),
                ElevatedButton(
                  onPressed: _submitUserInfo,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8 * scaleX),
                    ),
                    backgroundColor: const Color(0xFF292929),
                    padding: EdgeInsets.symmetric(
                        vertical: 16 * scaleX, horizontal: 80 * scaleX),
                  ),
                  child: Text(AppLocalizations.of(context).submit,
                      style: TextStyle(
                          color: Colors.white, fontSize: 20 * scaleX)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
