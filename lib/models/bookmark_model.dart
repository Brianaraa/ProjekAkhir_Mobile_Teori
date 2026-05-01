class BookmarkModel {
  final String uuid;
  final String userId;
  final String vendorId;
  final String? namaVendor; 
  final String? alamat;    
  final DateTime createdAt;

  BookmarkModel({
    required this.uuid,
    required this.userId,
    required this.vendorId,
    this.namaVendor,
    this.alamat,
    required this.createdAt,
  });

  factory BookmarkModel.fromJson(Map<String, dynamic> json) {
    final vendor = json['vendor'];
    return BookmarkModel(
      uuid: (json['uuid'] ?? json['id'] ?? '').toString(),
      userId: (json['user_id'] ?? '').toString(),
      vendorId: (json['vendor_id'] ?? '').toString(),
      namaVendor: vendor != null ? vendor['nama_vendor'] : json['nama_vendor'],
      alamat: vendor != null ? vendor['alamat'] : json['alamat'],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
    );
  }

  // simpen ke lokal
  Map<String, dynamic> toMap() {
    return {
      'uuid': uuid,
      'user_id': userId,
      'vendor_id': vendorId,
      'nama_vendor': namaVendor, 
      'alamat': alamat,           
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory BookmarkModel.fromMap(Map<String, dynamic> map) {
    return BookmarkModel(
      uuid: map['uuid'],
      userId: map['user_id'],
      vendorId: map['vendor_id'],
      namaVendor: map['nama_vendor'],
      alamat: map['alamat'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}