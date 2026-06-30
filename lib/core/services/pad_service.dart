import '../network/api_client.dart';

class PadService {
  PadService._();

  // Create new pad
  static Future<Map<String, dynamic>?> createPad({
    required String slug,
    String language = 'python',
    String content = '',
  }) async {
    try {
      final response = await ApiClient.instance.post(
        '/api/pads',
        data: {'slug': slug, 'language': language, 'content': content},
      );
      return response.data['pad'];
    } catch (e) {
      print('createPad error: $e');
      return null;
    }
  }

  // Get pad by slug
  static Future<Map<String, dynamic>?> getPad(String slug) async {
    try {
      final response = await ApiClient.instance.get('/api/pads/$slug');
      return response.data['pad'];
    } catch (e) {
      print('getPad error: $e');
      return null;
    }
  }

  // Update pad content
  static Future<void> updatePad(
    String slug, {
    String? content,
    String? language,
  }) async {
    try {
      await ApiClient.instance.patch(
        '/api/pads/$slug',
        data: {
          if (content != null) 'content': content,
          if (language != null) 'language': language,
        },
      );
    } catch (e) {
      print('updatePad error: $e');
    }
  }

  // Delete pad
  static Future<bool> deletePad(String slug) async {
    try {
      await ApiClient.instance.delete('/api/pads/$slug');
      return true;
    } catch (e) {
      print('deletePad error: $e');
      return false;
    }
  }
}
