import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../models/tour_service.dart';
import '../../services/tour_service.dart';
import '../tour/tour_detail_view.dart';

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  static const Color primaryColor = Color(0xFF075E59);
  static const Color backgroundColor = Color(0xFFF7F4ED);
  static const Color textColor = Color(0xFF263238);
  static const Color secondaryColor = Color(0xFF64748B);

  // Centro inicial aproximado de Cartagena.
  static const LatLng initialPosition = LatLng(10.3910, -75.4794);

  final TourServiceApi _tourService = TourServiceApi();
  final MapController _mapController = MapController();

  List<TourService> tours = [];
  TourService? selectedTour;

  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadTours();
  }

  Future<void> _loadTours() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final List<TourService> loadedTours = [];

      const int pageSize = 50;
      int currentPage = 0;
      int totalElements = 0;

      // Cargamos todas las páginas para no dejar experiencias por fuera.
      do {
        final result = await _tourService.getTours(
          page: currentPage,
          size: pageSize,
        );

        loadedTours.addAll(result.content);
        totalElements = result.totalElements;
        currentPage++;

        if (result.content.isEmpty) break;
      } while (loadedTours.length < totalElements);

      if (!mounted) return;

      setState(() {
        tours = loadedTours;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = e.toString().replaceFirst('Exception: ', '');
        isLoading = false;
      });
    }
  }

  // Solo mostramos experiencias con coordenadas válidas.
  List<TourService> get toursWithLocation {
    return tours.where((tour) {
      final location = tour.meetingLocation;

      if (location == null ||
          location.latitude == null ||
          location.longitude == null) {
        return false;
      }

      final latitude = location.latitude!;
      final longitude = location.longitude!;

      return latitude.isFinite &&
          longitude.isFinite &&
          latitude >= -90 &&
          latitude <= 90 &&
          longitude >= -180 &&
          longitude <= 180;
    }).toList();
  }

  LatLng _getPosition(TourService tour) {
    final location = tour.meetingLocation!;

    return LatLng(
      location.latitude!,
      location.longitude!,
    );
  }

  void _selectTour(TourService tour) {
    setState(() {
      selectedTour = tour;
    });

    _mapController.move(_getPosition(tour), 15);
  }

  void _openTourDetail(TourService tour) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TourDetailView(
          tourId: tour.id,
        ),
      ),
    );
  }

  String _formatPrice(double price) {
    return '\$${price.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => '.',
    )}';
  }

  @override
  void dispose() {
    _tourService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Mapa de experiencias',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _loadTours,
            tooltip: 'Actualizar mapa',
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: primaryColor,
        ),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cloud_off_outlined,
                size: 48,
                color: secondaryColor,
              ),
              const SizedBox(height: 15),
              Text(
                errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: textColor),
              ),
              const SizedBox(height: 15),
              ElevatedButton(
                onPressed: _loadTours,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Intentar nuevamente'),
              ),
            ],
          ),
        ),
      );
    }

    final locatedTours = toursWithLocation;

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: initialPosition,
            initialZoom: 11.5,
            minZoom: 3,
            maxZoom: 18,
            onTap: (_, __) {
              setState(() {
                selectedTour = null;
              });
            },
          ),
          children: [
            TileLayer(
              urlTemplate:
                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.localyapp',
            ),
            MarkerLayer(
              markers: locatedTours.map((tour) {
                final isSelected = selectedTour?.id == tour.id;

                return Marker(
                  point: _getPosition(tour),
                  width: 48,
                  height: 55,
                  child: GestureDetector(
                    onTap: () => _selectTour(tour),
                    child: Icon(
                      Icons.location_on,
                      size: isSelected ? 48 : 42,
                      color: isSelected
                          ? const Color(0xFFE58A32)
                          : primaryColor,
                      shadows: const [
                        Shadow(
                          color: Colors.black26,
                          blurRadius: 5,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            RichAttributionWidget(
              alignment: AttributionAlignment.bottomRight,
              attributions: [
                TextSourceAttribution('© OpenStreetMap contributors'),
              ],
            ),
          ],
        ),

        // Indicador de experiencias ubicadas.
        Positioned(
          top: 14,
          left: 14,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 13,
              vertical: 9,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.10),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.place_rounded,
                  color: primaryColor,
                  size: 19,
                ),
                const SizedBox(width: 6),
                Text(
                  '${locatedTours.length} experiencias en el mapa',
                  style: const TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Tarjeta de la experiencia seleccionada.
        if (selectedTour != null)
          Positioned(
            left: 14,
            right: 14,
            bottom: 18,
            child: _buildSelectedTourCard(selectedTour!),
          ),

        // Mensaje cuando todavía no hay coordenadas registradas.
        if (locatedTours.isEmpty)
          Positioned(
            left: 20,
            right: 20,
            bottom: 35,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.10),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: const Text(
                'Todavía no hay experiencias con ubicación disponible.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textColor,
                  fontSize: 13,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSelectedTourCard(TourService tour) {
    final location = tour.meetingLocation;

    return Card(
      color: Colors.white,
      elevation: 7,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(17),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: tour.photos.isNotEmpty
                      ? Image.network(
                          tour.photos.first,
                          width: 85,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              _imagePlaceholder(),
                        )
                      : _imagePlaceholder(),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tour.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            color: secondaryColor,
                            size: 15,
                          ),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              location?.meetingAddress ?? 'Ubicación disponible',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: secondaryColor,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Desde ${_formatPrice(tour.price)}',
                        style: const TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      selectedTour = null;
                    });
                  },
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                  icon: const Icon(
                    Icons.close,
                    color: secondaryColor,
                    size: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _openTourDetail(tour),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Ver experiencia',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      width: 85,
      height: 80,
      color: const Color(0xFFE9E8E2),
      child: const Icon(
        Icons.image_outlined,
        color: secondaryColor,
        size: 30,
      ),
    );
  }
}
