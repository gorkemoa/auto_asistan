/// Hatırlatma modeli
class ReminderModel {
  final String id;
  final String vehicleId;
  final String type; // muayene, sigorta, bakim, kasko, diger
  final String title;
  final DateTime? targetDate;
  final int? targetKm;
  final bool isCompleted;
  final bool notificationSent;
  final DateTime createdAt;

  const ReminderModel({
    required this.id,
    required this.vehicleId,
    required this.type,
    required this.title,
    this.targetDate,
    this.targetKm,
    this.isCompleted = false,
    this.notificationSent = false,
    required this.createdAt,
  });

  /// Tip gösterim adı
  String get typeDisplayName {
    switch (type) {
      case 'muayene':
        return 'Muayene';
      case 'sigorta':
        return 'Sigorta';
      case 'bakim':
        return 'Bakım';
      case 'kasko':
        return 'Kasko';
      default:
        return 'Diğer';
    }
  }

  /// Hatırlatma durumu: yaklaşıyor, gecikmiş, normal
  String get status {
    if (isCompleted) return 'completed';
    if (targetDate != null) {
      final daysLeft = targetDate!.difference(DateTime.now()).inDays;
      if (daysLeft < 0) return 'overdue';
      if (daysLeft <= 15) return 'soon';
    }
    return 'active';
  }

  factory ReminderModel.fromJson(Map<String, dynamic> json) {
    return ReminderModel(
      id: json['id'] as String,
      vehicleId: json['vehicle_id'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      targetDate: json['target_date'] != null
          ? DateTime.parse(json['target_date'] as String)
          : null,
      targetKm: json['target_km'] as int?,
      isCompleted: (json['is_completed'] as bool?) ?? false,
      notificationSent: (json['notification_sent'] as bool?) ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vehicle_id': vehicleId,
      'type': type,
      'title': title,
      'target_date': targetDate?.toIso8601String().split('T').first,
      'target_km': targetKm,
      'is_completed': isCompleted,
    };
  }

  /// Hatırlatma tipleri
  static const List<Map<String, String>> types = [
    {'key': 'muayene', 'label': 'TÜVTÜRK Muayene'},
    {'key': 'sigorta', 'label': 'Sigorta Yenileme'},
    {'key': 'kasko', 'label': 'Kasko Yenileme'},
    {'key': 'bakim', 'label': 'Periyodik Bakım'},
    {'key': 'diger', 'label': 'Diğer'},
  ];
}
