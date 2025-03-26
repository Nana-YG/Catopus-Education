import 'package:flutter/material.dart';
import 'package:flutter_project/generated/app_localizations.dart';
import 'package:flutter_project/pages/welcome.dart';

class LanguageSettingsPage extends StatefulWidget {
  final Function(Locale) setLocale;

  const LanguageSettingsPage({super.key, required this.setLocale});

  @override
  _LanguageSettingsPageState createState() => _LanguageSettingsPageState();
}

class _LanguageSettingsPageState extends State<LanguageSettingsPage> {
  bool _isNavigating = false; // 避免重复跳转

  void _changeLanguage(Locale locale) {
    if (_isNavigating) return; // **防止多次点击导致重复跳转**
    _isNavigating = true;

    widget.setLocale(locale); // **先更新语言**

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) { // **确保 Widget 仍然存在**
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const WelcomePage()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double baseWidth = 2160;
    double scaleX = screenWidth / baseWidth;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          width: screenWidth,
          decoration: const BoxDecoration(color: Colors.white),
          child: Stack(
          children: [
              Positioned(
                left: 666 * scaleX,
                top: 234 * scaleX,
                child: Text(
                  AppLocalizations.of(context).languageSettings, // ✅ 这里的 `settings` 应改为 `languageSettings`
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 48 * scaleX,
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w700,
                  ),
            ),
              ),
              Positioned(
                left: 855 * scaleX,
                top: 354 * scaleX,
                child: Text(
                  AppLocalizations.of(context).chooseLanguage,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 32 * scaleX,
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Positioned(
                left: 855 * scaleX,
                top: 500 * scaleX,
                child: GestureDetector(
                  onTap: () => _changeLanguage(const Locale('en', 'US')),
                  child: Container(
                    width: 450 * scaleX,
                    height: 80 * scaleX,
                    decoration: BoxDecoration(
                      color: const Color(0xFF292929),
                      borderRadius: BorderRadius.circular(8 * scaleX),
                    ),
                    child: Center(
                      child: Text(
                        'English',
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
              ),
              Positioned(
                left: 855 * scaleX,
                top: 620 * scaleX,
                child: GestureDetector(
                  onTap: () => _changeLanguage(const Locale('zh', 'CN')),
                  child: Container(
                    width: 450 * scaleX,
                    height: 80 * scaleX,
                    decoration: BoxDecoration(
                      color: const Color(0xFF292929),
                      borderRadius: BorderRadius.circular(8 * scaleX),
                    ),
                    child: Center(
                      child: Text(
                        '中文',
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
