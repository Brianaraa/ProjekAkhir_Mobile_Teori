class UserModel {
  final String id;
  final String nama;
  final String email;
  final String password;

  UserModel({
    required this.id,
    required this.nama,
    required this.email,
    required this.password,
  });

  // baca dari Supabase (JSON)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['uuid'],
      nama: json['nama'],  
      email: json['email'],
      password: json['password'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uuid': id,
      'nama': nama,
      'email': email,
      'password': password,
    };
  }
}