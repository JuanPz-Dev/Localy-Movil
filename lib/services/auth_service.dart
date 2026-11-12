import 'api_service.dart';

class AuthService {
  final ApiService _apiService = ApiService();
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiService.post(
      '/auth/login',
      body: {
        'email': email,
        'password': password,
      },
    );
    if (response['accessToken'] == null) {
      throw Exception('El servidor no devolvió el token de acceso.');
    }

    return response;
  }
  
  Future<Map<String, dynamic>> register({
    required String name,
    required String lastName,
    required String email,
    required String password,
  }) async {
    final response = await _apiService.post('/auth/register',
    body: {
      'name': name,
      'lastName': lastName,
      'email': email,
      'password': password,},
    );
    return response;
  }

  void dispose() {
    _apiService.dispose();
  }
}
