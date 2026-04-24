import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:projek_akhir/models/weather_model.dart';

class WeatherService {
  // BMKG Open API — gratis, tanpa API key
  static const String _baseUrl =
      'https://api.bmkg.go.id/publik/prakiraan-cuaca';

  // adm4 = kode wilayah level kelurahan
  // Contoh Yogyakarta: '34.71.01.1001'
  Future<WeatherModel?> getWeather(String adm4Code) async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl?adm4=$adm4Code'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return WeatherModel.fromBmkgJson(data);
      }
      return null;
    } catch (e) {
      print('WeatherService error: $e');
      return null;
    }
  }
}