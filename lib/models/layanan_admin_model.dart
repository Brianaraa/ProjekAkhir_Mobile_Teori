class LayananAdminModel {
  final String uuid;
  final String idVendor;
  final String namaLayanan;
  final String? deskripsi;
  final double? harga;
  final String? foto;
  final bool isActive;

  LayananAdminModel({
    required this.uuid,
    required this.idVendor,
    required this.namaLayanan,
    this.deskripsi,
    this.harga,
    this.foto,
    this.isActive = true,
  });

  factory LayananAdminModel.fromJson(Map<String, dynamic> json) {
    return LayananAdminModel(
      uuid: json['uuid'] ?? '',
      idVendor: json['id_vendor'] ?? '',
      namaLayanan: json['nama_layanan'] ?? '',
      deskripsi: json['deskripsi'],
      harga: json['harga'] != null ? (json['harga'] as num).toDouble() : null,
      foto: json['foto'],
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toInsertMap() => {
    'id_vendor': idVendor,
    'nama_layanan': namaLayanan,
    'deskripsi': deskripsi,
    'harga': harga,
    'foto': foto,
    'is_active': isActive,
  };

  String get hargaFormatted {
    if (harga == null || harga == 0) return 'Gratis';
    if (harga! >= 1000000) {
      return 'Rp ${(harga! / 1000000).toStringAsFixed(1)}jt';
    }
    if (harga! >= 1000) {
      return 'Rp ${(harga! / 1000).toStringAsFixed(0)}rb';
    }
    return 'Rp ${harga!.toStringAsFixed(0)}';
  }
}
