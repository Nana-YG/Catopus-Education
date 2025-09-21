import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_project/generated/app_localizations.dart';
import 'package:flutter_project/pages/language_setting_page.dart.dart';
import 'package:flutter_project/pages/welcome.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_project/utils/app_locale.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  await AppLocale.I.init();
  final hasChosen = await getHasChosenLanguage();

  runApp(MyApp(hasChosenLanguage: hasChosen));
}

class MyApp extends StatelessWidget {
  final bool hasChosenLanguage;
  const MyApp({super.key, required this.hasChosenLanguage});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: AppLocale.I.locale,
      builder: (_, loc, __) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          locale: loc,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          localeResolutionCallback: (device, supported) {
            if (device != null) {
              for (final s in supported) {
                if (s.languageCode == device.languageCode) return s;
              }
            }
            return const Locale('zh');
          },
          home: hasChosenLanguage
              ? const WelcomePage()
              : LanguageSettingsPage(
                  setLocale: (Locale loc) async {
                    await AppLocale.I.set(loc.languageCode);
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('hasChosenLanguage', true);
                  },
                ),
        );
      },
    );
  }
}

Future<bool> getHasChosenLanguage() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('hasChosenLanguage') ?? false;
}
