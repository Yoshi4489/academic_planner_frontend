import 'package:dio/dio.dart';

class GpaApiService {
  final Dio _dio;

  GpaApiService(this._dio);

  Future<Map<String, dynamic>> findGpaByUserId() async {
    try {
      final response = await _dio.post("/gpa/getGPAsByUserId");
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? "Something went wrong");
    }
  }
}
