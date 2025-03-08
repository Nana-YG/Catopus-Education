import 'package:flutter/material.dart';
import 'package:flutter_project/generated/app_localizations.dart';
import 'package:flutter_project/pages/welcome.dart';

class SettingsPage extends StatefulWidget {
  final Function(Locale) setLocale;

  const SettingsPage({super.key, required this.setLocale});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
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
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.settings)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(AppLocalizations.of(context)!.chooseLanguage, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _changeLanguage(const Locale('en', 'US')),
              child: const Text('English'),
            ),
            ElevatedButton(
              onPressed: () => _changeLanguage(const Locale('zh', 'CN')),
              child: const Text('中文'),
            ),
          ],
        ),
      ),
    );
  }
}
