import 'package:flutter/material.dart';
import '../../../services/reservation_service.dart';

class MyReservationsView extends StatefulWidget {
  const MyReservationsView({super.key});

  @override
  State<MyReservationsView> createState() =>
      _MyReservationsViewState();
}

class _MyReservationsViewState extends State<MyReservationsView> {
  static const Color primaryColor = Color(0xFF075E59);
  static const Color backgroundColor = Color(0xFFF7F4ED);
  static const Color textColor = Color(0xFF263238);
  static const Color secondaryColor = Color(0xFF64748B);

  final ReservationService _reservationService =
      ReservationService();

  List<Map<String, dynamic>> reservations = [];

  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadReservations();
  }

  @override
  void dispose() {
    _reservationService.dispose();
    super.dispose();
  }

  Future<void> _loadReservations() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final result =
          await _reservationService.getMyReservations();

      if (!mounted) return;

      setState(() {
        reservations = result;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage =
            e.toString().replaceFirst('Exception: ', '');
        isLoading = false;
      });
    }
  }

  String _formatDate(dynamic value) {
    if (value == null) return 'Fecha no disponible';

    try {
      final date = DateTime.parse(value.toString());

      const months = ['enero','febrero','marzo','abril','mayo','junio','julio',
        'agosto','septiembre','octubre','noviembre','diciembre',
      ];

      return '${date.day} de ${months[date.month - 1]} de ${date.year}';
    } catch (_) {
      return value.toString();
    }
  }

  String _formatTime(dynamic value) {
    if (value == null) return 'Hora no disponible';

    final time = value.toString();
    final parts = time.split(':');

    if (parts.length < 2) return time;

    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = parts[1];

    final period = hour >= 12 ? 'p. m.' : 'a. m.';
    final formattedHour = hour % 12 == 0 ? 12 : hour % 12;

    return '$formattedHour:$minute $period';
  }

  String _formatPrice(dynamic value) {
    final price = double.tryParse(value?.toString() ?? '') ?? 0;

    return '\$${price.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => '.',
    )}';
  }

  String _formatStatus(dynamic value) {
    switch (value?.toString().toUpperCase()) {
      case 'PENDING':
        return 'Pendiente';
      case 'PAID':
        return 'Pagada';
      case 'CONFIRMED':
        return 'Confirmada';
      case 'CANCELLED':
        return 'Cancelada';
      case 'REJECTED':
        return 'Rechazada';
      default:
        return value?.toString() ?? 'Sin estado';
    }
  }

  Color _statusColor(dynamic value) {
    switch (value?.toString().toUpperCase()) {
      case 'PENDING':
        return const Color(0xFFFFF0CC);
      case 'PAID':
      case 'CONFIRMED':
        return const Color(0xFFDDF3E4);
      case 'CANCELLED':
      case 'REJECTED':
        return const Color(0xFFFCE4E4);
      default:
        return const Color(0xFFEAEAEA);
    }
  }

  Color _statusTextColor(dynamic value) {
    switch (value?.toString().toUpperCase()) {
      case 'PENDING':
        return const Color(0xFF946200);
      case 'PAID':
      case 'CONFIRMED':
        return const Color(0xFF247342);
      case 'CANCELLED':
      case 'REJECTED':
        return const Color(0xFFB3261E);
      default:
        return secondaryColor;
    }
  }

  Widget _buildReservationCard(
    Map<String, dynamic> reservation,
  ) {
    final adults = reservation['adults'] ?? 0;
    final children = reservation['children'] ?? 0;
    final status = reservation['status'];

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: Colors.white,
      elevation: 1.5,
      shadowColor: Colors.black.withValues(alpha: 0.06),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(17),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              reservation['tourName']?.toString() ??
                  'Experiencia Localy',
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                const Icon(
                  Icons.person_outline,
                  size: 17,
                  color: secondaryColor,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Guía: ${reservation['guideName'] ?? 'No disponible'}',
                    style: const TextStyle(
                      color: secondaryColor,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),
            const Divider(color: Color(0xFFECECEC)),
            const SizedBox(height: 12),

            _buildInfoRow(
              Icons.calendar_today_outlined,
              _formatDate(reservation['reservationDate']),
            ),

            const SizedBox(height: 11),

            _buildInfoRow(
              Icons.access_time_rounded,
              _formatTime(reservation['startTime']),
            ),

            const SizedBox(height: 11),

            _buildInfoRow(
              Icons.people_outline_rounded,
              '$adults adultos · $children niños',
            ),

            const SizedBox(height: 17),

            const Divider(color: Color(0xFFECECEC)),

            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: _statusColor(status),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _formatStatus(status),
                    style: TextStyle(
                      color: _statusTextColor(status),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Total',
                      style: TextStyle(
                        fontSize: 11,
                        color: secondaryColor,
                      ),
                    ),
                    Text(
                      _formatPrice(reservation['totalPrice']),
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: primaryColor,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: textColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: const BoxDecoration(
                color: Color(0xFFDCEDE9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.calendar_month_outlined,
                size: 48,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Todavía no tienes reservas',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 9),
            const Text(
              'Explora nuestras experiencias y encuentra '
              'tu próxima aventura.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: secondaryColor,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
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
              errorMessage ?? 'No se pudieron cargar tus reservas.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: textColor),
            ),
            const SizedBox(height: 15),
            ElevatedButton.icon(
              onPressed: _loadReservations,
              icon: const Icon(Icons.refresh),
              label: const Text('Intentar nuevamente'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Mis reservas',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: isLoading ? null : _loadReservations,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Actualizar reservas',
          ),
        ],
      ),
      body: RefreshIndicator(
        color: primaryColor,
        onRefresh: _loadReservations,
        child: isLoading
            ? ListView(
                children: [
                  SizedBox(
                    height: 400,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: primaryColor,
                      ),
                    ),
                  ),
                ],
              )
            : errorMessage != null
                ? ListView(
                    children: [
                      SizedBox(
                        height: 450,
                        child: _buildError(),
                      ),
                    ],
                  )
                : reservations.isEmpty
                    ? ListView(
                        physics:
                            const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(
                            height: 500,
                            child: _buildEmptyState(),
                          ),
                        ],
                      )
                    : ListView.builder(
                        physics:
                            const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(17),
                        itemCount: reservations.length,
                        itemBuilder: (context, index) {
                          return _buildReservationCard(
                            reservations[index],
                          );
                        },
                      ),
      ),
    );
  }
}