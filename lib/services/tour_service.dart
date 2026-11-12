import '../models/tour_service.dart';
import 'api_service.dart';

class TourPage {
  final List<TourService> content;
  final int page;
  final int size;
  final int totalElements;

  TourPage({
    required this.content,
    required this.page,
    required this.size,
    required this.totalElements,
  });

  factory TourPage.fromJson(Map<String, dynamic> json) {
    return TourPage(
      content: (json['content'] as List<dynamic>? ?? [])
          .map((item) => TourService.fromJson(
                Map<String, dynamic>.from(item),
              ))
          .toList(),
      page: json['page'] ?? 0,
      size: json['size'] ?? 10,
      totalElements: json['totalElements'] ?? 0,
    );
  }
}

class TourServiceApi {
  final ApiService _apiService = ApiService();

  Future<TourPage> getTours({
    int page = 0,
    int size = 10,
    String? category,
  }) async {
    final queryParameters = <String, String>{
      'page': page.toString(),
      'size': size.toString(),
    };

    if (category != null) {
      queryParameters['category'] = category;
    }

    final uri = Uri.parse('${
      ApiService.baseUrl
    }/tours').replace(queryParameters: queryParameters);

    final response = await _apiService.getUri(uri);

    return TourPage.fromJson(
      Map<String, dynamic>.from(response),
    );
  }

  Future<TourService> getTourById(int id) async {
    final response = await _apiService.getUri(Uri.parse('${ApiService.baseUrl}/tours/$id'),
    );
    return TourService.fromJson(
      Map<String, dynamic>.from(response),
      );
      }

  void dispose() {
    _apiService.dispose();
  }
}
