class CurrencyModel {
  final String code;
  final String name;
  final double rate; // rate dari IDR ke mata uang ini
  final DateTime lastUpdated;

  CurrencyModel({
    required this.code,
    required this.name,
    required this.rate,
    required this.lastUpdated,
  });

  // Konversi nominal IDR ke mata uang target
  double convert(double idrAmount) => idrAmount * rate;

  factory CurrencyModel.fromApiJson(
      Map<String, dynamic> rates, String code, String name) {
    return CurrencyModel(
      code: code,
      name: name,
      rate: (rates[code] as num).toDouble(),
      lastUpdated: DateTime.now(),
    );
  }

  // Untuk simpan/baca dari Supabase jika diperlukan cache
  Map<String, dynamic> toMap() => {
        'code': code,
        'name': name,
        'rate': rate,
        'last_updated': lastUpdated.toIso8601String(),
      };

  factory CurrencyModel.fromMap(Map<String, dynamic> map) {
    return CurrencyModel(
      code: map['code'],
      name: map['name'],
      rate: (map['rate'] as num).toDouble(),
      lastUpdated: DateTime.parse(map['last_updated']),
    );
  }
}