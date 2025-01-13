import 'package:http/http.dart' as http;

void fetchLogin() async {
  try {
    final response = await http.get(Uri.parse('https://catopus.education/login/'));
    if (response.statusCode == 200) {
      print('Response: ${response.body}');
    } else {
      print('Failed with status: ${response.statusCode}');
    }
  } catch (e) {
    print('Error: $e');
  }
}
