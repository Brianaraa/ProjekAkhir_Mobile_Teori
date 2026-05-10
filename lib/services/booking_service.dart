import 'package:projek_akhir/models/booking_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BookingService {
  final SupabaseClient supabase = Supabase.instance.client;

  Future<String> createBooking({
    required String vendorId,
    required String layananId,
    required String namaVendor,
    required String namaLayanan,
    required String namaAcara,
    required DateTime tanggalAcara,
    required double totalHarga,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final userId = prefs.getString('user_id');

    if (userId == null || userId.isEmpty) {
      throw Exception('User belum login');
    }

    final response = await supabase
        .from('bookings')
        .insert({
          'user_id': userId,
          'vendor_id': vendorId,
          'layanan_id': layananId,
          'nama_vendor': namaVendor,
          'nama_layanan': namaLayanan,
          'nama_acara': namaAcara,
          'tanggal_acara': tanggalAcara.toIso8601String(),
          'total_harga': totalHarga,
          'status_booking': 'pending',
          'status_bayar': 'unpaid',
          'created_at': DateTime.now().toIso8601String(),
        })
        .select()
        .single();

    return response['uuid'];
  }

  Future<void> updatePaymentStatus({
    required String bookingId,
    required String statusBayar,
  }) async {
    await supabase
        .from('bookings')
        .update({'status_bayar': statusBayar, 'status_booking': 'done'})
        .eq('uuid', bookingId);
  }

  Future<List<BookingModel>> getMyBookings() async {
    final prefs = await SharedPreferences.getInstance();

    final userId = prefs.getString('user_id');

    if (userId == null || userId.isEmpty) {
      return [];
    }

    final response = await supabase
        .from('bookings')
        .select()
        .eq('user_id', userId)
        .order('tanggal_acara');

    return (response as List).map((e) => BookingModel.fromMap(e)).toList();
  }
}
