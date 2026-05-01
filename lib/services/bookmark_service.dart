import 'package:supabase_flutter/supabase_flutter.dart';
import 'user_service.dart';

class BookmarkService {
  final supabase = Supabase.instance.client;

  Future<bool> isBookmarked(String vendorId) async {
    final userId = await UserService.getCurrentUserId();

    if (userId == null) return false;

    final res = await supabase
        .from('bookmark')
        .select()
        .eq('user_id', userId)
        .eq('vendor_id', vendorId)
        .maybeSingle();

    return res != null;
  }

  Future<List<Map<String, dynamic>>> getBookmarksWithVendor() async {
    final userId = await UserService.getCurrentUserId();

    if (userId == null) return [];

    final res = await supabase
        .from('bookmark')
        .select('''
          vendor_id,
          vendor:vendor_id (
            uuid,
            nama_vendor,
            alamat
          )
        ''')
        .eq('user_id', userId);

    return List<Map<String, dynamic>>.from(res);
  }

  Future<List<Map<String, dynamic>>> getBookmarks() async {
    final userId = await UserService.getCurrentUserId();
    if (userId == null) return [];

    // Gunakan select dengan join vendor agar nama_vendor muncul[cite: 8]
    final res = await supabase
        .from('bookmark')
        .select('''
          vendor_id,
          vendor:vendor_id (
            uuid, 
            nama_vendor,
            alamat
          )
        ''')
        .eq('user_id', userId);

    return List<Map<String, dynamic>>.from(res);
  }

  Future<void> addBookmark(String vendorId) async {
    final userId = await UserService.getCurrentUserId();

    if (userId == null) throw Exception('User belum login');

    await supabase.from('bookmark').insert({
      'user_id': userId,
      'vendor_id': vendorId,
    });

    
  }

  Future<void> removeBookmark(String vendorId) async {
    final userId = await UserService.getCurrentUserId();

    await supabase
        .from('bookmark')
        .delete()
        .eq('user_id', userId!)
        .eq('vendor_id', vendorId);
  }
}