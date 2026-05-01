class KesanPesanModel {
  final String id;
  final String userId;
  final String namaUser;
  final String pesan;
  final String saran;
  final DateTime createdAt;

  KesanPesanModel({
    required this.id,
    required this.userId,
    required this.namaUser,
    required this.pesan,
    required this.saran,
    required this.createdAt,
  });

  factory KesanPesanModel.fromMap(Map<String, dynamic> map) {
    final usersData = map['users'] as Map<String, dynamic>?;

    return KesanPesanModel(
      id: map['id'] ?? '',
      userId: map['user_id'] ?? '',
      namaUser: usersData?['nama'] ?? 'User Tidak Dikenal',
      pesan: map['pesan'] ?? '',
      saran: map['saran'] ?? '',
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}