import 'package:flutter/material.dart';
import 'package:flutter_project/pages/student_version/student_choose_class.dart';

class StudentTermsPage extends StatefulWidget {
  final String username;
  final String token;

  const StudentTermsPage({
    super.key,
    required this.username,
    required this.token,
  });

  @override
  State<StudentTermsPage> createState() => _StudentTermsPageState();
}

class _StudentTermsPageState extends State<StudentTermsPage> {
  // 条款列表（前7条必选）
  final List<_TermItem> _terms = [
    _TermItem("我已阅读关于本研究的信息，理解并同意（我的孩子）参与本次研究。", required: true),
    _TermItem("我明白参加本研究是自愿的，我/我的孩子可在任何时候退出。", required: true),
    _TermItem("我同意对课堂讨论或学习活动进行视频/音频录制（不会录到学生正脸，如有出现，研究者会通过贴纸进行处理）。",
        required: true),
    _TermItem("我同意收集我/我孩子的课堂作业、家庭作业或游戏任务数据。", required: true),
    _TermItem("我同意完成/让我的孩子完成问卷（关于科学兴趣、交流与推理）。", required: true),
    _TermItem("我理解我所有回答都会被保密并匿名处理。", required: true),
    _TermItem("我理解匿名化数据将存储在研究者受密码保护的剑桥大学 OneDrive 中。", required: true),
    _TermItem("我同意参加/我的孩子参加课后简短的访谈或小组讨论。"),
    _TermItem("我希望收到一份我/我孩子的问卷结果简要总结。"),
  ];

  // 勾选状态
  late List<bool> _student = List<bool>.filled(9, false);
  late List<bool> _guardian = List<bool>.filled(9, false);

  bool get _requiredChecked {
    for (int i = 0; i < 7; i++) {
      if (!_student[i] || !_guardian[i]) return false;
    }
    return true;
  }

  void _onContinue() {
    if (!_requiredChecked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("请在前七项必选条款中，学生与家长/监护人均打勾 ✔")),
      );
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => StudentChooseClassPage(studentName: widget.username),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final baseWidth = 2160.0;
    final scaleX = w / baseWidth;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1200),
            padding: EdgeInsets.all(32 * scaleX),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Text(
                    "学生-家长知情同意书",
                    style: TextStyle(
                        fontSize: 48 * scaleX, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24 * scaleX),
                  Text(
                    "在填写本同意书并决定是否参与本次研究之前，请您与您的孩子务必仔细阅读并充分理解随附的信息说明。如有任何疑问，欢迎通过电子邮件（qz329@cam.ac.uk）联系研究者（我）进行咨询。\n"
                    "本同意书特别声明：您和您的孩子可以自主选择是否参与本研究的全部、部分或任何一项活动。无论作出何种决定，均不会影响您孩子在校的课程参与或学业评价。\n\n"
                    "请在下列表格中的“学生”及“家长/监护人”两栏内相应的方框内打勾“✔”。\n"
                    "请注意：前七项为参与课堂任务程序的必要条款。如您不同意其中任一项，可能无法使用该程序参与本次课堂任务，但孩子仍可参与课堂中的其他互动环节。\n",
                    style: TextStyle(fontSize: 26 * scaleX, height: 1.6),
                  ),
                  SizedBox(height: 20 * scaleX),
                  _buildConsentTable(scaleX),
                  SizedBox(height: 20 * scaleX),
                  ElevatedButton(
                    onPressed: _onContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _requiredChecked ? Colors.blue : Colors.grey,
                      padding: EdgeInsets.symmetric(
                          vertical: 20 * scaleX, horizontal: 60 * scaleX),
                    ),
                    child: Text("继续",
                        style: TextStyle(
                            fontSize: 32 * scaleX, color: Colors.white)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildConsentTable(double scaleX) {
    return Table(
      columnWidths: {
        0: const FlexColumnWidth(6),
        1: FixedColumnWidth(140 * scaleX),
        2: FixedColumnWidth(200 * scaleX),
      },
      border: TableBorder.all(color: const Color(0xFFE0E0E0), width: 1),
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        // 表头
        TableRow(
          decoration: const BoxDecoration(color: Color(0xFFF7F7F7)),
          children: [
            Padding(
              padding: EdgeInsets.all(12 * scaleX),
              child: Text("条款内容",
                  style: TextStyle(
                      fontSize: 26 * scaleX, fontWeight: FontWeight.bold)),
            ),
            Center(
                child: Text("学生",
                    style: TextStyle(
                        fontSize: 24 * scaleX, fontWeight: FontWeight.bold))),
            Center(
                child: Text("家长/监护人",
                    style: TextStyle(
                        fontSize: 24 * scaleX, fontWeight: FontWeight.bold))),
          ],
        ),
        for (int i = 0; i < _terms.length; i++)
          TableRow(
            children: [
              Padding(
                padding: EdgeInsets.all(12 * scaleX),
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                        fontSize: 24 * scaleX,
                        color: Colors.black,
                        height: 1.4),
                    children: [
                      TextSpan(text: "${i + 1}. ${_terms[i].text}"),
                      if (_terms[i].required)
                        TextSpan(
                            text: "  *",
                            style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              Center(
                child: Checkbox(
                  value: _student[i],
                  onChanged: (v) => setState(() => _student[i] = v ?? false),
                ),
              ),
              Center(
                child: Checkbox(
                  value: _guardian[i],
                  onChanged: (v) => setState(() => _guardian[i] = v ?? false),
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class _TermItem {
  final String text;
  final bool required;
  const _TermItem(this.text, {this.required = false});
}
