import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/widgets/auto_card.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../viewmodels/map_viewmodel.dart';
import '../models/place_model.dart';

/// Akıllı Harita ekranı
class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  final _viewModel = MapViewModel();
  final _mapController = MapController();
  PlaceModel? _selectedPlace;

  final _filters = [
    {
      'key': 'all',
      'label': AppStrings.allCategories,
      'icon': Icons.apps_rounded,
    },
    {
      'key': 'car_repair',
      'label': AppStrings.autoRepair,
      'icon': Icons.build_rounded,
    },
    {'key': 'fuel', 'label': 'Yakıt', 'icon': Icons.local_gas_station_rounded},
    {
      'key': 'inspection',
      'label': AppStrings.inspectionStation,
      'icon': Icons.fact_check_rounded,
    },
  ];

  @override
  void initState() {
    super.initState();
    _viewModel.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          if (_viewModel.isLoading && _viewModel.currentPosition == null) {
            return const LoadingIndicator(message: 'Konum alınıyor...');
          }

          if (_viewModel.error != null && _viewModel.currentPosition == null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.location_off_rounded,
                    size: 48,
                    color: AppColors.textTertiary,
                  ),
                  const SizedBox(height: 16),
                  Text(_viewModel.error!, style: AppTypography.bodyMedium),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _viewModel.initialize,
                    child: const Text(AppStrings.retry),
                  ),
                ],
              ),
            );
          }

          final pos = _viewModel.currentPosition;
          final center = pos != null
              ? LatLng(pos.latitude, pos.longitude)
              : const LatLng(39.9208, 32.8541); // Ankara default

          return Stack(
            children: [
              // Harita
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: center,
                  initialZoom: 14,
                  onTap: (tapPosition, point) =>
                      setState(() => _selectedPlace = null),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.autoassist.app',
                  ),

                  // Kullanıcı konumu
                  if (pos != null)
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: center,
                          width: 24,
                          height: 24,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.accentBlue,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.accentBlue.withValues(
                                    alpha: 0.4,
                                  ),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                  // Mekan marker'ları
                  MarkerLayer(
                    markers: _viewModel.places.map((place) {
                      return Marker(
                        point: LatLng(place.lat, place.lng),
                        width: 36,
                        height: 36,
                        child: GestureDetector(
                          onTap: () {
                            final url =
                                'https://www.google.com/maps/dir/?api=1&destination=${place.lat},${place.lng}';
                            launchUrl(
                              Uri.parse(url),
                              mode: LaunchMode.externalApplication,
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.danger,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.build_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),

              // Filtre çubuğu
              Positioned(
                top: MediaQuery.of(context).padding.top + 12,
                left: 12,
                right: 12,
                child: SizedBox(
                  height: 42,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _filters.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final filter = _filters[index];
                      final isSelected =
                          _viewModel.selectedFilter == filter['key'];
                      return ChoiceChip(
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              filter['icon'] as IconData,
                              size: 16,
                              color: isSelected
                                  ? AppColors.accentBlue
                                  : AppColors.textSecondary,
                            ),
                            const SizedBox(width: 6),
                            Text(filter['label'] as String),
                          ],
                        ),
                        selected: isSelected,
                        onSelected: (_) =>
                            _viewModel.setFilter(filter['key'] as String),
                        backgroundColor: AppColors.surfaceCard,
                        elevation: 2,
                      );
                    },
                  ),
                ),
              ),

              // Yükleniyor göstergesi
              if (_viewModel.isLoading)
                const Positioned(
                  top: 100,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.accentBlue,
                    ),
                  ),
                ),

              // Seçili mekan kartı
              if (_selectedPlace != null)
                Positioned(
                  bottom: MediaQuery.of(context).padding.bottom + 16,
                  left: 16,
                  right: 16,
                  child: _buildPlaceCard(_selectedPlace!),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPlaceCard(PlaceModel place) {
    return AutoCard(
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.accentBlue.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            ),
            child: const Icon(
              Icons.location_on_rounded,
              color: AppColors.accentBlue,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(place.name, style: AppTypography.labelLarge),
                if (place.address != null)
                  Text(place.address!, style: AppTypography.caption),
                if (place.phone != null) ...[
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: () => launchUrl(Uri.parse('tel:${place.phone}')),
                    child: Text(
                      place.phone!,
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.accentBlue,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              final url =
                  'https://www.google.com/maps/dir/?api=1&destination=${place.lat},${place.lng}';
              launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
            },
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.accentBlue,
                borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
              ),
              child: const Icon(
                Icons.directions_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
