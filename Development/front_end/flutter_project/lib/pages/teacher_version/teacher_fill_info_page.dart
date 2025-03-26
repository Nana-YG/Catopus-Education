import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_project/pages/teacher_version/teacher_choose_class.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_project/generated/app_localizations.dart';
import 'package:flutter_project/utils/constant.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TeacherUserInfoPage extends StatefulWidget {
  final String username; // ✅ 教师用户名
  final String token; // ✅ 登录 Token

  const TeacherUserInfoPage(
      {super.key, required this.username, required this.token});

  @override
  _TeacherUserInfoPageState createState() => _TeacherUserInfoPageState();
}

class _TeacherUserInfoPageState extends State<TeacherUserInfoPage> {
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _realNameController = TextEditingController();
  final TextEditingController _schoolController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();
  final TextEditingController _yearsExperienceController =
      TextEditingController();

  String _selectedGender = "";
  bool _isLoading = false;

  /// **✅ 提交教师信息到后端**
  Future<void> _submitTeacherInfo() async {
    if (_nicknameController.text.isEmpty ||
        _realNameController.text.isEmpty ||
        _schoolController.text.isEmpty ||
        _departmentController.text.isEmpty ||
        _yearsExperienceController.text.isEmpty ||
        _selectedGender.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(AppLocalizations.of(context)!.pleaseFillAllFields)),
      );
      return;
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
      "department": _departmentController.text,
      "yearsExperience": int.parse(_yearsExperienceController.text),
      "gender": _selectedGender,
      "teacherConsent": true
    });

    try {
      setState(() {
        _isLoading = true;
      });

      final response = await http.post(url, headers: headers, body: body);
      final responseBody = jsonDecode(response.body);

      print("🔹 [RESPONSE STATUS]: ${response.statusCode}");
      print("🔹 [RESPONSE BODY]: ${response.body}");

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

        // ✅ **提交成功后自动跳转到 `TeacherChooseClassPage`**
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => TeacherChooseClassPage(
              teacherName: widget.username,
              classes: [],
            ),
          ),
        );
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
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildGenderSelector(double scaleX) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppLocalizations.of(context)!.gender,
            style: TextStyle(fontSize: 20 * scaleX)),
        Wrap(
          spacing: 20 * scaleX,
          runSpacing: 10 * scaleX,
          children: [
            _buildGenderOption(AppLocalizations.of(context)!.male, scaleX),
            _buildGenderOption(AppLocalizations.of(context)!.female, scaleX),
            _buildGenderOption(
                AppLocalizations.of(context)!.preferNotToSay, scaleX),
          ],
        ),
      ],
    );
  }

  Widget _buildGenderOption(String gender, double scaleX) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Radio(
          value: gender,
          groupValue: _selectedGender,
          onChanged: (value) {
            setState(() {
              _selectedGender = value.toString();
            });
          },
        ),
        Text(gender, style: TextStyle(fontSize: 18 * scaleX)),
      ],
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, double scaleX,
      {TextInputType keyboardType = TextInputType.text}) {
    return SizedBox(
      width: 450 * scaleX,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          filled: true,
          fillColor: const Color(0xFFECECEC),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8 * scaleX),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 20 * scaleX),
          labelText: label,
          labelStyle: TextStyle(fontSize: 18 * scaleX),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  AppLocalizations.of(context)!.fillInfoTitle,
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 48 * scaleX,
                      fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 20 * scaleX),
                _buildTextField(_nicknameController,
                    AppLocalizations.of(context)!.nickname, scaleX),
                SizedBox(height: 20 * scaleX),
                _buildTextField(_realNameController,
                    AppLocalizations.of(context)!.realName, scaleX),
                _buildTextField(_schoolController,
                    AppLocalizations.of(context)!.school, scaleX),
                SizedBox(height: 20 * scaleX),
                SizedBox(height: 20 * scaleX),
                _buildGenderSelector(scaleX),
                SizedBox(height: 40 * scaleX),
                ElevatedButton(
                  onPressed: _submitTeacherInfo,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF292929),
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(AppLocalizations.of(context)!.submit,
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
