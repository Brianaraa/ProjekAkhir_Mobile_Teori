import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:projek_akhir/models/kesan_pesan_model.dart';
import 'package:projek_akhir/services/kesan_pesan_service.dart';

class KesanPesanPage extends StatefulWidget {
  const KesanPesanPage({super.key});

  @override
  State<KesanPesanPage> createState() => _KesanPesanPageState();
}

class _KesanPesanPageState extends State<KesanPesanPage> {
  final KesanPesanService _service = KesanPesanService();
  List<KesanPesanModel> _data = [];
  bool _isLoading = true;
  String? _errorMessage;
  String? _currentUserId;

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

    try {
      final result = await _service.getAllKesanPesan();
      final userId = await _service.getCurrentUserId();
      
      setState(() {
        _currentUserId = userId;
      }); 

      setState(() {
        _data = result;
        _currentUserId = userId;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal memuat data kesan & saran';
        _isLoading = false;
      });
    }
  }

  void _showFormDialog({KesanPesanModel? item}) {
    final pesanController = TextEditingController(text: item?.pesan ?? '');
    final saranController = TextEditingController(text: item?.saran ?? '');
    final isEdit = item != null;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: const Color(0xfffcf9f8),
        title: Text(
          isEdit ? 'Edit Kesan & Saran' : 'Tambah Kesan & Saran',
          style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF884513)),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: pesanController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Kesan',
                  hintText: 'Apa kesanmu selama kuliah?',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: saranController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Saran',
                  hintText: 'Ada saran perbaikan?',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),

        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),

          ElevatedButton(
            onPressed: () async {
              if (pesanController.text.trim().isEmpty || saranController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Field tidak boleh kosong')),
                );
                return;
              }

              try {
                if (isEdit) {
                  await _service.updateKesanPesan(
                    id: item!.id,
                    pesan: pesanController.text.trim(),
                    saran: saranController.text.trim(),
                  );
                } else {
                  await _service.addKesanPesan(
                    pesan: pesanController.text.trim(),
                    saran: saranController.text.trim(),
                  );
                }
                Navigator.pop(context);
                _fetchData();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $e')));
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFd4af37),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(isEdit ? 'Update' : 'Simpan', style: const TextStyle(color: Color(0xFF884513), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteItem(KesanPesanModel item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text('Hapus Data?'),
        content: const Text('Tindakan ini tidak dapat dibatalkan.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _service.deleteKesanPesan(item.id);
        _fetchData();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfffcf9f8),
      appBar: AppBar(
        title: const Text('Kesan & Saran TPM', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF884513))),
        backgroundColor: const Color(0xfffcf9f8),
        elevation: 0,
        centerTitle: true,
      ),

      body: RefreshIndicator(
        onRefresh: _fetchData,
        color: const Color(0xFFd4af37),
        child: _buildBody(),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => _showFormDialog(),
        backgroundColor: const Color(0xFFd4af37),
        child: const Icon(Icons.add, color: Color(0xFF884513)),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return const Center(child: CircularProgressIndicator(color: Color(0xFFd4af37)));
    if (_errorMessage != null) return Center(child: Text(_errorMessage!));
    if (_data.isEmpty) return _buildEmptyState();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _data.length,
      itemBuilder: (context, index) {
        final item = _data[index];
        final date = DateFormat('dd MMM yyyy • HH:mm').format(item.createdAt);
        final bool isOwner = _currentUserId == item.userId; 

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: const Color(0xFFd4af37).withOpacity(0.2),
                      child: Text(
                        item.namaUser.isNotEmpty ? item.namaUser[0].toUpperCase() : '?', 
                        style: const TextStyle(color: Color(0xFF884513), fontWeight: FontWeight.bold)
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.namaUser, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text(date, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                        ],
                      ),
                    ),
                  
                    if (isOwner) ...[
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(Icons.edit_note_rounded, color: Colors.blue, size: 24),
                        onPressed: () => _showFormDialog(item: item),
                        tooltip: 'Edit',
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 22),
                        onPressed: () => _deleteItem(item),
                        tooltip: 'Hapus',
                      ),
                    ],
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Divider(thickness: 0.5),
                ),
                _buildContentSection("Kesan", item.pesan),
                const SizedBox(height: 12),
                _buildContentSection("Saran", item.saran),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildContentSection(String label, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFd4af37), fontSize: 12)),
        const SizedBox(height: 4),
        Text(content, style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.4)),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline_rounded, size: 100, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text('Belum ada pesan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
        ],
      ),
    );
  }
}