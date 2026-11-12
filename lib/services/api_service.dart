import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://192.168.1.72:8080';
  static String? accessToken;

  final http.Client _client = http.Client();

  Map<String, String> get _headers => {'Content-Type': 'application/json', 'Accept': 'application/json',
  if (accessToken != null)
  'Authorization': 'Bearer $accessToken',
  };

  Future<Map<String, dynamic>> post(
    String endpoint, {
    required Map<String, dynamic> body,
  }) async {
    try {
      final response = await _client
          .post(Uri.parse('$baseUrl$endpoint'),
          headers: _headers,
          body: jsonEncode(body),
          ).timeout(const Duration(seconds: 20));

      final dynamic responseData = response.body.isNotEmpty ? jsonDecode(response.body) : {};
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return Map<String, dynamic>.from(responseData);
      }
      String message = 'Ocurrió un error en el servidor';
      if (responseData is Map) {
        message = responseData['message']?.toString() ??
            responseData['error']?.toString() ??
            message;
      }
      throw Exception(message);
    } catch (e) {
      if (e is FormatException) {
        throw Exception('El servidor devolvió una respuesta no válida.');
      }
      rethrow;
    }
  }

  Future<dynamic> get(String endpoint) async {
  try {
    final response = await _client
        .get(
          Uri.parse('$baseUrl$endpoint'),
          headers: _headers,
        )
        .timeout(const Duration(seconds: 20));

    final dynamic responseData = response.body.isNotEmpty
        ? jsonDecode(response.body) : {};
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return responseData;
      }
    String message = 'Ocurrió un error en el servidor';
    if (responseData is Map) {
      message = responseData['message']?.toString() ??
          responseData['error']?.toString() ?? message;
        }

    throw Exception(message);
    } catch (e) {
      if (e is FormatException) {
        throw Exception('El servidor devolvió una respuesta no válida.');
        }
        rethrow;
        }
      }
      Future<dynamic> getUri(Uri uri) async {
        try {
          final response = await _client.get(uri,headers: _headers,
        ).timeout(const Duration(seconds: 20));
        final dynamic responseData = response.body.isNotEmpty ? jsonDecode(response.body) : {};
        
        if (response.statusCode >= 200 && response.statusCode < 300) {
          return responseData;
        }
        String message = 'Ocurrió un error en el servidor';
        if (responseData is Map) {
          message = responseData['message']?.toString() ?? responseData['error']?.toString() ??
          message;
        }
      throw Exception(message);
      } catch (e) {
        if (e is FormatException) {
          throw Exception('El servidor devolvió una respuesta no válida.');
        }
        rethrow;
      }
    }

  void dispose() {
    _client.close();
  }
}