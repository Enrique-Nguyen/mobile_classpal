import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile_classpal/core/constants/ai_config.dart';
import '../services/api_service.dart';
import '../../../../core/models/chat_message.dart';

class ChatBotService {
  static Future<String> sendMessage({
    required List<ChatMessage> history,
  }) async {
    try {
      final apiKey = await ApiService.getApiKey();
      if (apiKey == null) {
        return "Lỗi: Chưa cấu hình API Key.";
      }
      final List<Map<String, dynamic>> messagesJson = [];
      messagesJson.add({"role": "system", "content": AiConfig.systemPrompt});
      for (var msg in history.reversed) {
        messagesJson.add({
          "role": msg.isUser ? "user" : "assistant",
          "content": msg.content,
        });
      }

      final Map<String, dynamic> requestBody = {
        "model": AiConfig.model,
        "messages": messagesJson,
        "temperature": 0.1,
        "top_p": 0.9,
        "top_k": 25,
      };
      final response = await http.post(
        Uri.parse('https://openrouter.ai/api/v1/chat/completions'),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
          'HTTP-Referer': 'https://classpal.app', // Tùy chọn
          'X-Title': 'ClassPal', // Tùy chọn
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        // Decode utf8 để không lỗi font tiếng Việt
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        // Lấy nội dung an toàn, nếu null trả về chuỗi mặc định
        return data['choices']?[0]?['message']?['content'] ??
            "AI không có phản hồi.";
      } else {
        return "Lỗi Server (${response.statusCode}): ${response.body}";
      }
    } catch (e) {
      return "Gặp lỗi kết nối: $e";
    }
  }
}
