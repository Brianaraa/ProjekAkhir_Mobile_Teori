import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:projek_akhir/models/kesan_pesan_model.dart';

class KesanPesanService {
  final supabase = Supabase.instance.client;

  Future<List<KesanPesanModel>> getAllKesanPesan() async {
    try {
      final response = await supabase
          .from('kesan_pesan')
          .select('id, pesan, saran');

      return (response as List)
          .map((item) => KesanPesanModel.fromMap(item))
          .toList();
    } catch (e) {
      print('Error getAllKesanPesan: $e');
      return [];
    }
  }
}