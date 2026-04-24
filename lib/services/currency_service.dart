import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:projek_akhir/models/currency_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CurrencyService {
  static final String _apiKey = dotenv.env['EXCHANGERATE_API_KEY'] ?? '';
  static String get _baseUrl =>
      'https://v6.exchangerate-api.com/v6/$_apiKey/latest/IDR';

  // Mata uang wajib TPM: min 3, kita pakai 4
  static const Map<String, String> targetCurrencies = {
    'MYR': 'Ringgit Malaysia',
    'SAR': 'Riyal Arab Saudi',
    'USD': 'Dolar Amerika',
    'SGD': 'Dolar Singapura',
  };

  Future<List<CurrencyModel>> getRates() async {
    try {
      final response = await http.get(Uri.parse(_baseUrl))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final rates = data['conversion_rates'] as Map<String, dynamic>;

        return targetCurrencies.entries
            .map((e) => CurrencyModel.fromApiJson(rates, e.key, e.value))
            .toList();
      }
      throw Exception('Failed to load rates: ${response.statusCode}');
    } catch (e) {
      print('CurrencyService error: $e');
      rethrow;
    }
  }
}