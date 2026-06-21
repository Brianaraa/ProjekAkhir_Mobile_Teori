import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  // Load environment variables dari file .env
  await dotenv.load(fileName: '.env');
  final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';

  final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);
  try {
    final list = await model.listModels();
    print('=== LIST MODELS ===');
    for (final m in list) {
      print('- ${m.name}');
    }
  } catch (e) {
    print('Error listing models: $e');
  }
}
