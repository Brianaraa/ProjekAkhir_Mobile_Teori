class WeatherModel {
  final String city;
  final String description;
  final double temperature;
  final int humidity;
  final String weatherCode;

  WeatherModel({
    required this.city,
    required this.description,
    required this.temperature,
    required this.humidity,
    required this.weatherCode,
  });

  factory WeatherModel.fromBmkgJson(Map<String, dynamic> json) {
    final lokasi = json['lokasi'];
    final cuacaItem = json['data'][0]['cuaca'][0][0];
    return WeatherModel(
      city: lokasi['deskripsi'] ?? lokasi['kota'] ?? '',
      description: cuacaItem['weather_desc'] ?? '',
      temperature: (cuacaItem['t'] as num).toDouble(),
      humidity: (cuacaItem['hu'] as num).toInt(),
      weatherCode: cuacaItem['weather'].toString(),
    );
  }
}