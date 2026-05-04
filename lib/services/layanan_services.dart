import 'package:projek_akhir/models/layanan_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LayananService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<LayananModel>> getLayananByVendor(String idVendor) async {
    try {
      final response = await _supabase
          .from('layanan')
          .select()
          .eq('id_vendor', idVendor)
          .order('nama_layanan', ascending: true);

      return (response as List<dynamic>)
          .map((json) => LayananModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('❌ Error fetching layanan for vendor $idVendor: $e');
      return [];
    }
  }

  Future<LayananModel?> getLayananById(String id) async {
    try {
      final response = await _supabase
          .from('layanan')
          .select()
          .eq('id', id)
          .maybeSingle();   // lebih aman daripada .single()

      return response != null ? LayananModel.fromJson(response) : null;
    } catch (e) {
      print('Error fetching layanan by id: $e');
      return null;
    }
  }
}