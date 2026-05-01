class ReviewModel {
  final String id;  
  final String vendorId;
  final String userId; 
  final double rating;  
  final String? komentar;  
  final DateTime createdAt;
  final String userName;

  ReviewModel({
    required this.id,
    required this.vendorId,
    required this.userId,
    required this.rating,
    this.komentar,
    required this.createdAt,
    required this.userName,
  });

  factory ReviewModel.fromMap(Map<String, dynamic> map) {
    final usersData = map['users'] as Map<String, dynamic>?;

    return ReviewModel(
      id: map['uuid'] ?? map['id'] ?? '',
      vendorId: map['id_vendor'] ?? '',
      userId: map['id_user'] ?? '',
      rating: (map['rating'] ?? 0).toDouble(),
      komentar: map['komentar'],
      createdAt: DateTime.tryParse(map['created_at'] ?? '') ?? DateTime.now(),
      userName: usersData?['nama'] ?? 'User Tidak Dikenal',
    );
  }
}