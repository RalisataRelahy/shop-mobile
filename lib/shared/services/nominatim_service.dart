import 'package:dio/dio.dart';

class NominatimService {
  final Dio _dio = Dio();

  Future<List<Map<String, dynamic>>> search(String query) async {
    if (query.length < 3) return [];

    final response = await _dio.get(
      "https://nominatim.openstreetmap.org/search",
      queryParameters: {
        "q": query,
        "format": "jsonv2",
        "addressdetails": 1,
        "limit": 5,
      },
      options: Options(
        headers: {
          "User-Agent": "FastGood/1.0",
        },
      ),
    );

    return List<Map<String, dynamic>>.from(response.data);
  }
}