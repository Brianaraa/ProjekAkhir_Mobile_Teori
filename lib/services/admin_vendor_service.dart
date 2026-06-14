import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:projek_akhir/models/vendor_admin_model.dart';
import 'package:projek_akhir/models/layanan_admin_model.dart';

class AdminVendorService {
  final _supabase = Supabase.instance.client;

  // ─────────────────────────────────────────────
  // VENDOR CRUD
  // ─────────────────────────────────────────────

  Future<List<VendorAdminModel>> getAllVendors() async {
    final res = await _supabase
        .from('vendor')
        .select()
        .order('nama_vendor');
    return (res as List).map((e) => VendorAdminModel.fromJson(e)).toList();
  }

  Future<VendorAdminModel?> getVendorById(String id) async {
    try {
      final res = await _supabase
          .from('vendor')
          .select()
          .eq('uuid', id)
          .single();
      return VendorAdminModel.fromJson(res);
    } catch (_) {
      return null;
    }
  }

  Future<String?> createVendor(VendorAdminModel vendor) async {
    try {
      final res = await _supabase
          .from('vendor')
          .insert(vendor.toInsertMap())
          .select('uuid')
          .single();
      return res['uuid'] as String;
    } catch (e) {
      print('createVendor error: $e');
      return null;
    }
  }

  Future<bool> updateVendor(String id, VendorAdminModel vendor) async {
    try {
      await _supabase
          .from('vendor')
          .update(vendor.toUpdateMap())
          .eq('uuid', id);
      return true;
    } catch (e) {
      print('updateVendor error: $e');
      return false;
    }
  }

  Future<bool> toggleVendorActive(String id, bool isActive) async {
    try {
      await _supabase
          .from('vendor')
          .update({'is_active': isActive})
          .eq('uuid', id);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteVendor(String id) async {
    try {
      // Hapus semua layanan dulu
      await _supabase.from('layanan').delete().eq('id_vendor', id);
      await _supabase.from('vendor').delete().eq('uuid', id);
      return true;
    } catch (e) {
      print('deleteVendor error: $e');
      return false;
    }
  }

  // ─────────────────────────────────────────────
  // UPLOAD FOTO VENDOR
  // ─────────────────────────────────────────────

  /// Upload main_picture.jpg ke bucket 'vendor/{vendorId}/main_picture.jpg'
  Future<String?> uploadVendorMainPhoto(
      String vendorId, Uint8List bytes) async {
    try {
      final path = '$vendorId/main_picture.jpg';
      await _supabase.storage.from('vendor').uploadBinary(
        path,
        bytes,
        fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
      );
      return _supabase.storage.from('vendor').getPublicUrl(path);
    } catch (e) {
      print('uploadVendorMainPhoto error: $e');
      return null;
    }
  }

  /// Upload foto layanan ke bucket 'vendor/{vendorId}/{fileName}'
  Future<String?> uploadLayananPhoto(
      String vendorId, String fileName, Uint8List bytes) async {
    try {
      final path = '$vendorId/$fileName';
      await _supabase.storage.from('vendor').uploadBinary(
        path,
        bytes,
        fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
      );
      return path; // simpan path relatif saja (bukan URL penuh)
    } catch (e) {
      print('uploadLayananPhoto error: $e');
      return null;
    }
  }

  // ─────────────────────────────────────────────
  // LAYANAN CRUD
  // ─────────────────────────────────────────────

  Future<List<LayananAdminModel>> getLayananByVendor(String vendorId) async {
    final res = await _supabase
        .from('layanan')
        .select()
        .eq('id_vendor', vendorId)
        .order('nama_layanan');
    return (res as List).map((e) => LayananAdminModel.fromJson(e)).toList();
  }

  Future<String?> createLayanan(LayananAdminModel layanan) async {
    try {
      final res = await _supabase
          .from('layanan')
          .insert(layanan.toInsertMap())
          .select('uuid')
          .single();
      return res['uuid'] as String;
    } catch (e) {
      print('createLayanan error: $e');
      return null;
    }
  }

  Future<bool> updateLayanan(String id, LayananAdminModel layanan) async {
    try {
      await _supabase
          .from('layanan')
          .update(layanan.toInsertMap())
          .eq('uuid', id);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteLayanan(String id) async {
    try {
      await _supabase.from('layanan').delete().eq('uuid', id);
      return true;
    } catch (_) {
      return false;
    }
  }

  // ─────────────────────────────────────────────
  // DASHBOARD STATS
  // ─────────────────────────────────────────────

  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final res = await _supabase
          .from('admin_dashboard_stats')
          .select()
          .single();
      return res;
    } catch (_) {
      return {};
    }
  }

  Future<List<Map<String, dynamic>>> getRecentBookings({int limit = 10}) async {
    try {
      final res = await _supabase
          .from('bookings')
          .select()
          .order('created_at', ascending: false)
          .limit(limit);
      return List<Map<String, dynamic>>.from(res);
    } catch (_) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getRecentReviews({int limit = 10}) async {
    try {
      final res = await _supabase
          .from('review')
          .select('*, vendor:id_vendor(nama_vendor), users:id_user(nama)')
          .order('created_at', ascending: false)
          .limit(limit);
      return List<Map<String, dynamic>>.from(res);
    } catch (_) {
      return [];
    }
  }
}
