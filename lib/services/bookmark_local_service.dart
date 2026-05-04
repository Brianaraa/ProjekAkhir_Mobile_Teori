import 'package:sqflite/sqflite.dart';
import 'database_helper.dart';
import 'package:projek_akhir/models/bookmark_model.dart';

class BookmarkLocalService {

  Future<void> insert(BookmarkModel bookmark) async {
    final db = await DatabaseHelper.instance.database;

    await db.insert(
      'bookmark',
      bookmark.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    final check = await db.query('bookmark');
    print('DATA LOCAL SEKARANG: $check');
  }
  
  Future<List<BookmarkModel>> getAll() async {
    final db = await DatabaseHelper.instance.database;

    final result = await db.query('bookmark');

    print(' GET ALL LOCAL: $result');

    return result.map((e) => BookmarkModel.fromMap(e)).toList();
  }

  Future<void> deleteByVendorId(String vendorId) async {
    final db = await DatabaseHelper.instance.database;

    await db.delete(
      'bookmark',
      where: 'vendor_id = ?',
      whereArgs: [vendorId],
    );

    print('LOCAL: Bookmark dengan vendor_id $vendorId berhasil dihapus');
  }
}