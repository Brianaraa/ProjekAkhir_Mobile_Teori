import 'package:flutter/material.dart';
import 'package:projek_akhir/models/kesan_pesan_model.dart';
import 'package:projek_akhir/services/kesan_pesan_service.dart';

class KesanPesanPage extends StatefulWidget {
  const KesanPesanPage({super.key});

  @override
  State<KesanPesanPage> createState() => _KesanPesanPageState();
}

class _KesanPesanPageState extends State<KesanPesanPage> {
  final KesanPesanService _service = KesanPesanService();

  KesanPesanModel? _data;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _service.getAllKesanPesan();

    setState(() {
      if (result.isNotEmpty) {
        _data = result.first;
      } else {
        _errorMessage = 'Data kosong';
      }
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfffcf9f8),
      appBar: AppBar(
        title: const Text(
          'Kesan & Saran TPM',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF884513),
          ),
        ),
        backgroundColor: const Color(0xfffcf9f8),
        elevation: 0,
        centerTitle: true,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFFd4af37),
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(child: Text(_errorMessage!));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: _buildCard(_data!),
    );
  }

  Widget _buildCard(KesanPesanModel item) {
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
          _buildSection(
            icon: Icons.sentiment_satisfied_alt,
            title: 'Kesan',
            content: item.pesan,
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
        Text(
          content,
          style: const TextStyle(
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}