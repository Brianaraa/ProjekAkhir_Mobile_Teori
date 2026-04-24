import 'package:flutter/material.dart';
import 'package:projek_akhir/models/chat_model.dart';
import 'package:projek_akhir/services/chat_service.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _chatService = ChatService();
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();

  List<ChatMessage> _messages = [];
  bool _isTyping = false;

  final List<String> _suggestions = [
    'Apa itu prosesi midodareni?',
    'Estimasi budget nikahan 200 orang?',
    'Hari baik pernikahan adat Jawa?',
    'Apa saja prosesi sunatan adat?',
  ];

  @override
  void initState() {
    super.initState();
    // Pesan pembuka dari Bli-AI
    _messages.add(ChatMessage(
      text:
          'Halo! Saya Bli-AI, asisten hajatan digitalmu 🙏\n\nSaya bisa membantu kamu soal:\n• Prosesi & tata cara adat\n• Menentukan hari baik\n• Estimasi budget hajatan\n• Rekomendasi persiapan\n\nAda yang bisa saya bantu?',
      sender: MessageSender.ai,
    ));
  }

  Future<void> _sendMessage([String? text]) async {
    final msg = (text ?? _inputController.text).trim();
    if (msg.isEmpty) return;

    _inputController.clear();

    setState(() {
      _messages.add(ChatMessage(text: msg, sender: MessageSender.user));
      // Tambah bubble loading AI
      _messages.add(ChatMessage(
        text: '',
        sender: MessageSender.ai,
        isLoading: true,
      ));
      _isTyping = true;
    });

    _scrollToBottom();

    final response = await _chatService.sendMessage(msg);

    setState(() {
      // Hapus bubble loading, ganti dengan respons asli
      _messages.removeLast();
      _messages.add(ChatMessage(text: response, sender: MessageSender.ai));
      _isTyping = false;
    });

    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfffcf9f8),
      appBar: AppBar(
        backgroundColor: const Color(0xfffcf9f8),
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFFd4af37),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.auto_awesome,
                  color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Bli-AI',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1C1C1C)),
                ),
                Text(
                  _isTyping ? 'sedang mengetik...' : 'Heritage Guide',
                  style: TextStyle(
                      fontSize: 11,
                      color: _isTyping
                          ? const Color(0xFFd4af37)
                          : Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // ── CHAT LIST ──
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _messages.length,
              itemBuilder: (context, i) => _buildBubble(_messages[i]),
            ),
          ),

          // ── SUGGESTED QUESTIONS (hanya jika belum ada percakapan) ──
          if (_messages.length <= 1) _buildSuggestions(),

          // ── INPUT BAR ──
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildBubble(ChatMessage msg) {
    final isUser = msg.sender == MessageSender.user;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: const Color(0xFFd4af37),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.auto_awesome,
                  color: Colors.white, size: 14),
            ),
            const SizedBox(width: 8),
          ],

          Flexible(
            child: Column(
              crossAxisAlignment: isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isUser
                        ? const Color(0xFFd4af37)
                        : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isUser ? 16 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      )
                    ],
                  ),
                  child: msg.isLoading
                      ? _loadingDots()
                      : Text(
                          msg.text,
                          style: TextStyle(
                            fontSize: 14,
                            color: isUser
                                ? const Color(0xFF884513)
                                : const Color(0xFF1C1C1C),
                            height: 1.5,
                          ),
                        ),
                ),
                const SizedBox(height: 3),
                Text(
                  msg.formattedTime,
                  style: const TextStyle(
                      fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
          ),

          if (isUser) const SizedBox(width: 36),
        ],
      ),
    );
  }

  Widget _loadingDots() {
    return const SizedBox(
      width: 40,
      height: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _Dot(delay: 0),
          _Dot(delay: 150),
          _Dot(delay: 300),
        ],
      ),
    );
  }

  Widget _buildSuggestions() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _suggestions
            .map((s) => GestureDetector(
                  onTap: () => _sendMessage(s),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFd4af37).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: const Color(0xFFd4af37).withOpacity(0.4)),
                    ),
                    child: Text(
                      s,
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF884513)),
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          )
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _inputController,
              textCapitalization: TextCapitalization.sentences,
              maxLines: null,
              decoration: InputDecoration(
                hintText: 'Tanya Bli-AI...',
                hintStyle:
                    const TextStyle(color: Colors.grey, fontSize: 14),
                filled: true,
                fillColor: const Color(0xfff6f3f2),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(
                      color: Color(0xFFd4af37), width: 1.5),
                ),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _isTyping ? null : _sendMessage,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: _isTyping
                    ? Colors.grey[300]
                    : const Color(0xFFd4af37),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.send_rounded,
                color: _isTyping ? Colors.grey : const Color(0xFF884513),
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

// Animasi loading dots
class _Dot extends StatefulWidget {
  final int delay;
  const _Dot({required this.delay});

  @override
  State<_Dot> createState() => _DotState();
}

class _DotState extends State<_Dot> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _anim = Tween(begin: 0.3, end: 1.0).animate(_ctrl);
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _ctrl.repeat(reverse: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _anim,
      child: Container(
        width: 7,
        height: 7,
        decoration: const BoxDecoration(
          color: Color(0xFFd4af37),
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }
}