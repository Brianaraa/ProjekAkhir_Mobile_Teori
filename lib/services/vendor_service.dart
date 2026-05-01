import 'package:projek_akhir/models/vendor_models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class VendorService {
  final supabase = Supabase.instance.client;

  Future<List<VendorModel>> getVendors() async {
    try {
      final response = await supabase
          .from('vendor')
          .select('''
            uuid,
            nama_vendor,
            deskripsi,
            alamat,
            sosmed,
            longitude,
            latitude,
            rating_avg,
            rating_count,
            rating_total
          ''');

      return (response as List)
          .map((e) => VendorModel.fromJson(e))
          .toList();
    } catch (e) {
      print('Error get vendors: $e');
      return [];
    }
  }

  Future<VendorModel?> getVendorById(String id) async {
    try {
      final response = await supabase
          .from('vendor')
          .select('''
            uuid,
            nama_vendor,
            deskripsi,
            alamat,
            sosmed,
            longitude,
            latitude,
            rating_avg,
            rating_count,
            rating_total
          ''')
          .eq('uuid', id)
          .single();

      return VendorModel.fromJson(response);
    } catch (e) {
      print('Error getVendorById: $e');
      return null;
    }
  }
}