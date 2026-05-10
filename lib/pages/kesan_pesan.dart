import 'package:flutter/material.dart';

class KesanPesanPage extends StatelessWidget {
  const KesanPesanPage({super.key});

  static const _items = [
    _KesanPesanItem(
      nama: 'Nara',
      kesan:
          'Mata kuliah TPM sangat membantu dalam memahami proses pengembangan aplikasi mobile secara lebih terstruktur, mulai dari perancangan UI, integrasi database, hingga implementasi fitur pada aplikasi nyata. Praktikum dan proyek yang diberikan juga menambah pengalaman dalam problem solving dan kerja mandiri.',
      saran:
          'Akan lebih baik jika diberikan lebih banyak contoh implementasi langsung pada studi kasus nyata serta pembahasan debugging error yang sering terjadi saat development aplikasi mobile.',
    ),
    _KesanPesanItem(
      nama: 'Aulia',
      kesan:
          'Mata kuliah TPM memberikan pengalaman belajar yang menarik karena tidak hanya mempelajari teori, tetapi juga praktik langsung membuat aplikasi. Materi yang diberikan cukup relevan dengan kebutuhan industri saat ini.',
      saran:
          'Semoga ke depannya tersedia lebih banyak sesi konsultasi atau review project secara berkala agar mahasiswa lebih mudah memahami kesalahan pada kode dan struktur aplikasi yang dibuat.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfffcf9f8),
      appBar: AppBar(
        title: const Text(
          'Kesan & Saran TPM',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF352010),
          ),
        ),
        backgroundColor: const Color(0xfffcf9f8),
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: _items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) => _buildCard(_items[index]),
      ),
    );
  }

  Widget _buildCard(_KesanPesanItem item) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                item.nama,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF884513),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _buildSection(
            icon: Icons.sentiment_satisfied_alt,
            title: 'Kesan',
            content: item.kesan,
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          _buildSection(
            icon: Icons.lightbulb_outline,
            title: 'Saran',
            content: item.saran,
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: const Color(0xFFd4af37)),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF884513),
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(content, style: const TextStyle(fontSize: 14, height: 1.5)),
      ],
    );
  }
}

class _KesanPesanItem {
  final String nama;
  final String kesan;
  final String saran;

  const _KesanPesanItem({
    required this.nama,
    required this.kesan,
    required this.saran,
  });
}
