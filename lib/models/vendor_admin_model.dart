class VendorAdminModel {
  final String uuid;
  final String namaVendor;
  final String deskripsi;
  final String alamat;
  final String sosmed;
  final String telpone;
  final double longitude;
  final double latitude;
  final bool isActive;
  final double? ratingAvg;
  final int? ratingCount;
  final DateTime? updatedAt;

  VendorAdminModel({
    required this.uuid,
    required this.namaVendor,
    required this.deskripsi,
    required this.alamat,
    required this.sosmed,
    required this.telpone,
    required this.longitude,
    required this.latitude,
    required this.isActive,
    this.ratingAvg,
    this.ratingCount,
    this.updatedAt,
  });

  factory VendorAdminModel.fromJson(Map<String, dynamic> json) {
    return VendorAdminModel(
      uuid: json['uuid'] ?? json['id'] ?? '',
      namaVendor: json['nama_vendor'] ?? '',
      deskripsi: json['deskripsi'] ?? '',
      alamat: json['alamat'] ?? '',
      sosmed: json['sosmed'] ?? '',
      telpone: json['telpone']?.toString() ?? '',
      longitude: (json['longitude'] ?? 0).toDouble(),
      latitude: (json['latitude'] ?? 0).toDouble(),
      isActive: json['is_active'] ?? true,
      ratingAvg: json['rating_avg'] != null
          ? (json['rating_avg']).toDouble()
          : null,
      ratingCount: json['rating_count'] as int?,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toInsertMap() => {
    'nama_vendor': namaVendor,
    'deskripsi': deskripsi,
    'alamat': alamat,
    'sosmed': sosmed,
    'telpone': telpone,
    'longitude': longitude,
    'latitude': latitude,
    'is_active': isActive,
  };

  Map<String, dynamic> toUpdateMap() => {
    'nama_vendor': namaVendor,
    'deskripsi': deskripsi,
    'alamat': alamat,
    'sosmed': sosmed,
    'telpone': telpone,
    'longitude': longitude,
    'latitude': latitude,
    'is_active': isActive,
  };
}
