enum MessageSender { user, ai }

class ChatMessage {
  final String text;
  final MessageSender sender;
  final DateTime timestamp;
  final bool isLoading;

  ChatMessage({
    required this.text,
    required this.sender,
    DateTime? timestamp,
    this.isLoading = false,
  }) : timestamp = timestamp ?? DateTime.now();

  String get formattedTime {
    final h = timestamp.hour.toString().padLeft(2, '0');
    final m = timestamp.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}