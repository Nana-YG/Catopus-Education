import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 全局语言管理器：负责
/// 1) 从 SharedPreferences 读取/写入语言码（'zh' / 'en')；
/// 2) 通过 ValueNotifier<Locale> 通知全局 MaterialApp 切换语言。
class AppLocale {
  AppLocale._();
  static final AppLocale I = AppLocale._();

  /// 本地存储 key
  static const String _k = 'app_language_code'; // 'zh' / 'en'

  /// 当前 Locale 的可监听对象，MaterialApp 会监听它以切换语言
  final ValueNotifier<Locale> locale = ValueNotifier(const Locale('en'));

  /// 支持的语言（可按需扩展）
  static const List<Locale> supported = [Locale('en'), Locale('zh')];

  /// 启动时调用：从 SharePrefs 读取已保存语言并应用
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final String? code = prefs.getString(_k);
    if (code != null && _isSupported(code)) {
      locale.value = Locale(code);
    }
  }

  /// 设置语言：写入 SharePrefs + 触发全局刷新
  Future<void> set(String code) async {
    if (!_isSupported(code)) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_k, code);
    locale.value = Locale(code);
  }

  /// 便捷：当前语言码（'zh' / 'en'）
  String get code => locale.value.languageCode;

  /// 便捷：是否支持该语言码
  static bool _isSupported(String code) =>
      code == 'zh' || code == 'en';

  /// 可选：一键切换中英（如果只做中英两种）
  Future<void> toggle() =>
      set(code == 'zh' ? 'en' : 'zh');
}
