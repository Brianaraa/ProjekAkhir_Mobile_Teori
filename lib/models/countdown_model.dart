class CountdownModel {
  final String uuid;
  final String idUser;
  final String judul;
  final DateTime tanggal;
  final DateTime createdAt;

  CountdownModel({
    required this.uuid,
    required this.idUser,
    required this.judul,
    required this.tanggal,
    required this.createdAt,
  });

  factory CountdownModel.fromMap(Map<String, dynamic> map) {
    return CountdownModel(
      uuid: map['uuid'] ?? '',
      idUser: map['id_user'] ?? '',
      judul: map['judul'] ?? 'Tanpa Judul',
      tanggal: DateTime.parse(map['tanggal']),
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  //ngambil kurang berapa hari
  int get sisaHari {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final eventDate = DateTime(tanggal.year, tanggal.month, tanggal.day);
    
    return eventDate.difference(today).inDays;
  }

  String get sisaHariLabel {
    if (sisaHari > 0) {
      return '$sisaHari Hari';
    } else if (sisaHari == 0) {
      return 'Hari Ini';
    } else {
      return 'Selesai';
    }
  }
}