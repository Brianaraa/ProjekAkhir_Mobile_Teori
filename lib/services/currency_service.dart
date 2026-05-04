import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:projek_akhir/models/currency_model.dart';

class CurrencyService {
  // Ambil API Key dan Base URL dari .env atau definisikan secara dinamis
  final String _apiKey = dotenv.env['EXCHANGERATE_API_KEY'] ?? '';
  
  // URL untuk mengambil rate terbaru dengan base IDR (Rupiah)
  String get _baseUrl => 'https://v6.exchangerate-api.com/v6/$_apiKey/latest/IDR';

  static const Map<String, String> targetCurrencies = {
    'MYR': 'Ringgit Malaysia', // Relevan untuk TKI/Keluarga di Malaysia
    'SAR': 'Riyal Arab Saudi',  // Relevan untuk konteks Haji/Hijriyah
    'USD': 'Dolar Amerika',    // Global standar
    'SGD': 'Dolar Singapura',  // Tetangga terdekat
  };

  Future<List<CurrencyModel>> getRates() async {
    if (_apiKey.isEmpty) {
      throw Exception('API Key mata uang belum diatur di .env');
    }

    try {
      final response = await http.get(Uri.parse(_baseUrl))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final rates = data['conversion_rates'] as Map<String, dynamic>;

        return targetCurrencies.entries
            .map((e) => CurrencyModel.fromApiJson(rates, e.key, e.value))
            .toList();
      } else {
        throw Exception('Gagal memuat kurs: ${response.statusCode}');
      }
    } catch (e) {
      print('CurrencyService Error: $e');
      return [];
    }
  }
}