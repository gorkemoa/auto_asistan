
class ForumPostModel {
  final String id;
  final String userId;
  final String userEmail;
  final String title;
  final String content;
  final String category; // sikayet, oneri, soru, genel
  final String? carBrand;
  final DateTime createdAt;

  const ForumPostModel({
    required this.id,
    required this.userId,
    required this.userEmail,
    required this.title,
    required this.content,
    required this.category,
    this.carBrand,
    required this.createdAt,
  });

  /// Kategori etiketini kullanıcı dostu hale getirir
  String get categoryDisplayName {
    switch (category) {
      case 'sikayet':
        return 'Şikayet';
      case 'oneri':
        return 'Öneri';
      case 'soru':
        return 'Soru';
      default:
        return 'Genel';
    }
  }

  factory ForumPostModel.fromJson(Map<String, dynamic> json) {
    return ForumPostModel(
      id: (json['id'] ?? '').toString(),
      userId: json['user_id'] ?? '',
      userEmail: json['user_email'] ?? 'Misafir',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      category: json['category'] ?? 'genel',
      carBrand: json['car_brand'],
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'user_email': userEmail,
      'title': title,
      'content': content,
      'category': category,
      'car_brand': carBrand,
    };
  }

  static const List<Map<String, String>> categories = [
    {'key': 'sikayet', 'label': 'Şikayet', 'icon': 'report'},
    {'key': 'oneri', 'label': 'Öneri', 'icon': 'lightbulb'},
    {'key': 'soru', 'label': 'Soru', 'icon': 'help_outline'},
    {'key': 'genel', 'label': 'Genel', 'icon': 'chat'},
  ];
}
