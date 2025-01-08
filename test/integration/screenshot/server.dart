import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> sendScreenshotToServer(String filename, List<int> bytes) async {
  final url = Uri.parse('http://127.0.0.1:34893/');
  final payload = jsonEncode({
    "filename": filename,
    "bytes": bytes,
  });

  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: payload,
    );

    if (response.statusCode == 200) {
      print('File uploaded successfully: ${response.body}');
    } else {
      print('Failed to upload file: ${response.body}');
    }
  } catch (e) {
    print('Error occurred while uploading file: $e');
  }
}
