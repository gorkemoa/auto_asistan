import 'package:flutter/material.dart';
import '../models/forum_post_model.dart';
import '../services/forum_service.dart';
import '../../../core/services/supabase_service.dart';

class ForumViewModel extends ChangeNotifier {
  final _service = ForumService();

  List<ForumPostModel> _posts = [];
  List<ForumPostModel> get posts => _posts;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _selectedCategory = 'genel';
  String get selectedCategory => _selectedCategory;

  /// Gönderileri yükle
  Future<void> loadPosts() async {
    _isLoading = true;
    notifyListeners();

    _posts = await _service.getPosts();

    _isLoading = false;
    notifyListeners();
  }

  /// Kategori filtrelemesi
  Future<void> filterByCategory(String? category) async {
    if (category == null || category == 'genel') {
      _selectedCategory = 'genel';
      await loadPosts();
    } else {
      _selectedCategory = category;
      _isLoading = true;
      notifyListeners();

      _posts = await _service.getPostsByCategory(category);

      _isLoading = false;
      notifyListeners();
    }
  }

  /// Yeni gönderi oluştur
  Future<bool> createPost({
    required String title,
    required String content,
    required String category,
    String? carBrand,
  }) async {
    final user = SupabaseService.currentUser;
    if (user == null) return false;

    final post = ForumPostModel(
      id: '', // Supabase otomatik atar
      userId: user.id,
      userEmail: user.email ?? 'Kullanıcı',
      title: title,
      content: content,
      category: category,
      carBrand: carBrand,
      createdAt: DateTime.now(),
    );

    final success = await _service.createPost(post);
    if (success) {
      await loadPosts();
    }
    return success;
  }
}
