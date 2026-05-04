import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/review_model.dart';

class ReviewService {
  final supabase = Supabase.instance.client;

  Future<String?> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id');
  }

  Future<void> addOrUpdateReview({
    required String vendorId,
    required double rating,
    String? komentar,
  }) async {
    try {
      final userId = await getCurrentUserId();

      if (userId == null || userId.isEmpty) {
        throw Exception('User ID tidak ditemukan');
      }

      final existing = await supabase
          .from('review')
          .select('uuid')
          .eq('id_vendor', vendorId)
          .eq('id_user', userId)
          .maybeSingle();

      if (existing != null) {
        await supabase.from('review').update({
          'rating': rating,
          'komentar': komentar?.trim(),
        }).eq('uuid', existing['uuid']);
      } else {
        await supabase.from('review').insert({
          'id_vendor': vendorId,
          'id_user': userId,
          'rating': rating,
          'komentar': komentar?.trim(),
        });
      }

      await _updateVendorRatingSummary(vendorId);
    } catch (e) {
      print('Error addOrUpdateReview: $e');
      rethrow;
    }
  }

  Future<void> _updateVendorRatingSummary(String vendorId) async {
    try {
      final result = await supabase
          .from('review')
          .select('rating')
          .eq('id_vendor', vendorId);

      if (result.isEmpty) {
        await supabase.from('vendor').update({
          'rating_avg': 0,
          'rating_total': 0,
          'rating_count': 0,
        }).eq('uuid', vendorId);
        return;
      }

      final ratings = result
          .map<double>((e) => (e['rating'] ?? 0).toDouble())
          .toList();

      final count = ratings.length;
      final total = ratings.fold<double>(0, (sum, r) => sum + r);
      final avg = count > 0 ? total / count : 0.0;

      await supabase.from('vendor').update({
        'rating_avg': avg,
        'rating_total': total,
        'rating_count': count,
      }).eq('uuid', vendorId);
    } catch (e) {
      print('rror updateVendorRatingSummary: $e');
    }
  }

  Future<double?> getVendorRating(String vendorId) async {
    try {
      final result = await supabase
          .from('vendor')
          .select('rating_avg')
          .eq('id', vendorId)
          .single();

      return (result['rating_avg'] as num?)?.toDouble();
    } catch (e){
      print('Error getVendorRating: $e');
      return null;
    }
  }

  Future<List<ReviewModel>> getReviewsByVendor(String vendorId) async {
    try {
      final response = await supabase
          .from('review')
          .select('''
            uuid,
            id_vendor,
            id_user,
            rating,
            komentar,
            created_at,
            users:id_user (
              nama
            )
          ''')
          .eq('id_vendor', vendorId)
          .order('created_at', ascending: false);

      print('Response reviews: ${response.length}');

      return (response as List)
          .map((item) => ReviewModel.fromMap(item))
          .toList();
    } catch (e) {
      print('Error getReviewsByVendor: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getVendorSummary(String vendorId) async {
    try {
      final data = await supabase
          .from('vendor')
          .select('rating_avg, rating_count')
          .eq('uuid', vendorId)
          .single();

      return data;
    } catch (e) {
      print('❌ Error getVendorSummary: $e');
      return null;
    }
  }
}