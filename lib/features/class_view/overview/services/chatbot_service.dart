import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_classpal/core/constants/ai_config.dart';
import 'package:mobile_classpal/core/models/rule.dart';
import 'package:mobile_classpal/features/class_view/overview/services/rule_service.dart';
import '../services/api_service.dart';
import '../../../../core/models/chat_message.dart';

class ChatBotService {
  static Future<String> sendMessage({
    required List<ChatMessage> history,
    required String classId,
  }) async {
    try {
      final apiKey = await ApiService.getApiKey();
      print('After write: $apiKey');
      if (apiKey == null) {
        return "Lỗi: Chưa cấu hình API Key.";
      }
      // --- 1. LẤY DỮ LIỆU RULES TỪ STREAM ---
      List<Rule> rules = [];
      try {
        rules = await RuleService.getRules(classId).first;
      } catch (e) {
        print("Lỗi lấy rules: $e");
      }
      // --- 2. CHUYỂN RULES THÀNH JSON STRING ---
      String rulesJsonString = jsonEncode(rules.map((r) => r.toMap()).toList());
      // --- 3. TẠO SYSTEM PROMPT ĐỘNG ---
      // Thay thế placeholder bằng dữ liệu thật
      String dynamicSystemPrompt = AiConfig.systemPrompt.replaceAll(
        '{{RULES_LIST}}',
        rulesJsonString,
      );
      final List<Map<String, dynamic>> messagesJson = [];
      messagesJson.add({"role": "system", "content": dynamicSystemPrompt});
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
        // "tools": AiConfig.tools,
        // "tool_choice": 'required',
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
      print("CHek: ${response.statusCode}");
      // if (response.statusCode == 200) {
      //   final data = jsonDecode(utf8.decode(response.bodyBytes));
      //   final message = data['choices']?[0]?['message'];
      //   print("mesL: ${message}");
      //   if (message != null && message['tool_calls'] != null) {
      //     final toolCalls = message['tool_calls'] as List;
      //     String finalResultText = "Đã hoàn thành";
      //     for (var tool in toolCalls) {
      //       print("*1");
      //       final functionName = tool['function']['name'];
      //       final functionArgs = jsonDecode(tool['function']['arguments']);

      //       debugPrint("Đang thực hiện hàm: $functionName");
      //       debugPrint("Tham số: $functionArgs");
      //       String result = await _executeLocalFunction(
      //         classId,
      //         functionName,
      //         functionArgs,
      //       );
      //       if (result.isNotEmpty) {
      //         finalResultText = result;
      //       }
      //     }
      //     return finalResultText;
      //   }

      //   return "AI không phản hồi hành động cụ thể.";
      // }
      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        // Lấy nội dung text thô từ AI (không lấy tool_calls nữa)
        final String? aiContent = data['choices']?[0]?['message']?['content'];

        print("AI Raw Response: $aiContent");

        if (aiContent == null) return "AI không phản hồi.";

        // --- TÁCH JSON TỪ TEXT ---
        Map<String, dynamic>? actionJson;
        try {
          // Tìm vị trí bắt đầu '{' và kết thúc '}' để loại bỏ markdown thừa (nếu có)
          final startIndex = aiContent.indexOf('{');
          final endIndex = aiContent.lastIndexOf('}');

          if (startIndex != -1 && endIndex != -1 && endIndex > startIndex) {
            final jsonString = aiContent.substring(startIndex, endIndex + 1);
            actionJson = jsonDecode(jsonString);
          }
        } catch (e) {
          print(
            "⚠️ Không tìm thấy JSON hợp lệ trong phản hồi (có thể là chat thường): $e",
          );
        }
        // Kiểm tra xem JSON có đúng cấu trúc { "tool_name": "...", ... } không
        if (actionJson != null && actionJson.containsKey('tool_name')) {
          final functionName = actionJson['tool_name'];
          final functionArgs =
              actionJson['arguments']; // Có thể là Map hoặc null

          debugPrint("Đang thực hiện hàm: $functionName");
          debugPrint("Tham số: $functionArgs");

          String result = await _executeLocalFunction(
            classId,
            functionName,
            functionArgs is Map<String, dynamic> ? functionArgs : {},
          );
          if (result.isNotEmpty) {
            return result;
          }

          return "Đã hoàn thành";
        }

        // --- NẾU KHÔNG PHẢI JSON -> TRẢ VỀ TEXT CHAT BÌNH THƯỜNG ---
        return aiContent;
      } else {
        return "Lỗi Server (${response.statusCode}): ${response.body}";
      }
    } catch (e) {
      return "Gặp lỗi kết nối: $e";
    }
  }

  static Future<String> _executeLocalFunction(
    String classId,
    String functionName,
    Map<String, dynamic> args,
  ) async {
    try {
      switch (functionName) {
        case 'createDuty':
          debugPrint("Đã tạo Duty: ${args['name']}");
          return "Đã tạo duty:\n${args['name']}";

        case 'createEvent':
          debugPrint("Đã tạo Event: ${args['name']}");
          return "Đã tạo Event:\n${args['name']}";

        case 'createTransaction':
          debugPrint("Đã tạo Giao dịch: ${args['title']}");
          return "Đã tạo Transaction:\n${args['title']}";

        case 'ask_for_info':
          final question = args['question'] ?? "Cần thêm thông tin.";
          return question;

        default:
          debugPrint("Hàm $functionName chưa được định nghĩa logic.");
          return "Lỗi: Không tìm thấy chức năng $functionName";
      }
    } catch (e) {
      debugPrint("Lỗi thực thi hàm $functionName: $e");
      return "Có lỗi xảy ra khi thực hiện yêu cầu.";
    }
  }
}
