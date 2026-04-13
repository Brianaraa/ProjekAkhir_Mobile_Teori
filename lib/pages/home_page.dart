import 'package:flutter/material.dart';
import 'package:projek_akhir/auth/auth_gate.dart';
import 'package:projek_akhir/auth/auth_service.dart';
import 'package:projek_akhir/models/vendor_models.dart';
import 'package:projek_akhir/services/vendor_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final authService = AuthService();
  final vendorService = VendorService();

  List<VendorModel> vendors = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchVendors();
  }

  Future<void> fetchVendors() async {
    final data = await vendorService.getVendors();

    setState(() {
      vendors = data;
      isLoading = false;
    });
  }

  void logout() async {
    try {
      await authService.signOut();
      
      // Optional: force refresh dengan Navigator
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const AuthGate()),
        );
      }
    } catch (e) {
      print('Logout error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final username = authService.getCurrentUserName() ?? "User";

    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        actions: [
          IconButton(
            onPressed: logout,
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Halo, $username',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Daftar Vendor',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 16),

              /// 🔹 LIST VENDOR
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Expanded(
                      child: vendors.isEmpty
                          ? const Center(child: Text("Belum ada data vendor"))
                          : ListView.builder(
                              itemCount: vendors.length,
                              itemBuilder: (context, index) {
                                final vendor = vendors[index];

                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  child: ListTile(
                                    title: Text(vendor.namaVendor),
                                    subtitle: Text(vendor.alamat),
                                    trailing: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          vendor.latitude
                                              .toStringAsFixed(2),
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                        Text(
                                          vendor.longitude
                                              .toStringAsFixed(2),
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}