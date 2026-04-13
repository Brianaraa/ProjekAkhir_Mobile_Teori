import 'package:projek_akhir/models/vendor_models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class VendorService {
  final database = Supabase.instance.client.from('vendor');

  Future<List<VendorModel>> getVendors() async {
    try {
      final response = await database.select();

      return (response as List)
          .map((e) => VendorModel.fromJson(e))
          .toList();
    } catch (e) {
      print('Error get vendors: $e');
      return [];
    }
  }
}