import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:projek_akhir/models/kesan_pesan_model.dart';

class KesanPesanService {
  final supabase = Supabase.instance.client;

  Future<String?> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id');
  }

  Future<List<KesanPesanModel>> getAllKesanPesan() async {
    try {
      final response = await supabase
          .from('kesan_pesan')
          .select('''
            id,
            user_id,
            pesan,
            saran,
            created_at,
            users (
              nama
            )
          ''')
          .order('created_at', ascending: false);

      return response
          .map<KesanPesanModel>((item) => KesanPesanModel.fromMap(item))
          .toList();
    } catch (e) {
      print('Error getAllKesanPesan: $e');
      rethrow;
    }
  }

  Future<KesanPesanModel> addKesanPesan({
    required String pesan,
    required String saran,
  }) async {
    try {
      final userId = await getCurrentUserId();
      if (userId == null || userId.isEmpty) {
        throw Exception('User ID tidak ditemukan. Pastikan sudah login.');
      }

      final response = await supabase
          .from('kesan_pesan')
          .insert({
            'user_id': userId,
            'pesan': pesan.trim(),
            'saran': saran.trim(),
          })
          .select('''
            id, 
            user_id, 
            pesan, 
            saran, 
            created_at,
            users (nama)
          ''')
    .single();

      return KesanPesanModel.fromMap(response);
    } catch (e) {
      print('Error addKesanPesan: $e');
      rethrow;
    }
  }

  Future<void> updateKesanPesan({
    required String id,
    required String pesan,
    required String saran,
  }) async {
    try {
      final userId = await getCurrentUserId();
      if (userId == null || userId.isEmpty) {
        throw Exception('User ID tidak ditemukan');
      }

      await supabase
          .from('kesan_pesan')
          .update({
            'pesan': pesan.trim(),
            'saran': saran.trim(),
          })
          .eq('id', id)
          .eq('user_id', userId);
    } catch (e) {
      print('Error updateKesanPesan: $e');
      rethrow;
    }
  }

  Future<void> deleteKesanPesan(String id) async {
    try {
      final userId = await getCurrentUserId();
      if (userId == null || userId.isEmpty) {
        throw Exception('User ID tidak ditemukan');
      }

      await supabase
          .from('kesan_pesan')
          .delete()
          .eq('id', id)
          .eq('user_id', userId);
    } catch (e) {
      print('Error deleteKesanPesan: $e');
      rethrow;
    }
  }
}