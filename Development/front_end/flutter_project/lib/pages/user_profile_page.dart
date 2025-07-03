import 'package:flutter/material.dart';
import 'package:flutter_project/generated/app_localizations.dart';
import 'package:flutter_project/pages/avatar_editor_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_project/pages/login.dart';


class UserProfilePage extends StatelessWidget {
  const UserProfilePage({super.key});

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }

  void _goToAvatarEditor(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AvatarEditorPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text( AppLocalizations.of(context)!.profile,
),
        centerTitle: true,
        backgroundColor: Colors.grey[100],
        elevation: 0,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 🔵 头像圆圈显示
          GestureDetector(
            onTap: () => _goToAvatarEditor(context),
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey[400],
              child: const Icon(Icons.brush, size: 40, color: Colors.white),
            ),
          ),
          const SizedBox(height: 40),


          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout),
            label: Text(AppLocalizations.of(context)!.logout,),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
