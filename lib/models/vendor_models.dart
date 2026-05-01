class VendorModel {
  final String uuid;                
  final String namaVendor;
  final String deskripsi;
  final String alamat;
  final String sosmed;
  final double longitude;
  final double latitude;

  // Rating fields
  final double? ratingAvg;
  final int? ratingCount;
  final double? ratingTotal;

  VendorModel({
    required this.uuid,
    required this.namaVendor,
    required this.deskripsi,
    required this.alamat,
    required this.sosmed,
    required this.longitude,
    required this.latitude,
    this.ratingAvg,
    this.ratingCount,
    this.ratingTotal,
  });

  factory VendorModel.fromJson(Map<String, dynamic> json) {
    return VendorModel(
      uuid: json['id'] ?? json['uuid'] ?? '',
      namaVendor: json['nama_vendor'] ?? 'Tanpa Nama',
      deskripsi: json['deskripsi'] ?? '',
      alamat: json['alamat'] ?? '',
      sosmed: json['sosmed'] ?? '',
      longitude: (json['longitude'] ?? 0).toDouble(),
      latitude: (json['latitude'] ?? 0).toDouble(),
      ratingAvg: json['rating_avg'] != null ? (json['rating_avg']).toDouble() : null,
      ratingCount: json['rating_count'] as int?,
      ratingTotal: json['rating_total'] != null ? (json['rating_total']).toDouble() : null,
    );
  }
}