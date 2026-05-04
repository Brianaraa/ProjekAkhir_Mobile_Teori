import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ChatService {
  late final GenerativeModel _model;
  late final ChatSession _chat;

  ChatService() {
  final apiKey = dotenv.env['GEMINI_API_KEY'] ?? 'KUNCI_TIDAK_DITEMUKAN';
  print('Debug API Key: $apiKey'); // Lihat di konsol apakah kuncinya muncul
  
  _model = GenerativeModel(
    model: 'gemini-1.5-flash-latest',
    apiKey: apiKey,
      systemInstruction: Content.system(
        '''Kamu adalah Bli-AI, asisten digital yang ahli dalam adat istiadat 
        Jawa, Sunda, Bali, Batak, dan Bugis. Kamu membantu pengguna merencanakan 
        hajatan (pernikahan, sunatan, selamatan, mitoni) dengan memberikan 
        informasi tentang prosesi adat, hari baik, estimasi budget, dan 
        rekomendasi vendor. Jawab dalam Bahasa Indonesia yang ramah dan sopan. 
        Jika ditanya di luar topik hajatan dan adat, arahkan kembali ke topik tersebut.'''
      ),
    );
    _chat = _model.startChat();
  }

  Future<String> sendMessage(String message) async {
    try {
      final response = await _chat.sendMessage(Content.text(message));
      return response.text ?? 'Maaf, Bli-AI sedang kehilangan kata-kata.';
    } catch (e) {
      print('Gemini Error: $e');
      return 'Maaf King, ada kendala koneksi ke otak Bli-AI. Coba lagi nanti ya!';
    }
  }
}