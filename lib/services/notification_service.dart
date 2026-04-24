import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  // Channel ID & Name
  static const String _channelId = 'hagati_channel';
  static const String _channelName = 'Hagati Notifikasi';

  Future<void> init() async {
    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(initSettings);

    // Buat notification channel untuk Android 8+
    await _plugin
    .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
    ?.createNotificationChannel(
      const AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: 'Notifikasi pengingat hajatan dari Hagati',
        importance: Importance.high,
      ),
    );
  }

  NotificationDetails get _details => const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: 'Notifikasi pengingat hajatan dari Hagati',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(),
      );

  // Notifikasi langsung / seketika
  Future<void> showNow({
    required int id,
    required String title,
    required String body,
  }) async {
    await _plugin.show(id, title, body, _details);
  }

  // Notifikasi terjadwal — misal H-1 sebelum hajatan
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    final tzDate = tz.TZDateTime.from(scheduledDate, tz.local);

    // Jangan jadwalkan jika waktu sudah lewat
    if (tzDate.isBefore(tz.TZDateTime.now(tz.local))) return;

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tzDate,
      _details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // Batalkan notifikasi berdasarkan ID
  Future<void> cancel(int id) async {
    await _plugin.cancel(id);
  }

  // Batalkan semua notifikasi
  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  // Cek semua notifikasi yang sudah terjadwal (untuk debugging)
  Future<List<PendingNotificationRequest>> getPending() async {
    return await _plugin.pendingNotificationRequests();
  }
}