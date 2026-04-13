class VendorModel {
  final String id;
  final String namaVendor;
  final String deksripsi;
  final String alamat;
  final String sosmed;
  final double longitude;
  final double latitude;

  VendorModel({required this.id, required this.namaVendor, required this.deksripsi, required this.alamat, required this.sosmed, required this.longitude, required this.latitude});

  // read data
  factory VendorModel.fromJson(Map<String, dynamic> json) {
    return VendorModel(
      id: json['id'],
      namaVendor: json['nama_vendor'],
      deksripsi: json['deskripsi'],
      alamat: json['alamat'],
      sosmed: json['sosmed'],
      longitude: json['longitude'],
      latitude: json['latitude']
    );
  }

  // insert data tapi belom kepake
  // Map<String, dynamic> toMap() {
  //   return {
  //     'nama_vendor': namaVendor,
  //     'deskripsi': deksripsi,
  //     'alamat': alamat,
  //     'sosmed': sosmed,
  //     'longitude': longitude,
  //     'latitude': latitude
  //   };
  // }
}