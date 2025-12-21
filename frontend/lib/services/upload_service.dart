import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

class UploadService {
  static const String baseUrl = 'http://10.0.2.2:8000';

  // ---------------------------------------------------------------------------
  // Azure Blob Storage 업로드
  // POST /upload/photo/azure (multipart)
  // ---------------------------------------------------------------------------
  static Future<String> uploadPhotoToAzure(File file) async {
    final uri = Uri.parse('$baseUrl/upload/photo/azure');

    final request = http.MultipartRequest('POST', uri)
      ..files.add(
        await http.MultipartFile.fromPath(
          'file',
          file.path,
        ),
      );

    final response = await request.send();

    if (response.statusCode == 200) {
      final body = await response.stream.bytesToString();
      final json = jsonDecode(body);
      return json['url'];
    } else {
      throw Exception('Azure 업로드 실패');
    }
  }
}
