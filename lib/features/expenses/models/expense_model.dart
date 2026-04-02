class ExpenseModel {
  final String id;
  final String vehicleId;
  final String category; // yakit, bakim, sigorta, kasko, yikama, otopark, diger
  final double amount;
  final DateTime date;
  final String? description;
  final DateTime createdAt;

  const ExpenseModel({
    required this.id,
    required this.vehicleId,
    required this.category,
    required this.amount,
    required this.date,
    this.description,
    required this.createdAt,
  });

  /// Kategori görsel adı
  String get categoryDisplayName {
    switch (category) {
      case 'yakit':
        return 'Yakıt';
      case 'bakim':
        return 'Bakım';
      case 'sigorta':
        return 'Sigorta';
      case 'kasko':
        return 'Kasko';
      case 'yikama':
        return 'Yıkama';
      case 'otopark':
        return 'Otopark';
      default:
        return 'Diğer';
    }
  }

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['id'] as String,
      vehicleId: json['vehicle_id'] as String,
      category: json['category'] as String,
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vehicle_id': vehicleId,
      'category': category,
      'amount': amount,
      'date': date.toIso8601String().split('T').first,
      'description': description,
    };
  }

  /// Gider kategorileri
  static const List<Map<String, String>> categories = [
    {'key': 'yakit', 'label': 'Yakıt', 'icon': 'local_gas_station'},
    {'key': 'bakim', 'label': 'Bakım', 'icon': 'build'},
    {'key': 'sigorta', 'label': 'Sigorta', 'icon': 'security'},
    {'key': 'kasko', 'label': 'Kasko', 'icon': 'shield'},
    {'key': 'yikama', 'label': 'Yıkama', 'icon': 'local_car_wash'},
    {'key': 'otopark', 'label': 'Otopark', 'icon': 'local_parking'},
    {'key': 'diger', 'label': 'Diğer', 'icon': 'more_horiz'},
  ];
}
