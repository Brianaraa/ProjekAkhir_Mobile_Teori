class KesanPesanModel {
  final String id;
  final String pesan;
  final String saran;

  const KesanPesanModel({
    required this.id,
    required this.pesan,
    required this.saran,
  });

  factory KesanPesanModel.fromMap(Map<String, dynamic> map) {
    return KesanPesanModel(
      id: map['id'] ?? '',
      pesan: map['pesan'] ?? '',
      saran: map['saran'] ?? '',
    );
  }
}