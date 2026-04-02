/// Araç modeli
class VehicleModel {
  final String id;
  final String userId;
  final String brand;
  final String model;
  final int year;
  final String? engineType;
  final String? plate;
  final int currentKm;
  final String? color;
  final String? imageUrl;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const VehicleModel({
    required this.id,
    required this.userId,
    required this.brand,
    required this.model,
    required this.year,
    this.engineType,
    this.plate,
    this.currentKm = 0,
    this.color,
    this.imageUrl,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Araç gösterim adı
  String get displayName => '$brand $model';

  /// Araç detay metni
  String get subtitle => '$year • ${engineType ?? ""} • ${plate ?? ""}';

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      brand: json['brand'] as String,
      model: json['model'] as String,
      year: json['year'] as int,
      engineType: json['engine_type'] as String?,
      plate: json['plate'] as String?,
      currentKm: (json['current_km'] as int?) ?? 0,
      color: json['color'] as String?,
      imageUrl: json['image_url'] as String?,
      isActive: (json['is_active'] as bool?) ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'brand': brand,
      'model': model,
      'year': year,
      'engine_type': engineType,
      'plate': plate,
      'current_km': currentKm,
      'color': color,
      'image_url': imageUrl,
      'is_active': isActive,
    };
  }

  VehicleModel copyWith({
    String? brand,
    String? model,
    int? year,
    String? engineType,
    String? plate,
    int? currentKm,
    String? color,
    String? imageUrl,
    bool? isActive,
  }) {
    return VehicleModel(
      id: id,
      userId: userId,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      year: year ?? this.year,
      engineType: engineType ?? this.engineType,
      plate: plate ?? this.plate,
      currentKm: currentKm ?? this.currentKm,
      color: color ?? this.color,
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}

/// Araç checklist item modeli
class ChecklistItemModel {
  final String id;
  final String vehicleId;
  final String itemName;
  final bool isChecked;
  final DateTime updatedAt;

  const ChecklistItemModel({
    required this.id,
    required this.vehicleId,
    required this.itemName,
    this.isChecked = false,
    required this.updatedAt,
  });

  factory ChecklistItemModel.fromJson(Map<String, dynamic> json) {
    return ChecklistItemModel(
      id: json['id'] as String,
      vehicleId: json['vehicle_id'] as String,
      itemName: json['item_name'] as String,
      isChecked: (json['is_checked'] as bool?) ?? false,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vehicle_id': vehicleId,
      'item_name': itemName,
      'is_checked': isChecked,
    };
  }

  /// Varsayılan araç malzemeleri listesi
  static List<String> get defaultItems => [
        'İlk Yardım Çantası',
        'Yangın Söndürücü',
        'Reflektör / Yansıtıcı',
        'Yedek Lastik',
        'Kriko ve Bijon Anahtarı',
        'Çekme Halatı',
        'Takviye Kablosu',
        'Cam Silecek Suyu',
        'El Feneri',
        'Uyarı Üçgeni',
        'Araç Sigorta Poliçesi',
        'Ruhsat Fotokopisi',
      ];
}
