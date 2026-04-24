import 'package:flutter/material.dart';
import 'package:hagati/pages/konversi_tanggal_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// 🔥 CARD UTAMA
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // Header
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Text("✨ Tanggal Baik Untuk Akad"),
                      ),

                      SizedBox(height: 16),

                      // Row 1
                      Row(
                        children: [
                          Expanded(child: _itemTanggal("Masehi", "11 April 2025")),
                          SizedBox(width: 12),
                          Expanded(child: _itemTanggal("Saka", "1948")),
                        ],
                      ),

                      SizedBox(height: 12),

                      // Row 2
                      Row(
                        children: [
                          Expanded(child: _itemTanggal("Jawa", "Sabtu Legi")),
                          SizedBox(width: 12),
                          Expanded(child: _itemTanggal("Hijriyah", "13 Syawwal")),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 20),

              /// 🔥 HEADER HAJATAN
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Hajatan mendatang",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  TextButton(
                    onPressed: () {},
                    child: Text("Lihat semua"),
                  )
                ],
              ),

              /// 🔥 CARD HAJATAN mendtang
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Pernikahan Adit & Sari",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),

                      Row(
                        children: [
                          Icon(Icons.calendar_month, size: 18),
                          SizedBox(width: 6),
                          Text("12 April 2026"),
                        ],
                      ),

                      SizedBox(height: 12),

                      Row(
                        children: [
                          Icon(Icons.add),
                          SizedBox(width: 6),
                          Text("Tambah Hajatan"),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 20),

              /// 🔥 AKSI CEPAT
              Text("Aksi Cepat",
                  style: TextStyle(fontWeight: FontWeight.bold)),

              SizedBox(height: 12),

              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.3,
                children: [
                  _menuItem(Icons.add, "Tambah Hajatan", DateConvertPage()),
                  _menuItem(Icons.store, "Cari Vendor", DateConvertPage()),
                  _menuItem(Icons.calendar_month, "Hitung Hari Baik", DateConvertPage()),
                  _menuItem(Icons.android_rounded, "Chatbot AI", DateConvertPage()),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 🔧 reusable item tanggal
  Widget _itemTanggal(String title, String value) {
    return Card(
      elevation: 0,
      color: Colors.grey.shade100,
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: TextStyle(fontSize: 12, color: Colors.grey)),
            SizedBox(height: 4),
            Text(value, style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  /// 🔧 menu item grid
  Widget _menuItem(IconData icon, String title, Widget page) {
    return Card(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => page),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 28),
              SizedBox(height: 8),
              Text(title),
            ],
          ),
        ),
      ),
    );
  }
}