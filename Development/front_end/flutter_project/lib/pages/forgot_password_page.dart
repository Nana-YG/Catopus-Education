import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_project/utils/constant.dart';
import 'package:flutter_project/pages/login.dart';
import 'package:flutter_project/utils/color.dart';
import 'package:flutter_project/generated/app_localizations.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _magicController = TextEditingController();
  final TextEditingController _newPwdController = TextEditingController();
  final TextEditingController _confirmPwdController = TextEditingController();

  final FocusNode _userFocus = FocusNode();
  final FocusNode _magicFocus = FocusNode();
  final FocusNode _newPwdFocus = FocusNode();
  final FocusNode _confirmPwdFocus = FocusNode();

  bool _isLoading = false;
  bool _showNewPwd = false;
  bool _showConfirmPwd = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _magicController.dispose();
    _newPwdController.dispose();
    _confirmPwdController.dispose();
    _userFocus.dispose();
    _magicFocus.dispose();
    _newPwdFocus.dispose();
    _confirmPwdFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final username = _usernameController.text.trim();
    final magicWord = _magicController.text.trim();
    final newPwd = _newPwdController.text;
    final confirmPwd = _confirmPwdController.text;

    if (username.isEmpty ||
        magicWord.isEmpty ||
        newPwd.isEmpty ||
        confirmPwd.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(AppLocalizations.of(context).pleaseFillAllFields)),
      );
      return;
    }
    if (newPwd != confirmPwd) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).passwordMismatch)),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final url = Uri.parse("$baseApiUrl/login/reset-password");
      final response = await http.post(
        url,
        headers: {
          "username": username,
          "magicWord": magicWord,
          "Content-Type": "application/json; charset=UTF-8",
        },
        body: jsonEncode({"newPassword": newPwd}),
      );

      setState(() => _isLoading = false);

      // 解析与提示
      Map<String, dynamic>? body;
      try {
        body = response.body.isNotEmpty ? jsonDecode(response.body) : null;
      } catch (_) {
        body = null;
      }

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(body?["message"] ??
                  AppLocalizations.of(context).resetSuccess)),
        );
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LoginPage()),
            (route) => false,
          );
        }
      } else if (response.statusCode == 400) {
        final msg = body?["error"] ?? "Bad Request";
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(msg)));
      } else if (response.statusCode == 401) {
        final msg =
            body?["error"] ?? AppLocalizations.of(context).unauthorizedInvalid;
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(msg)));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).networkError)),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).networkError)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // —— 与登录/注册一致的布局参数 —— //
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    const baseWidth = 2160.0;
    const baseHeight = 1080.0;
    final scaleX = screenWidth / baseWidth;
    final scaleY = screenHeight / baseHeight;
    final rightShift = screenWidth * 0.20;

    // 右侧面板与注册/登录一致（更宽 & 位置微调）
    final panelWidth = screenWidth * 0.30;
    final panelLeft = (855 * scaleX + rightShift) - 40 * scaleX; // 往左一点
    final panelTop = -150 * scaleY; // 往上一点

    final inputHeight = screenHeight * 0.08;
    final inputHeightRight = inputHeight * 1.12; // 与注册页一致
    final gap = 32 * scaleX;
    final buttonWidth = (screenWidth * 0.284 - gap) / 2;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          width: screenWidth,
          height: screenHeight,
          decoration: const BoxDecoration(color: AppColors.background),
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => FocusScope.of(context).unfocus(), // 点击空白收起键盘
            child: Stack(
              children: [
                // —— 左侧三层斜叠容器（保持与登录一致） —— //
                Positioned(
                  left: (-240 * scaleX),
                  top: -80 * scaleY,
                  child: Container(
                    transform: Matrix4.identity()..rotateZ(0.09),
                    width: 1278.26 * scaleX,
                    height: 1300.66 * scaleY,
                    decoration: ShapeDecoration(
                      color: Colors.white,
                      shape: const RoundedRectangleBorder(
                          side: BorderSide(width: 1.5)),
                      shadows: const [
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
                      shape: const RoundedRectangleBorder(
                          side: BorderSide(width: 1.5)),
                      shadows: const [
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
                      shape: const RoundedRectangleBorder(
                          side: BorderSide(width: 1.5)),
                      shadows: const [
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
                    child: Image.asset('assets/images/circle.png',
                        fit: BoxFit.contain),
                  ),
                ),

                // —— 右侧可滚动面板 —— //
                Positioned(
                  left: panelLeft,
                  top: panelTop,
                  width: panelWidth,
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
                      child: Builder(builder: (_) {
                        // === 计算每一段关键位置 ===
                        final double nameInputTop = 413 * scaleY;
                        final double magicInputTop = 573 * scaleY;

                        // 新密码 label 与输入框
                        final double newPwdLabelTop =
                            magicInputTop + inputHeightRight + 30 * scaleY;
                        final double newPwdInputTop =
                            newPwdLabelTop + 58 * scaleY;

                        // 确认密码 label 与输入框
                        final double confirmLabelTop =
                            newPwdInputTop + inputHeightRight + 20 * scaleY;
                        final double confirmInputTop =
                            confirmLabelTop + 58 * scaleY;

                        // === 按钮放在“确认密码输入框”之后，再加 64 的垂直间距 ===
                        final double buttonTop =
                            confirmInputTop + inputHeightRight + 64 * scaleY;

                        // === 滚动内容总高度：按钮底部 + 120 缓冲，避免裁切 ===
                        final double scrollContentHeight =
                            buttonTop + inputHeightRight + 120 * scaleY;

                        return SizedBox(
                          height: scrollContentHeight,
                          child: Stack(
                            children: [
                              // ===== 标题 =====
                              Positioned(
                                left: 0,
                                top: 234 * scaleY,
                                child: Text(
                                  AppLocalizations.of(context).resetPassword,
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
                                top: nameInputTop,
                                child: SizedBox(
                                  width: panelWidth,
                                  height: inputHeightRight,
                                  child: TextField(
                                    controller: _usernameController,
                                    focusNode: _userFocus,
                                    textInputAction: TextInputAction.next,
                                    onSubmitted: (_) =>
                                        _magicFocus.requestFocus(),
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

                              // ===== Magic Word =====
                              Positioned(
                                left: 0,
                                top: 515 * scaleY,
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
                                top: magicInputTop,
                                child: SizedBox(
                                  width: panelWidth,
                                  height: inputHeightRight,
                                  child: TextField(
                                    controller: _magicController,
                                    focusNode: _magicFocus,
                                    textInputAction: TextInputAction.next,
                                    onSubmitted: (_) =>
                                        _newPwdFocus.requestFocus(),
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

                              // ===== 新密码 =====
                              Positioned(
                                left: 0,
                                top: newPwdLabelTop,
                                child: Text(
                                  AppLocalizations.of(context).newPassword,
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
                                top: newPwdInputTop,
                                child: SizedBox(
                                  width: panelWidth,
                                  height: inputHeightRight,
                                  child: TextField(
                                    controller: _newPwdController,
                                    focusNode: _newPwdFocus,
                                    textInputAction: TextInputAction.next,
                                    onSubmitted: (_) =>
                                        _confirmPwdFocus.requestFocus(),
                                    obscureText: !_showNewPwd,
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
                                          .enterYourNewPassword,
                                      hintStyle: const TextStyle(
                                          color: Colors.black45),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _showNewPwd
                                              ? Icons.visibility
                                              : Icons.visibility_off,
                                          color: Colors.grey,
                                        ),
                                        onPressed: () => setState(
                                            () => _showNewPwd = !_showNewPwd),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              // ===== 确认密码 =====
                              Positioned(
                                left: 0,
                                top: confirmLabelTop,
                                child: Text(
                                  AppLocalizations.of(context).confirmPassword,
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
                                top: confirmInputTop,
                                child: SizedBox(
                                  width: panelWidth,
                                  height: inputHeightRight,
                                  child: TextField(
                                    controller: _confirmPwdController,
                                    focusNode: _confirmPwdFocus,
                                    textInputAction: TextInputAction.done,
                                    onSubmitted: (_) => _submit(),
                                    obscureText: !_showConfirmPwd,
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
                                          .enterYourConfirmPassword,
                                      hintStyle: const TextStyle(
                                          color: Colors.black45),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _showConfirmPwd
                                              ? Icons.visibility
                                              : Icons.visibility_off,
                                          color: Colors.grey,
                                        ),
                                        onPressed: () => setState(() =>
                                            _showConfirmPwd = !_showConfirmPwd),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              // ===== 按钮区：使用 buttonTop，不再固定 750 * scaleY =====
                              Positioned(
                                left: 0,
                                top: buttonTop,
                                child: Row(
                                  children: [
                                    // 返回
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.pushAndRemoveUntil(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) =>
                                                  const LoginPage()),
                                          (route) => false,
                                        );
                                      },
                                      child: Container(
                                        width: (screenWidth * 0.284 -
                                                32 * scaleX) /
                                            2,
                                        height: inputHeightRight,
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
                                    SizedBox(width: 32 * scaleX),
                                    // 重置
                                    GestureDetector(
                                      onTap: _submit,
                                      child: Container(
                                        width: (screenWidth * 0.284 -
                                                32 * scaleX) /
                                            2,
                                        height: inputHeightRight,
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
                                                      .reset,
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 32 * scaleX,
                                                    fontFamily: 'Manrope',
                                                    fontWeight: FontWeight.w400,
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
