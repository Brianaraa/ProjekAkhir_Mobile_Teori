class BookingModel {
  final String uuid;
  final String userId;
  final String vendorId;
  final String layananId;
  final String namaVendor;
  final String namaLayanan;
  final String namaAcara;
  final DateTime tanggalAcara;
  final double totalHarga;
  final String statusBayar;
  final DateTime createdAt;

  BookingModel({
    required this.uuid,
    required this.userId,
    required this.vendorId,
    required this.layananId,
    required this.namaVendor,
    required this.namaLayanan,
    required this.namaAcara,
    required this.tanggalAcara,
    required this.totalHarga,
    required this.statusBayar,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uuid': uuid,
      'user_id': userId,
      'vendor_id': vendorId,
      'layanan_id': layananId,
      'nama_vendor': namaVendor,
      'nama_layanan': namaLayanan,
      'nama_acara': namaAcara,
      'tanggal_acara': tanggalAcara.toIso8601String(),
      'total_harga': totalHarga,
      'status_bayar': statusBayar,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory BookingModel.fromMap(Map<String, dynamic> map) {
    return BookingModel(
      uuid: map['uuid'],
      userId: map['user_id'],
      vendorId: map['vendor_id'],
      layananId: map['layanan_id'],
      namaVendor: map['nama_vendor'],
      namaLayanan: map['nama_layanan'],
      namaAcara: map['nama_acara'],
      tanggalAcara: DateTime.parse(map['tanggal_acara']),
      totalHarga: (map['total_harga'] as num).toDouble(),
      statusBayar: map['status_bayar'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}
