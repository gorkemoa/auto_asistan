import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/utils/logger.dart';
import '../models/place_model.dart';

/// Overpass API (OpenStreetMap) ile yakın mekan arama
class PlacesApiService {
  static const _overpassUrl = 'https://overpass-api.de/api/interpreter';

  /// Yakındaki oto servis/tamirci/sanayi ara
  Future<List<PlaceModel>> searchNearby({
    required double lat,
    required double lng,
    double radiusKm = 5.0,
    String? filter, // car_repair, fuel, inspection
  }) async {
    final radiusMeters = (radiusKm * 1000).round();

    String amenityFilter;
    switch (filter) {
      case 'car_repair':
        amenityFilter = '''
          node["shop"="car_repair"](around:$radiusMeters,$lat,$lng);
          node["craft"="car_repair"](around:$radiusMeters,$lat,$lng);
          node["amenity"="car_repair"](around:$radiusMeters,$lat,$lng);
        ''';
        break;
      case 'fuel':
        amenityFilter =
            'node["amenity"="fuel"](around:$radiusMeters,$lat,$lng);';
        break;
      case 'inspection':
        amenityFilter = '''
          node["amenity"="vehicle_inspection"](around:$radiusMeters,$lat,$lng);
          node["office"="government"]["name"~"TÜVTÜRK",i](around:$radiusMeters,$lat,$lng);
        ''';
        break;
      default:
        amenityFilter = '''
          node["shop"="car_repair"](around:$radiusMeters,$lat,$lng);
          node["craft"="car_repair"](around:$radiusMeters,$lat,$lng);
          node["amenity"="car_repair"](around:$radiusMeters,$lat,$lng);
          node["amenity"="fuel"](around:$radiusMeters,$lat,$lng);
          node["amenity"="vehicle_inspection"](around:$radiusMeters,$lat,$lng);
          node["shop"="car_parts"](around:$radiusMeters,$lat,$lng);
        ''';
    }

    final query = '''
      [out:json][timeout:25];
      (
        $amenityFilter
      );
      out body;
    ''';

    final body = {'data': query};
    AppLogger.apiRequest('POST', _overpassUrl, body);

    try {
      final response = await http.post(
        Uri.parse(_overpassUrl),
        body: body,
      );

      AppLogger.apiResponse('POST', _overpassUrl, response.statusCode, response.body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final elements = data['elements'] as List;
        return elements
            .map((e) => PlaceModel.fromOverpassJson(e))
            .toList();
      }
      return [];
    } catch (e, stackTrace) {
      AppLogger.error('Harita Arama Hatası', e, stackTrace);
      return [];
    }
  }
}
