import 'package:supabase_flutter/supabase_flutter.dart';

class LayananModel {
  final String id;
  final String idVendor;
  final String namaLayanan;
  final String? deskripsi;
  final double? harga;
  final String? foto;

  LayananModel({
    required this.id,
    required this.idVendor,
    required this.namaLayanan,
    this.deskripsi,
    this.harga,
    this.foto,
  });

  factory LayananModel.fromJson(Map<String, dynamic> json) {
    return LayananModel(
      id: json['id'] ?? '',
      idVendor: json['id_vendor'] ?? '',
      namaLayanan: json['nama_layanan'] ?? '',
      deskripsi: json['deskripsi'],
      harga: json['harga'] != null ? (json['harga'] as num).toDouble() : null,
      foto: json['foto'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_vendor': idVendor,
      'nama_layanan': namaLayanan,
      'deskripsi': deskripsi,
      'harga': harga,
      'foto': foto,
    };
  }

  String get hargaFormatted {
    if (harga == null || harga == 0) return 'Harga belum ditentukan';
    return 'Rp ${harga!.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  //ambil foto di storage
  String getFotoUrl(String vendorId) {
    if (foto == null || foto!.trim().isEmpty) {
      return '';
    }
    return Supabase.instance.client.storage
        .from('vendor')
        .getPublicUrl('$vendorId/$foto');
  }
}