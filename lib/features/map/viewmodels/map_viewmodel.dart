import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/place_model.dart';
import '../services/places_api_service.dart';

/// Harita ViewModel
class MapViewModel extends ChangeNotifier {
  final PlacesApiService _placesService = PlacesApiService();

  List<PlaceModel> _places = [];
  Position? _currentPosition;
  bool _isLoading = false;
  String? _error;
  String _selectedFilter = 'all';

  List<PlaceModel> get places => _places;
  Position? get currentPosition => _currentPosition;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedFilter => _selectedFilter;

  /// Konum al ve servisleri ara
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Konum izni kontrol
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _error = 'Konum izni verilmedi';
        _isLoading = false;
        notifyListeners();
        return;
      }

      _currentPosition = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      await _searchPlaces();
    } catch (e) {
      _error = 'Konum alınamadı: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Filtre değiştir
  Future<void> setFilter(String filter) async {
    _selectedFilter = filter;
    notifyListeners();
    await _searchPlaces();
  }

  Future<void> _searchPlaces() async {
    if (_currentPosition == null) return;

    _isLoading = true;
    notifyListeners();

    _places = await _placesService.searchNearby(
      lat: _currentPosition!.latitude,
      lng: _currentPosition!.longitude,
      filter: _selectedFilter == 'all' ? null : _selectedFilter,
    );

    _isLoading = false;
    notifyListeners();
  }
}
