import 'package:flutter/material.dart';

import '../../models/tour_service.dart';
import '../../services/tour_service.dart';
import '../../screens/tour/reservation/reservation_card.dart';

class TourDetailView extends StatefulWidget {
  final int tourId;

  const TourDetailView({
    super.key,
    required this.tourId,
  });

  @override
  State<TourDetailView> createState() => _TourDetailViewState();
}

class _TourDetailViewState extends State<TourDetailView> {
  static const Color primaryColor = Color(0xFF075E59);
  static const Color backgroundColor = Color(0xFFF7F4ED);
  static const Color textColor = Color(0xFF263238);
  static const Color secondaryColor = Color(0xFF64748B);

  final TourServiceApi _tourService = TourServiceApi();

  TourService? tour;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadTour();
  }

  Future<void> _loadTour() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final result = await _tourService.getTourById(widget.tourId);

      if (!mounted) return;

      setState(() {
        tour = result;
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

  String _formatPrice(double price) {
    return '\$${price.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => '.',
    )}';
  }

  String _formatCategory(String category) {
    switch (category) {
      case 'HISTORICAL':
        return 'Histórica';
      case 'ISLANDS_AND_BEACHES':
        return 'Islas y playas';
      case 'GASTRONOMIC':
        return 'Gastronómica';
      case 'CULTURAL':
        return 'Cultural';
      case 'NIGHTLIFE':
        return 'Vida nocturna';
      default:
        return category.replaceAll('_', ' ');
    }
  }

  String _formatDay(String day) {
    const days = {
      'MONDAY': 'Lunes',
      'TUESDAY': 'Martes',
      'WEDNESDAY': 'Miércoles',
      'THURSDAY': 'Jueves',
      'FRIDAY': 'Viernes',
      'SATURDAY': 'Sábado',
      'SUNDAY': 'Domingo',
    };

    return days[day] ?? day;
  }

  String _formatDuration(int minutes) {
    if (minutes <= 0) return 'No especificada';

    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;

    if (hours == 0) return '$remainingMinutes minutos';
    if (remainingMinutes == 0) return '$hours ${hours == 1 ? 'hora' : 'horas'}';

    return '$hours h $remainingMinutes min';
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
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        title: const Text(
          'Detalle de experiencia',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: primaryColor),
            )
          : errorMessage != null
              ? _buildError()
              : tour == null
                  ? const Center(child: Text('Experiencia no encontrada'))
                  : _buildContent(tour!),
    );
  }

  Widget _buildContent(TourService item) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGallery(item),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCategory(item.category),
                const SizedBox(height: 10),

                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    height: 1.25,
                  ),
                ),

                const SizedBox(height: 12),
                _buildRating(item),

                const SizedBox(height: 22),
                _buildPrice(item.price),

                const SizedBox(height: 25),
                _buildSectionTitle('Sobre esta experiencia'),
                const SizedBox(height: 9),
                Text(
                  item.description,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.6,
                    color: secondaryColor,
                  ),
                ),

                const SizedBox(height: 25),
                _buildSectionTitle('Tu guía'),
                const SizedBox(height: 12),
                _buildGuide(item),

                const SizedBox(height: 25),
                _buildSectionTitle('Detalles de la experiencia'),
                const SizedBox(height: 14),
                _buildInfoRow(
                  Icons.schedule_rounded,
                  'Duración',
                  _formatDuration(item.durationMinutes),
                ),
                const SizedBox(height: 13),
                _buildInfoRow(
                  Icons.groups_outlined,
                  'Participantes',
                  '${item.minParticipants} a ${item.maxParticipants} personas',
                ),

                const SizedBox(height: 25),
                _buildSectionTitle('Horarios disponibles'),
                const SizedBox(height: 12),
                if (item.schedules.isEmpty)
                  _buildEmptyText('No hay horarios registrados.')
                else
                  ...item.schedules.map(
                    (schedule) => _buildSchedule(schedule),
                  ),

                const SizedBox(height: 25),
                _buildSectionTitle('¿Qué incluye?'),
                const SizedBox(height: 12),
                if (item.features.isEmpty)
                  _buildEmptyText('No hay características registradas.')
                else
                  ...item.features.map(
                    (feature) => _buildFeature(feature),
                  ),

                const SizedBox(height: 25),
                _buildSectionTitle('Punto de encuentro'),
                const SizedBox(height: 12),
                if (item.meetingLocation == null)
                  _buildEmptyText('Ubicación no disponible.')
                else
                  _buildLocation(item.meetingLocation!),
                  const SizedBox(height: 25),
                  ReservationCard(tour: item),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGallery(TourService item) {
    if (item.photos.isEmpty) {
      return Container(
        height: 260,
        width: double.infinity,
        color: Colors.grey.shade300,
        child: const Icon(Icons.image_outlined, size: 60),
      );
    }

    return SizedBox(
      height: 270,
      child: PageView.builder(
        itemCount: item.photos.length,
        itemBuilder: (context, index) {
          return Image.network(
            item.photos[index],
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: Colors.grey.shade300,
              child: const Icon(Icons.broken_image_outlined, size: 50),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategory(String category) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFE0EEEA),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _formatCategory(category),
        style: const TextStyle(
          color: primaryColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildRating(TourService item) {
    return Row(
      children: [
        const Icon(Icons.star_rounded, color: Colors.amber, size: 21),
        const SizedBox(width: 5),
        Text(
          item.reviewCount > 0
              ? '${item.averageRating.toStringAsFixed(1)} (${item.reviewCount} reseñas)'
              : 'Aún no tiene reseñas',
          style: const TextStyle(
            color: secondaryColor,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildPrice(double price) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Precio por persona',
            style: TextStyle(color: secondaryColor, fontSize: 12),
          ),
          const SizedBox(height: 5),
          Text(
            _formatPrice(price),
            style: const TextStyle(
              color: primaryColor,
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: textColor,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildGuide(TourService item) {
    return Row(
      children: [
        CircleAvatar(
          radius: 25,
          backgroundColor: const Color(0xFFE0EEEA),
          backgroundImage: item.guideProfilePicture != null &&
                  item.guideProfilePicture!.isNotEmpty
              ? NetworkImage(item.guideProfilePicture!)
              : null,
          child: item.guideProfilePicture == null ||
                  item.guideProfilePicture!.isEmpty
              ? const Icon(Icons.person, color: primaryColor)
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            item.guideName,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, color: primaryColor, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(color: secondaryColor, fontSize: 13),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: textColor,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildSchedule(TourSchedule schedule) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          const Icon(
            Icons.access_time_rounded,
            color: primaryColor,
            size: 20,
          ),
          const SizedBox(width: 10),
          Text(
            _formatDay(schedule.day),
            style: const TextStyle(color: textColor, fontSize: 14),
          ),
          const Spacer(),
          Text(
            schedule.startTime,
            style: const TextStyle(
              color: primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeature(ServiceFeature feature) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(
            feature.included ? Icons.check_circle : Icons.cancel_outlined,
            color: feature.included ? primaryColor : secondaryColor,
            size: 19,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              feature.name,
              style: const TextStyle(color: textColor, fontSize: 14),
            ),
          ),
          Text(
            feature.included ? 'Incluido' : 'No incluido',
            style: const TextStyle(
              color: secondaryColor,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocation(MeetingLocation location) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                color: primaryColor,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  location.city,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            location.meetingAddress,
            style: const TextStyle(
              color: secondaryColor,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          if (location.latitude != null && location.longitude != null) ...[
            const SizedBox(height: 8),
            Text(
              'Coordenadas: ${location.latitude}, ${location.longitude}',
              style: const TextStyle(
                color: secondaryColor,
                fontSize: 11,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyText(String message) {
    return Text(
      message,
      style: const TextStyle(color: secondaryColor, fontSize: 13),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.cloud_off_outlined,
              size: 50,
              color: secondaryColor,
            ),
            const SizedBox(height: 15),
            Text(
              errorMessage ?? 'No se pudo cargar la experiencia.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: _loadTour,
              child: const Text('Intentar nuevamente'),
            ),
          ],
        ),
      ),
    );
  }
}
