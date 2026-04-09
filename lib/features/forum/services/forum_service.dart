import '../../../core/services/supabase_service.dart';
import '../models/forum_post_model.dart';

class ForumService {
  final _client = SupabaseService.client;

  /// Tüm forum gönderilerini çek
  Future<List<ForumPostModel>> getPosts() async {
    try {
      final response = await _client
          .from('forum_posts')
          .select()
          .order('created_at', ascending: false);

      return (response as List).map((json) => ForumPostModel.fromJson(json)).toList();
    } catch (e) {
      // Hata durumunda boş liste döner
      return [];
    }
  }

  /// Yeni bir gönderi ekle
  Future<bool> createPost(ForumPostModel post) async {
    try {
      await _client.from('forum_posts').insert(post.toJson());
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Belirli bir kategorideki gönderileri çek
  Future<List<ForumPostModel>> getPostsByCategory(String category) async {
    try {
      final response = await _client
          .from('forum_posts')
          .select()
          .eq('category', category)
          .order('created_at', ascending: false);

      return (response as List).map((json) => ForumPostModel.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }
}
