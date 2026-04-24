import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:projek_akhir/services/notification_service.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final _notifService = NotificationService();

  List<PendingNotificationRequest> _pending = [];
  bool _isLoading = true;

  // Notif dummy untuk demo tampilan riwayat
  // Nanti bisa diganti dari Supabase atau shared_preferences
  final List<Map<String, dynamic>> _history = [
    {
      'title': 'Selamat Datang di Hagati! 🎉',
      'body': 'Mulai rencanakan hajatanmu sekarang.',
      'time': 'Baru saja',
      'isRead': false,
      'icon': Icons.celebration_outlined,
    },
    {
      'title': 'Vendor Disimpan ✓',
      'body': 'Vendor telah ditambahkan ke daftar hajatanmu.',
      'time': '5 menit lalu',
      'isRead': true,
      'icon': Icons.store_outlined,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadPending();
  }

  Future<void> _loadPending() async {
    final pending = await _notifService.getPending();
    setState(() {
      _pending = pending;
      _isLoading = false;
    });
  }

  Future<void> _cancelPending(int id) async {
    await _notifService.cancel(id);
    await _loadPending();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notifikasi dibatalkan'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // Demo: kirim test notifikasi langsung
  Future<void> _sendTestNotif() async {
    await _notifService.showNow(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: 'Test Notifikasi Hagati 🔔',
      body: 'Notifikasi berjalan dengan baik!',
    );

    setState(() {
      _history.insert(0, {
        'title': 'Test Notifikasi Hagati 🔔',
        'body': 'Notifikasi berjalan dengan baik!',
        'time': 'Baru saja',
        'isRead': false,
        'icon': Icons.notifications_outlined,
      });
    });
  }

  // Schedule notif H-1 hajatan (contoh use case nyata)
  Future<void> _scheduleHajatanReminder() async {
  final tomorrow = DateTime.now().add(const Duration(minutes: 1));

  await _notifService.scheduleNotification(
    id: 1001,
    title: 'Pengingat Hajatan ⏰',
    body: 'Hajatan kamu 1 menit lagi! Pastikan semua persiapan sudah siap.',
    scheduledDate: tomorrow,
  );

  await _loadPending();

  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Reminder dijadwalkan 1 menit lagi'),
        backgroundColor: Color(0xFF884513),
      ),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfffcf9f8),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Notifikasi',
                    style: TextStyle(
                        fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  // Tombol test notif
                  GestureDetector(
                    onTap: _sendTestNotif,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFd4af37).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.notification_add_outlined,
                        color: Color(0xFFd4af37),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ── TERJADWAL ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Terjadwal',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: _scheduleHajatanReminder,
                    child: const Text(
                      '+ Tambah Reminder',
                      style: TextStyle(
                          color: Color(0xFFd4af37),
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: Color(0xFFd4af37)))
                  : _pending.isEmpty
                      ? _emptyPending()
                      : Column(
                          children: _pending
                              .map((n) => _pendingCard(n))
                              .toList(),
                        ),

              const SizedBox(height: 24),

              // ── RIWAYAT ──
              const Text(
                'Riwayat',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              ..._history.map((n) => _historyCard(n)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pendingCard(PendingNotificationRequest notif) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFd4af37).withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFd4af37).withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.schedule, color: Color(0xFFd4af37), size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notif.title ?? 'Notifikasi',
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold),
                ),
                if (notif.body != null)
                  Text(
                    notif.body!,
                    style: const TextStyle(
                        fontSize: 12, color: Colors.grey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _cancelPending(notif.id),
            child: const Icon(Icons.close, color: Colors.grey, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _historyCard(Map<String, dynamic> notif) {
    final isRead = notif['isRead'] as bool;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isRead ? Colors.white : const Color(0xfff6f3f2),
        borderRadius: BorderRadius.circular(14),
        border: Border(
          left: BorderSide(
            color: isRead
                ? Colors.transparent
                : const Color(0xFFd4af37),
            width: 3,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFd4af37).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              notif['icon'] as IconData,
              color: const Color(0xFFd4af37),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notif['title'] as String,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight:
                        isRead ? FontWeight.normal : FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  notif['body'] as String,
                  style: const TextStyle(
                      fontSize: 12, color: Colors.grey),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  notif['time'] as String,
                  style: const TextStyle(
                      fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
          if (!isRead)
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Color(0xFFd4af37),
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }

  Widget _emptyPending() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(Icons.notifications_none, size: 40, color: Colors.grey[300]),
          const SizedBox(height: 8),
          Text(
            'Belum ada notifikasi terjadwal',
            style: TextStyle(fontSize: 13, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}