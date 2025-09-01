import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_project/pages/login.dart';
import 'package:flutter_project/pages/student_version/student_choose_class.dart';
import 'package:flutter_project/pages/student_version/student_terms_page.dart';
import 'package:flutter_project/pages/teacher_version/teacher_choose_class.dart';
import 'package:flutter_project/utils/color.dart';
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
  final TextEditingController _mobileController = TextEditingController();

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
        _mobileController.text.isEmpty ||
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
      "mobile": _mobileController.text,
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

 Widget _buildGenderDropdown(double scaleX) {
  final double fontSize = 30 * scaleX;
  final double fieldHeight = 92 * scaleX;
  final double vPad = 18 * scaleX;

  final items = <String>[
    AppLocalizations.of(context).male,
    AppLocalizations.of(context).female,
    AppLocalizations.of(context).preferNotToSay,
  ];
  final String? value = _selectedGender.isEmpty ? null : _selectedGender;

  return SizedBox(
    width: 600 * scaleX,
    height: fieldHeight,
    child: DropdownButtonFormField<String>(
      value: value,
      items: items
          .map((g) => DropdownMenuItem(
                value: g,
                child: Text(g, style: TextStyle(fontSize: fontSize)),
              ))
          .toList(),
      onChanged: (v) => setState(() => _selectedGender = v ?? ""),
      dropdownColor: Colors.white,  // ✅ 下拉菜单背景色改为白色
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.inputBackgroundColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10 * scaleX),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 20 * scaleX,
          vertical: vPad,
        ),
        labelText: AppLocalizations.of(context).gender,
        labelStyle: TextStyle(fontSize: fontSize),
        floatingLabelStyle: TextStyle(
          fontSize: (fontSize * 1.15),
          fontWeight: FontWeight.w700,
          color: Colors.black87,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        isDense: false,
      ),
      isExpanded: true,
      icon: const Icon(Icons.keyboard_arrow_down),
      style: TextStyle(fontSize: fontSize, color: Colors.black),
    ),
  );
}


  Widget _buildSubjectButtons(double scaleX) {
    if (_subjects.isEmpty) return const CircularProgressIndicator();

    final double fontSize = 34 * scaleX;

    return SizedBox(
      width: 600 * scaleX, // 建议与上面的输入框同宽
      child: GridView.count(
        crossAxisCount: 4, // ← 一行 4 个
        crossAxisSpacing: 12 * scaleX, // 水平间距
        mainAxisSpacing: 12 * scaleX, // 垂直间距
        shrinkWrap: true, // 放在外层的 SingleChildScrollView 里
        physics: const NeverScrollableScrollPhysics(), // 交给外层滚动
        childAspectRatio: 1.6, // 宽高比(可按需微调 1.8~2.6)
        children: _subjects.map((subject) {
          final bool selected = _selectedSubjects.contains(subject);
          return GestureDetector(
            onTap: () => _toggleSubject(subject),
            child: Container(
              // Grid 会自动算宽高，这里不需要再写 width / height
              padding: EdgeInsets.symmetric(
                vertical: 16 * scaleX,
                horizontal: 12 * scaleX,
              ),
              decoration: BoxDecoration(
                color: selected ? Colors.blue : AppColors.inputBackgroundColor,
                borderRadius: BorderRadius.circular(12 * scaleX),
              ),
              child: Center(
                child: Text(
                  subject,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: selected ? Colors.white : Colors.black,
                    fontSize: fontSize,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    double scaleX, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    final double fontSize = 30 * scaleX;
    final double fieldHeight = 92 * scaleX; // ← 比原来 75*scaleX 高一截
    final double vPad = 20 * scaleX; // ← 上下内边距，直接决定高度

    return SizedBox(
      width: 600 * scaleX,
      height: fieldHeight,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: TextStyle(fontSize: fontSize),
        textAlignVertical: TextAlignVertical.center, // ← 垂直居中
        decoration: InputDecoration(
          filled: true,
          fillColor: AppColors.inputBackgroundColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10 * scaleX),
            borderSide: BorderSide.none,
          ),
          // 关键：上下 padding 增大 → 输入框更高
          contentPadding: EdgeInsets.symmetric(
            horizontal: 20 * scaleX,
            vertical: vPad,
          ),
          labelText: label,
          labelStyle: TextStyle(fontSize: fontSize),
          floatingLabelStyle: TextStyle(
            fontSize: (fontSize * 1.15),
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          isDense: false, // 确保不压缩高度
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double baseWidth = 2160;
    double scaleX = screenWidth / baseWidth;
    final double vGap = 32 * scaleX;

    return Scaffold(
      backgroundColor: Colors.white,
      //测试使用跳过fillinfo
      /*
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => StudentChooseClassPage(
                  studentName: widget.username,
                ),
              ),
            );
          },
        ),
      ),
      */
      appBar: AppBar(
  backgroundColor: AppColors.background,
  elevation: 0,
  leading: IconButton(
    icon: const Icon(Icons.arrow_back, color: Colors.black),
    onPressed: () {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false, // 清空导航栈，防止再返回
      );
    },
  ),
),

      //结束
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: screenWidth,
            padding: EdgeInsets.symmetric(vertical: 20 * scaleX),
            decoration: const BoxDecoration(color: AppColors.background),
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
                SizedBox(height: vGap),
                _buildTextField(_nicknameController,
                    AppLocalizations.of(context).nickname, scaleX),
                SizedBox(height: vGap),
                _buildTextField(_realNameController,
                    AppLocalizations.of(context).realName, scaleX),
                SizedBox(height: vGap),
                _buildTextField(_schoolController,
                    AppLocalizations.of(context).school, scaleX),
                SizedBox(height: vGap),
                _buildTextField(_classController,
                    AppLocalizations.of(context).className, scaleX),
                SizedBox(height: vGap),
                _buildTextField(_studentIDController,
                    AppLocalizations.of(context).studentID, scaleX),
                SizedBox(height: vGap),
                _buildTextField(_mobileController,
                    AppLocalizations.of(context).mobile, scaleX,
                    keyboardType: TextInputType.phone),
                SizedBox(height: vGap),
                _buildTextField(
                    _ageController, AppLocalizations.of(context).age, scaleX,
                    keyboardType: TextInputType.number),
                SizedBox(height: vGap),
                SizedBox(
                  width: 600 * scaleX,
                  child: _buildGenderDropdown(scaleX),
                ),
                SizedBox(height: vGap),
                SizedBox(
                  width: 600 * scaleX, // 确保和输入框对齐
                  child: Text(
                    AppLocalizations.of(context).selectSubjects,
                    style: TextStyle(fontSize: 30 * scaleX),
                    textAlign: TextAlign.left,
                  ),
                ),
                SizedBox(height: vGap * 0.6),
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
                          color: Colors.white, fontSize: 40 * scaleX)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
