import 'dart:math';
import 'package:flutter/material.dart';
import 'package:mobile_classpal/core/constants/app_colors.dart';
import 'package:mobile_classpal/core/models/class.dart';
import 'package:mobile_classpal/core/models/member.dart';

class ChatbotWindow extends StatefulWidget {
  final Class classData;
  final Member currentMember;

  const ChatbotWindow({
    super.key,
    required this.classData,
    required this.currentMember,
  });

  @override
  State<ChatbotWindow> createState() => _ChatbotWindowState();
}

class _ChatbotWindowState extends State<ChatbotWindow> {
  final TextEditingController _textController = TextEditingController();
  final List<String> _messages = [];

  void _handleSend() {
    if (_textController.text.trim().isNotEmpty) {
      setState(() {
        // _messages.add(_textController.text.trim());
        _messages.insert(0, _textController.text.trim());
        _textController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double windowWidth = min(size.width * 0.9, 380);
    final double windowHeight = size.height * 0.65;
    return Material(
      color: Colors.transparent,
      elevation: 10,
      child: AnimatedContainer(
        duration: const Duration(
          milliseconds: 100,
        ), // Animation nhanh để khớp với bàn phím
        width: windowWidth,
        height: max(windowHeight, 250),

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: AppColors.bannerBlue,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.smart_toy, color: Colors.white),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "ClassPal AI",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          widget.classData.name,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Nội dung tin nhắn
            Expanded(
              child: _messages.isEmpty
                  ? const Center(
                      child: Text(
                        "Tôi có thể giúp gì cho bạn?",
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      reverse: true,
                      padding: const EdgeInsets.all(12),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) => Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          // Giới hạn chiều rộng bong bóng chat để không bị tràn text
                          constraints: BoxConstraints(
                            maxWidth: windowWidth * 0.7,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.bannerBlue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(_messages[index]),
                        ),
                      ),
                    ),
            ),
            // Input
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _textController,
                textInputAction: TextInputAction.send,
                decoration: InputDecoration(
                  hintText: "Nhập tin nhắn...",
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.send, color: AppColors.primaryBlue),
                    onPressed: _handleSend,
                  ),
                ),
                onSubmitted: (_) => _handleSend(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
