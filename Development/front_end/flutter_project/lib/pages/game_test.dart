import 'package:flutter/material.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:webview_flutter/webview_flutter.dart' as mobile;
import 'package:webviewx_plus/webviewx_plus.dart';

class GameWebViewPage extends StatelessWidget {
  const GameWebViewPage({super.key});

  static const String _gameUrl =
      'https://catopus.education/game-packages/Test/TestGame/SeriousGameProject.html';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Game Test')),
      body: UniversalPlatform.isWeb
           ? _buildWebViewWeb(context)

          : _buildMobileWebView(),
    );
  }

  /// ✅ Web 平台用 WebViewX
  Widget _buildWebViewWeb(BuildContext context) {
  final size = MediaQuery.of(context).size;

  return WebViewX(
    initialContent: _gameUrl,
    initialSourceType: SourceType.url,
    width: size.width,
    height: size.height,
    javascriptMode: JavascriptMode.unrestricted,
  );
}


  /// ✅ Android/iOS 平台用 webview_flutter
  Widget _buildMobileWebView() {
    final controller = mobile.WebViewController()
      ..setJavaScriptMode(mobile.JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(_gameUrl));

    return mobile.WebViewWidget(controller: controller);
  }
}
