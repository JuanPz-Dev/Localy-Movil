import 'package:flutter/material.dart';

import '../../../models/tour_service.dart';
import '../../../services/reservation_service.dart';

class ReservationCard extends StatefulWidget {
  final TourService tour;

  const ReservationCard({
    super.key,
    required this.tour,
  });

  @override
  State<ReservationCard> createState() => _ReservationCardState();
}

class _ReservationCardState extends State<ReservationCard> {
  static const Color primaryColor = Color(0xFF075E59);
  static const Color textColor = Color(0xFF263238);
  static const Color secondaryColor = Color(0xFF64748B);

  final ReservationService _reservationService = ReservationService();

  DateTime? selectedDate;
  String? selectedStartTime;

  int adults = 1;
  int children = 0;

  bool isLoading = false;
  bool isReserved = false;

  int get participants => adults + children;

  double get totalPrice => widget.tour.price * participants;

  bool get validParticipants =>
      participants >= widget.tour.minParticipants &&
      participants <= widget.tour.maxParticipants;

  bool _isAvailableDay(DateTime date) {
    const weekdays = {
      1: 'MONDAY',
      2: 'TUESDAY',
      3: 'WEDNESDAY',
      4: 'THURSDAY',
      5: 'FRIDAY',
      6: 'SATURDAY',
      7: 'SUNDAY',
    };

    final day = weekdays[date.weekday];

    return widget.tour.schedules.any(
      (schedule) => schedule.day.toUpperCase() == day,
    );
  }

  List<TourSchedule> get availableSchedules {
    if (selectedDate == null) return [];

    const weekdays = {
      1: 'MONDAY',
      2: 'TUESDAY',
      3: 'WEDNESDAY',
      4: 'THURSDAY',
      5: 'FRIDAY',
      6: 'SATURDAY',
      7: 'SUNDAY',
    };

    final day = weekdays[selectedDate!.weekday];

    return widget.tour.schedules
        .where((schedule) => schedule.day.toUpperCase() == day)
        .toList();
  }

  DateTime? _nextAvailableDate() {
    final today = DateUtils.dateOnly(DateTime.now());

    for (int i = 0; i <= 365; i++) {
      final date = today.add(Duration(days: i));

      if (_isAvailableDay(date)) {
        return date;
      }
    }

    return null;
  }

  Future<void> _selectDate() async {
    final firstDate = DateUtils.dateOnly(DateTime.now());
    final initialDate = _nextAvailableDate();

    if (initialDate == null) {
      _showMessage('Este servicio no tiene horarios disponibles.');
      return;
    }

    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: firstDate.add(const Duration(days: 365)),
      selectableDayPredicate: _isAvailableDay,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: textColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      setState(() {
        selectedDate = date;
        selectedStartTime = null;
      });
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'enero', 'febrero', 'marzo', 'abril',
      'mayo', 'junio', 'julio', 'agosto',
      'septiembre', 'octubre', 'noviembre', 'diciembre',
    ];

    return '${date.day} de ${months[date.month - 1]} de ${date.year}';
  }

  String _formatPrice(double price) {
    return '\$${price.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => '.',
    )}';
  }

  String _formatStartTime(String time) {
    final parts = time.split(':');

    if (parts.length == 2) {
      return '${parts[0]}:${parts[1]}:00';
    }

    return time;
  }

  void _changeAdults(int value) {
    setState(() {
      final newValue = adults + value;

      if (newValue >= 1 &&
          newValue + children <= widget.tour.maxParticipants) {
        adults = newValue;
      }
    });
  }

  void _changeChildren(int value) {
    setState(() {
      final newValue = children + value;

      if (newValue >= 0 &&
          adults + newValue <= widget.tour.maxParticipants) {
        children = newValue;
      }
    });
  }

  Future<void> _confirmReservation() async {
    if (isReserved || isLoading) return;

    if (selectedDate == null) {
      _showMessage('Selecciona una fecha para tu experiencia.');
      return;
    }

    if (selectedStartTime == null) {
      _showMessage('Selecciona un horario disponible.');
      return;
    }

    if (!validParticipants) {
      _showMessage(
        'Debes seleccionar entre ${widget.tour.minParticipants} y '
        '${widget.tour.maxParticipants} participantes.',
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final date =
          '${selectedDate!.year.toString().padLeft(4, '0')}-'
          '${selectedDate!.month.toString().padLeft(2, '0')}-'
          '${selectedDate!.day.toString().padLeft(2, '0')}';

      final response = await _reservationService.createReservation(
        tourId: widget.tour.id,
        reservationDate: date,
        startTime: _formatStartTime(selectedStartTime!),
        adults: adults,
        children: children,
      );

      if (!mounted) return;

      setState(() {
        isReserved = true;
      });

      _showSuccessDialog(response);
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        e.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _showSuccessDialog(Map<String, dynamic> response) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          icon: const Icon(
            Icons.check_circle_rounded,
            color: primaryColor,
            size: 55,
          ),
          title: const Text(
            '¡Reserva realizada!',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Tu solicitud de reserva fue registrada correctamente.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Reserva #${response['id'] ?? ''}',
                style: const TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Estado: ${response['status'] ?? 'PENDING'}',
              ),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(dialogContext),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Continuar'),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  void dispose() {
    _reservationService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFFE8E5DE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Reserva tu experiencia',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Selecciona cuándo quieres vivirla.',
            style: TextStyle(
              fontSize: 13,
              color: secondaryColor,
            ),
          ),
          const SizedBox(height: 20),

          const Text(
            'Fecha de la experiencia',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 9),

          InkWell(
            onTap: isReserved ? null : _selectDate,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F4ED),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE8E5DE)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_month_rounded,
                    color: primaryColor,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      selectedDate == null
                          ? 'Seleccionar fecha'
                          : _formatDate(selectedDate!),
                      style: const TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: secondaryColor,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            'Horario disponible',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 9),

          if (selectedDate == null)
            const Text(
              'Primero selecciona una fecha.',
              style: TextStyle(color: secondaryColor, fontSize: 13),
            )
          else if (availableSchedules.isEmpty)
            const Text(
              'No hay horarios para esta fecha.',
              style: TextStyle(color: secondaryColor, fontSize: 13),
            )
          else
            Wrap(
              spacing: 9,
              runSpacing: 9,
              children: availableSchedules.map((schedule) {
                final selected = selectedStartTime == schedule.startTime;

                return ChoiceChip(
                  label: Text(schedule.startTime),
                  selected: selected,
                  showCheckmark: false,
                  onSelected: isReserved
                      ? null
                      : (_) {
                          setState(() {
                            selectedStartTime = schedule.startTime;
                          });
                        },
                  selectedColor: primaryColor,
                  backgroundColor: const Color(0xFFF7F4ED),
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : textColor,
                    fontWeight: FontWeight.w600,
                  ),
                  side: BorderSide(
                    color: selected
                        ? primaryColor
                        : const Color(0xFFE8E5DE),
                  ),
                );
              }).toList(),
            ),

          const SizedBox(height: 22),
          const Divider(color: Color(0xFFECECEC)),
          const SizedBox(height: 15),

          const Text(
            'Participantes',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 13),

          _buildCounter(
            title: 'Adultos',
            subtitle: 'Mínimo 1 adulto',
            value: adults,
            onDecrease: () => _changeAdults(-1),
            onIncrease: () => _changeAdults(1),
            decreaseDisabled: adults <= 1 || isReserved,
            increaseDisabled:
                participants >= widget.tour.maxParticipants || isReserved,
          ),

          const SizedBox(height: 15),

          _buildCounter(
            title: 'Niños',
            subtitle: 'Precio igual por participante',
            value: children,
            onDecrease: () => _changeChildren(-1),
            onIncrease: () => _changeChildren(1),
            decreaseDisabled: children <= 0 || isReserved,
            increaseDisabled:
                participants >= widget.tour.maxParticipants || isReserved,
          ),

          const SizedBox(height: 13),

          if (!validParticipants)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                'Esta experiencia requiere entre '
                '${widget.tour.minParticipants} y '
                '${widget.tour.maxParticipants} participantes.',
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                ),
              ),
            ),

          const Divider(color: Color(0xFFECECEC)),
          const SizedBox(height: 13),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Precio por persona',
                style: TextStyle(color: secondaryColor, fontSize: 12),
              ),
              Text(
                _formatPrice(widget.tour.price),
                style: const TextStyle(color: textColor, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 9),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total de participantes',
                style: TextStyle(color: secondaryColor, fontSize: 12),
              ),
              Text(
                '$participants',
                style: const TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total estimado',
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              Text(
                _formatPrice(totalPrice),
                style: const TextStyle(
                  color: primaryColor,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 19),

          SizedBox(
            width: double.infinity,
            height: 51,
            child: ElevatedButton(
              onPressed: isLoading || isReserved
                  ? null
                  : _confirmReservation,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                disabledBackgroundColor: primaryColor.withValues(alpha: 0.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      height: 23,
                      width: 23,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : Text(
                      isReserved ? 'Reserva registrada' : 'Confirmar reserva',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),

          const SizedBox(height: 9),

          const Text(
            'El precio se calcula según la cantidad de participantes.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: secondaryColor,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCounter({
    required String title,
    required String subtitle,
    required int value,
    required VoidCallback onDecrease,
    required VoidCallback onIncrease,
    required bool decreaseDisabled,
    required bool increaseDisabled,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 11,
                  color: secondaryColor,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: decreaseDisabled ? null : onDecrease,
          icon: const Icon(Icons.remove_circle_outline),
          color: primaryColor,
        ),
        Text(
          '$value',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        IconButton(
          onPressed: increaseDisabled ? null : onIncrease,
          icon: const Icon(Icons.add_circle_outline),
          color: primaryColor,
        ),
      ],
    );
  }
}