class BookingModel {
  final String id;
  final String userId;
  final String vendorId;
  final String namaVendor;
  final DateTime tanggalAcara;
  final String jenisAdat;
  final double totalHarga;
  final String statusBayar;
  final DateTime createdAt;

  BookingModel({
    required this.id,
    required this.userId,
    required this.vendorId,
    required this.namaVendor,
    required this.tanggalAcara,
    required this.jenisAdat,
    required this.totalHarga,
    required this.statusBayar,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'vendor_id': vendorId,
      'nama_vendor': namaVendor,
      'tanggal_acara': tanggalAcara.toIso8601String(),
      'jenis_adat': jenisAdat,
      'total_harga': totalHarga,
      'status_bayar': statusBayar,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory BookingModel.fromMap(Map<String, dynamic> map) {
    return BookingModel(
      id: map['id'],
      userId: map['user_id'],
      vendorId: map['vendor_id'],
      namaVendor: map['nama_vendor'],
      tanggalAcara: DateTime.parse(map['tanggal_acara']),
      jenisAdat: map['jenis_adat'],
      totalHarga: (map['total_harga'] as num).toDouble(),
      statusBayar: map['status_bayar'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}
