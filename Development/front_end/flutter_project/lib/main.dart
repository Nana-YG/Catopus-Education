import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_project/generated/app_localizations.dart';
import 'package:flutter_project/pages/language_setting_page.dart.dart';
import 'package:flutter_project/pages/welcome.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
   // ✅ 清除 SharedPreferences 数据
  // await clearSharedPreferences(); // **运行一次后可以注释掉**
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]).then((_) async {
    Locale? savedLocale = await getSavedLocale(); // 获取存储的语言
    bool hasChosenLanguage = await getHasChosenLanguage(); // 检查是否已选择语言
    runApp(MyApp(savedLocale: savedLocale, hasChosenLanguage: hasChosenLanguage));
  });
}

class MyApp extends StatefulWidget {
  final Locale? savedLocale;
  final bool hasChosenLanguage; // 是否已选择语言

  const MyApp({super.key, this.savedLocale, required this.hasChosenLanguage});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Locale _locale;
  late bool _hasChosenLanguage;

  @override
  void initState() {
    super.initState();
    _locale = widget.savedLocale ?? const Locale('zh', 'CN'); // 默认中文
    _hasChosenLanguage = widget.hasChosenLanguage; // 读取是否选择过语言
    debugPrint("🌍 当前存储的语言: ${_locale.languageCode}");
  debugPrint("🚀 是否已经选择语言: $_hasChosenLanguage");
  }

  void setLocale(Locale newLocale) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale', newLocale.languageCode); // 存储用户选择的语言
    await prefs.setBool('hasChosenLanguage', true); // 记录用户已选择语言

    setState(() {
      _locale = newLocale;
      _hasChosenLanguage = true; // 语言已选择
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: _locale, // 读取存储的语言
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        for (var supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale?.languageCode) {
            return supportedLocale;
          }
        }
        return const Locale('zh', 'CN'); // 默认使用中文
      },
      home: _hasChosenLanguage
          ? const WelcomePage() // **如果已经选过语言，进入 WelcomePage**
          : LanguageSettingsPage(setLocale: setLocale), // **否则进入 SettingsPage**
    );
  }
}

Future<Locale?> getSavedLocale() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? localeCode = prefs.getString('locale');
  if (localeCode != null) {
    return Locale(localeCode);
  }
  return null;
}

Future<bool> getHasChosenLanguage() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool hasChosen = prefs.getBool('hasChosenLanguage') ?? false;
  debugPrint("🚀 hasChosenLanguage: $hasChosen"); // ✅ 打印日志，确认值
  return hasChosen;
}
Future<void> clearSharedPreferences() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.clear(); // 清除所有存储数据
  debugPrint("🚀 SharedPreferences 已清除");
}


