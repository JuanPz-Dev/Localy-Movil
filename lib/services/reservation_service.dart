import 'api_service.dart';

class ReservationService {
  final ApiService _apiService = ApiService();

  Future<Map<String, dynamic>> createReservation({
    required int tourId,
    required String reservationDate,
    required String startTime,
    required int adults,
    required int children,
  }) async {
    if (ApiService.accessToken == null ||
        ApiService.accessToken!.isEmpty) {
      throw Exception('Tu sesión ha expirado. Inicia sesión nuevamente.');
    }

    return await _apiService.post(
      '/reservations/tour/$tourId',
      body: {
        'reservationDate': reservationDate,
        'startTime': startTime,
        'adults': adults,
        'children': children,
      },
    );
  }

  Future<List<Map<String, dynamic>>> getMyReservations({
    int page = 0,
    int size = 20,
  }) async {
    if (ApiService.accessToken == null ||
        ApiService.accessToken!.isEmpty) {
      throw Exception(
        'Tu sesión ha expirado. Inicia sesión nuevamente.',
      );
    }
    final response = await _apiService.get(
      '/reservations/my?page=$page&size=$size',
    );
    return (response['content'] as List)
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  void dispose() {
    _apiService.dispose();
  }
}