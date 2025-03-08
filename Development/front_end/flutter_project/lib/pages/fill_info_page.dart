import 'package:flutter/material.dart';

class FillUserInfoPage extends StatefulWidget {
  @override
  _FillUserInfoPageState createState() => _FillUserInfoPageState();
}

class _FillUserInfoPageState extends State<FillUserInfoPage> {
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _realNameController = TextEditingController();
  final TextEditingController _schoolController = TextEditingController();
  final TextEditingController _classController = TextEditingController();
  final TextEditingController _studentIDController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  String _selectedGender = "";
  final List<String> _subjects = ["Math", "Science", "History", "Art", "Music", "PE", "English"];
  List<String> _selectedSubjects = [];

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
        Text("Gender:", style: TextStyle(fontSize: fontSize)),
        Wrap(
          spacing: 20 * scaleX, // 控制选项之间的间距
          runSpacing: 10 * scaleX, // 防止换行时紧贴
          children: [
            _buildGenderOption("Male", fontSize, scaleX),
            _buildGenderOption("Female", fontSize, scaleX),
            _buildGenderOption("Prefer not to say", fontSize, scaleX),
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
    double fontSize = 18 * scaleX;
    return SizedBox(
      width: 450 * scaleX, // 让科目选项和输入框宽度一致
      child: Wrap(
        alignment: WrapAlignment.start, // 让选项对齐左侧
        spacing: 10 * scaleX, // 控制选项之间的水平间距
        runSpacing: 10 * scaleX, // 控制换行间距
        children: _subjects.map((subject) => GestureDetector(
          onTap: () => _toggleSubject(subject),
          child: Container(
            width: 140 * scaleX, // 控制每个科目按钮的宽度，避免超出换行
            padding: EdgeInsets.symmetric(vertical: 10 * scaleX, horizontal: 10 * scaleX),
            decoration: BoxDecoration(
              color: _selectedSubjects.contains(subject) ? Colors.blue : Colors.grey[300],
              borderRadius: BorderRadius.circular(8 * scaleX),
            ),
            child: Center(
              child: Text(
                subject,
                style: TextStyle(
                  color: _selectedSubjects.contains(subject) ? Colors.white : Colors.black,
                  fontSize: fontSize,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        )).toList(),
      ),
    );
  }
  Widget _buildTextField(TextEditingController controller, String label, double scaleX, {TextInputType keyboardType = TextInputType.text}) {
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
                  '信息',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 48 * scaleX,
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 20 * scaleX),
                _buildTextField(_nicknameController, "Nickname", scaleX),
                SizedBox(height: 20 * scaleX),
                _buildTextField(_realNameController, "Real Name", scaleX),
                SizedBox(height: 20 * scaleX),
                _buildTextField(_schoolController, "School", scaleX),
                SizedBox(height: 20 * scaleX),
                _buildTextField(_classController, "Class", scaleX),
                SizedBox(height: 20 * scaleX),
                _buildTextField(_studentIDController, "Student ID", scaleX),
                SizedBox(height: 20 * scaleX),
                _buildTextField(_ageController, "Age", scaleX, keyboardType: TextInputType.number),
                SizedBox(height: 20 * scaleX),
SizedBox(
  width: 450 * scaleX,
  child: _buildGenderSelector(scaleX),
),
SizedBox(height: 20 * scaleX),
                SizedBox(
  width: 450 * scaleX, // 确保和输入框对齐
  child: Text("Select Subjects:",
    style: TextStyle(fontSize: 20 * scaleX),
    textAlign: TextAlign.left,
  ),
),
SizedBox(height: 10 * scaleX),
                _buildSubjectButtons(scaleX),
                SizedBox(height: 40 * scaleX),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8 * scaleX),
                    ),
                    backgroundColor: const Color(0xFF292929),
                    padding: EdgeInsets.symmetric(vertical: 16 * scaleX, horizontal: 80 * scaleX),
                  ),
                  child: Text('Submit', style: TextStyle(color: Colors.white, fontSize: 20 * scaleX)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
