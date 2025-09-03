import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_project/utils/constant.dart'; // baseApiUrl

/// 缓存：username -> hex string
final Map<String, String?> _avatarCache = {};

/// 拉取像素头像（"RRGGBB..." or "#RRGGBB#..."），自动转成 "#RRGGBB#..." 形式
Future<String?> fetchAvatarHexFor(String targetUsername) async {
  if (_avatarCache.containsKey(targetUsername)) return _avatarCache[targetUsername];

  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token') ?? '';

  final uri = Uri.parse('$baseApiUrl/login/profile-picture');
  final res = await http.get(uri, headers: {
    // ⚠️ 这里要传“要看的那个人”的用户名
    'Username': targetUsername,
    'Token': token,
  });

  if (res.statusCode != 200) {
    // 方便排查：打开日志看看是不是 403/401
    // debugPrint('avatar $targetUsername => ${res.statusCode} ${res.body}');
    _avatarCache[targetUsername] = null;
    return null;
  }

  final body = jsonDecode(res.body);
  final raw = body['profilePicture'];
  if (raw == null || raw.toString().isEmpty) {
    _avatarCache[targetUsername] = null;
    return null;
  }

  final str = raw.toString();
  final hex = RegExp(r'^#').hasMatch(str)
      ? str
      : str.replaceAllMapped(RegExp(r'.{6}'), (m) => '#${m.group(0)}');

  _avatarCache[targetUsername] = hex;
  return hex;
}
