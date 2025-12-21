import 'package:family_app/api/api_client.dart';

class FamilyService {
  static Future<void> createFamily({
    required String name,
    required String type,
  }) async {
    await ApiClient.post(
      '/families',
      {
        'name': name,
        'type': type,
      },
    );
  }
}
