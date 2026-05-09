import 'package:projek_akhir/models/booking_model.dart';
import 'package:projek_akhir/services/database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookingLocalService {
  Future<void> saveBooking(BookingModel booking) async {
    final db = await DatabaseHelper.instance.database;
    await db.insert(
      'bookings',
      booking.toMap(),
    );
  }

  Future<List<BookingModel>> getMyBookings() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');

    if (userId == null) return [];

    final db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'bookings',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );

    return List.generate(maps.length, (i) {
      return BookingModel.fromMap(maps[i]);
    });
  }

  Future<void> updatePaymentStatus(String bookingId, String status) async {
    final db = await DatabaseHelper.instance.database;
    await db.update(
      'bookings',
      {'status_bayar': status},
      where: 'id = ?',
      whereArgs: [bookingId],
    );
  }
}
