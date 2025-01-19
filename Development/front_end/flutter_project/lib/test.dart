import 'dart:convert'; 
import 'package:http/http.dart' as http;

void fetchLogin() async {
  try {
    var headers = {
      'Username': 'Fang123',
      'Token': 'Jek19dnR9KJrn9EAm',
    };

    final response = await http.get(
      Uri.parse('https://catopus.education/game-scripts/chem-sample.rpy'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      // 强制解码为 UTF-8
      final decodedBody = utf8.decode(response.bodyBytes);
      print('Response: $decodedBody');
    } else {
      print('Failed with status: ${response.statusCode}');
    }
  } catch (e) {
    print('Error: $e');
  }
}
