import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_project/generated/app_localizations.dart';
import 'package:flutter_project/pages/settings.dart';
import 'package:flutter_project/pages/welcome.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
          ? WelcomePage() // **如果已经选过语言，进入 WelcomePage**
          : SettingsPage(setLocale: setLocale), // **否则进入 SettingsPage**
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
  return prefs.getBool('hasChosenLanguage') ?? false;
}
