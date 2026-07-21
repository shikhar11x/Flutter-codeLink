import '../network/api_client.dart';

class RecentPadsService {
  RecentPadsService._();

  static Future<List<Map<String, dynamic>>> getRecentPads() async {
    try {
      final response = await ApiClient.instance.get('/api/pads/user/recent');
      return List<Map<String, dynamic>>.from(response.data['pads']);
    } catch (e) {
      return [];
    }
  }
}