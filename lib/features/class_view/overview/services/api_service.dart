import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static const String _apiKey = 'openrouter_api_key';

  // LẤY API key từ secure storage
  static Future<String?> getApiKey() async {
    try {
      String? apiKey = await _storage.read(key: _apiKey);
      if (apiKey == null) {
        // Lần đầu: Nhập API key và lưu an toàn
        throw Exception('Chưa set API key. Gọi setApiKey() trước');
      }
      return apiKey;
    } catch (e) {
      debugPrint('Lỗi đọc API key: $e');
      return null;
    }
  }

  // LƯU API key (gọi 1 lần khi user nhập)
  static Future<void> setApiKey(String apiKey) async {
    await _storage.write(key: _apiKey, value: apiKey);
  }

  // XÓA API key
  static Future<void> deleteApiKey() async {
    await _storage.delete(key: _apiKey);
  }
}
