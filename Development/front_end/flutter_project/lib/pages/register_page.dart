import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_project/generated/app_localizations.dart';
import 'package:flutter_project/pages/student_version/student_fill_info_page.dart';
import 'package:flutter_project/pages/login.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_project/utils/constant.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_project/utils/color.dart';

class RegisterPage extends StatefulWidget {
  final String userType;

  const RegisterPage({super.key, required this.userType});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _magicWordController = TextEditingController();
  // ✅ 新增：焦点管理，支持“下一项/完成”
  final FocusNode _userFocus = FocusNode();
  final FocusNode _passFocus = FocusNode();
  final FocusNode _magicFocus = FocusNode();

  bool _isLoading = false;
  bool _obscurePassword = true; // 密码是否隐藏（初始隐藏）

  Future<void> _register() async {
    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();
    String magicWord = _magicWordController.text.trim(); // 🔸 新增

    if (username.isEmpty || password.isEmpty || magicWord.isEmpty) {
      // 🔸 校验包含 magicWord
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(AppLocalizations.of(context).pleaseFillAllFields)),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final url = Uri.parse("$baseApiUrl/login/signup");

      final headers = {
        "username": username,
        "password": password,
        "accountType": widget.userType.toUpperCase(), // 确保是 STUDENT 或 TEACHER
        "magicWord": magicWord,
      };

      // 🔍 可选调试输出
      print("📤 正在发送注册请求 headers: $headers");

      final response = await http.post(url, headers: headers);

      setState(() {
        _isLoading = false;
      });

      print("🔵 Response (${response.statusCode}): ${response.body}");

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final token = responseBody["token"];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        await prefs.setString('username', username);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text(AppLocalizations.of(context).registrationSuccessful)),
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StudentUserInfoPage(
              username: username,
              token: token,
            ),
          ),
        );
      } else {
        // 注册失败，例如用户名已存在
        final serverMsg = (responseBody["message"] as String?)?.trim();
        final errorMsg = (serverMsg != null &&
                serverMsg.toLowerCase() ==
                    "username already taken".toLowerCase())
            ? AppLocalizations.of(context).usernameTaken
            : (serverMsg ?? AppLocalizations.of(context).registrationFailed);

        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(errorMsg)));
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Unexpected error: $e")),
      );
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _magicWordController.dispose();
    _userFocus.dispose();
    _passFocus.dispose();
    _magicFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double baseWidth = 2160;
    double baseHeight = 1080;
    double scaleX = screenWidth / baseWidth;
    double scaleY = screenHeight / baseHeight;
    double inputHeight = screenHeight * 0.08;
    double rightShift = screenWidth * 0.20;
    final double gap = 32 * scaleX;
    final double buttonWidth = (screenWidth * 0.284 - gap) / 2;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          width: screenWidth,
          height: screenHeight,
          decoration: const BoxDecoration(color: AppColors.background),
          child: GestureDetector(
            behavior: HitTestBehavior.translucent, // 透明区域也能点到
            onTap: () => FocusScope.of(context).unfocus(),
            child: Stack(
              children: [
                // 背景三层卡片
                Positioned(
                  left: (-240 * scaleX),
                  top: -80 * scaleY,
                  child: Container(
                    transform: Matrix4.identity()..rotateZ(0.09),
                    width: 1278.26 * scaleX,
                    height: 1300.66 * scaleY,
                    decoration: ShapeDecoration(
                      color: Colors.white,
                      shape:
                          RoundedRectangleBorder(side: BorderSide(width: 1.5)),
                      shadows: [
                        BoxShadow(
                          color: Color(0x3F000000),
                          blurRadius: 35,
                          offset: Offset(4, 4),
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: -260 * scaleX,
                  top: -100 * scaleY,
                  child: Container(
                    transform: Matrix4.identity()..rotateZ(0.09),
                    width: 1278.26 * scaleX,
                    height: 1300.66 * scaleY,
                    decoration: ShapeDecoration(
                      color: Colors.white,
                      shape:
                          RoundedRectangleBorder(side: BorderSide(width: 1.5)),
                      shadows: [
                        BoxShadow(
                          color: Color(0x3F000000),
                          blurRadius: 35,
                          offset: Offset(4, 4),
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: -280 * scaleX,
                  top: -125 * scaleY,
                  child: Container(
                    transform: Matrix4.identity()..rotateZ(0.09),
                    width: 1278.26 * scaleX,
                    height: 1300.66 * scaleY,
                    decoration: ShapeDecoration(
                      color: Colors.white,
                      shape:
                          RoundedRectangleBorder(side: BorderSide(width: 1.5)),
                      shadows: [
                        BoxShadow(
                          color: Color(0x3F000000),
                          blurRadius: 35,
                          offset: Offset(4, 4),
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                  ),
                ),
                // 插图
                Positioned(
                  left: -100 * scaleX,
                  top: 60 * scaleY,
                  child: SizedBox(
                    width: 976 * scaleX,
                    height: 976 * scaleY,
                    child: Image.asset(
                      'assets/images/circle.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),

                // ✅ 右半边滚动容器：保持原始位置与宽度，仅右区可滚动
                // ✅ 右半边滚动容器：位置微调 + 输入框更大 + 间距优化
                Positioned(
                  // 往左一点（-24 * scaleX），保留你原本的 rightShift 布局基准
                  left: (855 * scaleX + rightShift) - 40 * scaleX, // ← 往左一点
                  // 往上一点（-24 * scaleY）
                  top: -70 * scaleY, // ← 往上一点
                  // 右侧面板稍微加宽（原 0.284 → 0.30），让输入框“更大一点”
                  width: screenWidth * 0.30, // ← 更宽
                  bottom: 0,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () => FocusScope.of(context).unfocus(),
                    child: SingleChildScrollView(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                      ),
                      child: Builder(builder: (context) {
                        // 只在右侧把输入高度放大 12%
                        final double inputHeightRight =
                            inputHeight * 1.12; // ← 更高
                        // 调大内部可滚高度，避免滚到底部裁剪
                        final double scrollContentHeight = 1300 * scaleY;

                        return SizedBox(
                          height: scrollContentHeight,
                          child: Stack(
                            children: [
                              // ===== 标题（保持你的原始 top，只因整体容器已向上移动 24*scaleY） =====
                              Positioned(
                                left: 0,
                                top: 234 * scaleY,
                                child: Text(
                                  '${AppLocalizations.of(context).registerAs} ${widget.userType}',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 48 * scaleX,
                                    fontFamily: 'Manrope',
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),

                              // ===== 用户名 =====
                              Positioned(
                                left: 0,
                                top: 354 * scaleY,
                                child: Text(
                                  AppLocalizations.of(context).name,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 32 * scaleX,
                                    fontFamily: 'Manrope',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 0,
                                top: 413 * scaleY,
                                child: SizedBox(
                                  width: screenWidth * 0.30, // 跟随右侧面板宽度
                                  height: inputHeightRight, // ← 更高
                                  child: TextField(
                                    controller: _usernameController,
                                    focusNode: _userFocus,
                                    textInputAction: TextInputAction.next,
                                    onSubmitted: (_) =>
                                        _passFocus.requestFocus(),
                                    textAlignVertical: TextAlignVertical.center,
                                    style: TextStyle(fontSize: 30 * scaleX),
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: AppColors.inputBackgroundColor,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide.none,
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 20),
                                      hintText: AppLocalizations.of(context)
                                          .enterYourName,
                                      hintStyle: const TextStyle(
                                          color: Colors.black45),
                                    ),
                                  ),
                                ),
                              ),

                              // ===== 密码 =====
                              Positioned(
                                left: 0,
                                top: 515 * scaleY,
                                child: Text(
                                  AppLocalizations.of(context).password,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 32 * scaleX,
                                    fontFamily: 'Manrope',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 0,
                                top: 573 * scaleY,
                                child: SizedBox(
                                  width: screenWidth * 0.30,
                                  height: inputHeightRight, // ← 更高
                                  child: TextField(
                                    controller: _passwordController,
                                    focusNode: _passFocus,
                                    textInputAction: TextInputAction.next,
                                    onSubmitted: (_) =>
                                        _magicFocus.requestFocus(),
                                    obscureText:
                                        _obscurePassword, // ← 用变量控制显示/隐藏
                                    textAlignVertical: TextAlignVertical.center,
                                    style: TextStyle(fontSize: 30 * scaleX),
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: AppColors.inputBackgroundColor,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide.none,
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 20),
                                      hintText: AppLocalizations.of(context)
                                          .enterYourPassword,
                                      hintStyle: const TextStyle(
                                          color: Colors.black45),

                                      // 👇 右侧加个小眼睛按钮，不带文字
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscurePassword
                                              ? Icons.visibility_off
                                              : Icons.visibility,
                                          color: Colors.grey,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _obscurePassword =
                                                !_obscurePassword; // 切换密码可见性
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              // ===== Magic Word =====
                              Positioned(
                                left: 0,
                                top: (573 * scaleY +
                                    inputHeightRight +
                                    30 * scaleY), // 用放大后的高度
                                child: Text(
                                  AppLocalizations.of(context).magicWord,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 32 * scaleX,
                                    fontFamily: 'Manrope',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 0,
                                top: (573 * scaleY +
                                    inputHeightRight +
                                    30 * scaleY +
                                    58 * scaleY),
                                child: SizedBox(
                                  width: screenWidth * 0.30,
                                  height: inputHeightRight, // ← 更高
                                  child: TextField(
                                    controller: _magicWordController,
                                    focusNode: _magicFocus,
                                    textInputAction: TextInputAction.done,
                                    onSubmitted: (_) => _register(),
                                    obscureText: false,
                                    autocorrect: false,
                                    enableSuggestions: false,
                                    textAlignVertical: TextAlignVertical.center,
                                    style: TextStyle(fontSize: 30 * scaleX),
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: AppColors.inputBackgroundColor,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide.none,
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 20),
                                      hintText: AppLocalizations.of(context)
                                          .enterYourMagicWord,
                                      hintStyle: const TextStyle(
                                          color: Colors.black45),
                                    ),
                                  ),
                                ),
                              ),

                              // ===== 已有账号？登录（保持原位置计算） =====
                              Positioned(
                                left: 0,
                                top: (573 * scaleY +
                                    inputHeightRight // 用放大后的高度
                                    +
                                    30 * scaleY +
                                    58 * scaleY +
                                    inputHeightRight // 用放大后的高度
                                    +
                                    20 * scaleY),
                                child: SizedBox(
                                  width: screenWidth * 0.30,
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const LoginPage()),
                                        );
                                      },
                                      child: Text(
                                        AppLocalizations.of(context)
                                            .alreadyHaveAccount,
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 24 * scaleX,
                                          fontFamily: 'Manrope',
                                          fontWeight: FontWeight.w400,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              // ===== 按钮区：与“已有账号？登录”拉开更大距离（40 → 64） =====
                              Positioned(
                                left: 0,
                                top: (573 * scaleY +
                                    inputHeightRight // 密码输入框高度（放大后）
                                    +
                                    30 * scaleY // 与 Magic Word 标题间距
                                    +
                                    58 * scaleY // Magic Word 标题高度
                                    +
                                    inputHeightRight // Magic Word 输入框高度（放大后）
                                    +
                                    64 * scaleY), // ← 与“已有账号？登录”拉开更大距离
                                child: Row(
                                  children: [
                                    // 返回
                                    SizedBox(
                                      width: buttonWidth,
                                      height: inputHeightRight, // 跟随右侧输入高度
                                      child: GestureDetector(
                                        onTap: () => Navigator.pop(context),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            boxShadow: const [
                                              BoxShadow(
                                                color: Color(0x3F000000),
                                                blurRadius: 15,
                                                spreadRadius: 0,
                                              )
                                            ],
                                          ),
                                          child: Center(
                                            child: Text(
                                              AppLocalizations.of(context).back,
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 32 * scaleX,
                                                fontFamily: 'Manrope',
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),

                                    // 返回 / 下一步按钮之间距更大：gap → gap * 1.5
                                    SizedBox(width: gap * 1.5), // ← 更宽的间隔

                                    // 下一步
                                    SizedBox(
                                      width: buttonWidth,
                                      height: inputHeightRight,
                                      child: GestureDetector(
                                        onTap: _register,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF292929),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Center(
                                            child: _isLoading
                                                ? const CircularProgressIndicator(
                                                    color: Colors.white)
                                                : Text(
                                                    AppLocalizations.of(context)
                                                        .next,
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 32 * scaleX,
                                                      fontFamily: 'Manrope',
                                                      fontWeight:
                                                          FontWeight.w400,
                                                    ),
                                                  ),
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
                      }),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
