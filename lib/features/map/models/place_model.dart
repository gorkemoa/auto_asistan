/// Yer/mekan modeli — harita için
class PlaceModel {
  final String name;
  final String? category;
  final double lat;
  final double lng;
  final String? address;
  final double? distance; // km
  final String? phone;
  final double? rating;

  const PlaceModel({
    required this.name,
    this.category,
    required this.lat,
    required this.lng,
    this.address,
    this.distance,
    this.phone,
    this.rating,
  });

  factory PlaceModel.fromOverpassJson(Map<String, dynamic> json) {
    final tags = json['tags'] as Map<String, dynamic>? ?? {};
    return PlaceModel(
      name: tags['name'] as String? ?? 'Bilinmeyen',
      category: tags['shop'] as String? ??
          tags['craft'] as String? ??
          tags['amenity'] as String?,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lon'] as num).toDouble(),
      address: tags['addr:street'] as String?,
      phone: tags['phone'] as String?,
    );
  }
}
