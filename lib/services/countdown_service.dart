import 'package:projek_akhir/services/notification_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:projek_akhir/models/countdown_model.dart';

class CountdownService {
  final supabase = Supabase.instance.client;

  Future<List<CountdownModel>> getMyCountdowns() async {
    try {
      final userId = await _getCurrentUserId();

      if (userId == null || userId.isEmpty) {
        throw Exception('User ID tidak ditemukan. Pastikan sudah login.');
      }

      final response = await supabase
          .from('countdown')
          .select('uuid, id_user, judul, tanggal, created_at')
          .eq('id_user', userId)
          .order('tanggal', ascending: true);

      final List<CountdownModel> countdowns = (response as List)
          .map((item) => CountdownModel.fromMap(item))
          .where((model) => model.sisaHari >= 0)
          .toList();

      return countdowns;
    } catch (e) {
      print('error getMyCountdowns: $e');
      rethrow;
    }
  }

  Future<void> addCountdown(String judul, DateTime tanggal) async {
    try {
      final userId = await _getCurrentUserId();
      if (userId == null || userId.isEmpty) {
        throw Exception('User ID tidak ditemukan');
      }

      final response = await supabase.from('countdown').insert({
        'id_user': userId,
        'judul': judul,
        'tanggal': tanggal.toIso8601String(),
      }).select().single();

      final newCountdown = CountdownModel.fromMap(response);

      // schedule notifikasi H-1 secara otomatis
      await scheduleH1Reminder(newCountdown);

      print('Countdown ditambahkan dan notifikasi H-1 dijadwalkan');
    } catch (e) {
      print('Error addCountdown: $e');
      rethrow;
    }
  }

  Future<void> deleteCountdown(String uuid) async {
    try {
      await supabase
          .from('countdown')
          .delete()
          .eq('uuid', uuid);
    } catch (e) {
      print('Error deleteCountdown: $e');
      rethrow;
    }
  }

  Future<void> updateCountdown(
    String uuid,
    String judul,
    DateTime tanggal,
  ) async {
    try {
      await supabase
          .from('countdown')
          .update({
            'judul': judul,
            'tanggal': tanggal.toIso8601String(),
          })
          .eq('uuid', uuid);
    } catch (e) {
      print('Error updateCountdown: $e');
      rethrow;
    }
  }

  Future<void> scheduleH1Reminder(CountdownModel countdown) async {
    final notificationId = countdown.uuid.hashCode.abs();

    final reminderDate = countdown.tanggal.subtract(const Duration(days: 1));

    await NotificationService().scheduleNotification(
      id: notificationId,
      title: 'H-1 Hajatan!',
      body: 'Besok adalah "${countdown.judul}". Jangan lupa persiapannya ya!',
      scheduledDate: reminderDate,
    );
  }

  Future<String?> _getCurrentUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');

      print('🔑 DEBUG: user_id = "$userId"');
      return userId;
    } catch (e) {
      print('Error mendapatkan user_id: $e');
      return null;
    }
  }
}