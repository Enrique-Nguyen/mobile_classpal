class ChatMessage {
  final String content;
  final bool isUser;
  final bool isStreaming;
  ChatMessage({
    required this.content,
    required this.isUser,
    this.isStreaming = false,
  });
}
