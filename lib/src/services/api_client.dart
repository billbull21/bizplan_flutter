import 'package:dio/dio.dart';

class ApiClient {
  final Dio _dio;
  ApiClient([String? baseUrl])
      : _dio = Dio(BaseOptions(baseUrl: baseUrl ?? 'http://localhost:8080'));

  Future<List<dynamic>> categories() async {
    final r = await _dio.get('/v1/categories');
    return r.data as List<dynamic>;
  }

  Future<List<dynamic>> templates(String? categorySlug) async {
    final r = await _dio.get('/v1/templates', queryParameters: {'category_slug': categorySlug});
    return r.data as List<dynamic>;
  }

  Future<Map<String, dynamic>> templateDetail(String id) async {
    final r = await _dio.get('/v1/templates/$id');
    return r.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> calcHpp(Map<String, dynamic> payload) async {
    final r = await _dio.post('/v1/calc/hpp', data: payload);
    return r.data as Map<String, dynamic>;
  }
}
