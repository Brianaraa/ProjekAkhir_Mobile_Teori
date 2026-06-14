class AdminModel {
  final String uuid;
  final String nama;
  final String email;
  final DateTime createdAt;

  AdminModel({
    required this.uuid,
    required this.nama,
    required this.email,
    required this.createdAt,
  });

  factory AdminModel.fromJson(Map<String, dynamic> json) {
    return AdminModel(
      uuid: json['uuid'] ?? '',
      nama: json['nama'] ?? '',
      email: json['email'] ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }
}
