import 'package:projek_akhir/models/bookmark_model.dart';
import 'bookmark_local_service.dart';
import 'bookmark_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class BookmarkRepository {
  final remote = BookmarkService();
  final local = BookmarkLocalService();

  Future<void> add(String vendorId, {String? nama, String? alamat}) async {
    await remote.addBookmark(vendorId);

    final bookmark = BookmarkModel(
      uuid: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: '', 
      vendorId: vendorId,
      namaVendor: nama,   
      alamat: alamat,  
      createdAt: DateTime.now(),
    );

    await local.insert(bookmark);
  }

  Future<List<BookmarkModel>> getAll() async {
    final connectivity = await (Connectivity().checkConnectivity());
    
    // kalo offline
    if (connectivity.contains(ConnectivityResult.none)) {
      return await local.getAll();
    }

    // online
    try {
      final List<Map<String, dynamic>> remoteData = 
          await remote.getBookmarksWithVendor().timeout(const Duration(seconds: 5));
      
      final localData = await local.getAll();
      
      List<BookmarkModel> updatedList = [];

      for (var item in remoteData) {
        final model = BookmarkModel.fromJson(item);
        updatedList.add(model);
        bool exists = localData.any((l) => l.vendorId == model.vendorId);
        if (!exists) {
          await local.insert(model);
        }
      }
      
      return updatedList;
    } catch (e) {
      print(' Error remote, fallback ke local: $e');
      return await local.getAll();
    }
  }

  Future<void> remove(String vendorId) async {
    try {
      final connectivity = await (Connectivity().checkConnectivity());
      if (!connectivity.contains(ConnectivityResult.none)) {
        await remote.removeBookmark(vendorId).timeout(const Duration(seconds: 5));
      }
    } catch (e) {
      print('Gagal hapus remote (lanjut hapus lokal): $e');
    }

    await local.deleteByVendorId(vendorId); 
  }
  Future<bool> checkIsBookmarked(String vendorId) async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    
    if (connectivityResult == ConnectivityResult.none) {
      final localData = await local.getAll();
      return localData.any((element) => element.vendorId == vendorId);
    }

    try {
      return await remote.isBookmarked(vendorId);
    } catch (_) {
      final localData = await local.getAll();
      return localData.any((element) => element.vendorId == vendorId);
    }
  }
}