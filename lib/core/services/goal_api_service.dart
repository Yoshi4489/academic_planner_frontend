import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class GoalApiService {
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  final String? Function() getAccessToken;
  late final Dio _dio;

  GoalApiService({required this.getAccessToken}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: "https://academic-planner-backend-vfbf.onrender.com",
        headers: {"Content-Type": "application/json"},
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
      ),
    );
  }

  InterceptorsWrapper _goalInterceptor() {
    return InterceptorsWrapper(
      onRequest: (option, handler) {
        final token = getAccessToken();
        if (token != null) {
          option.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(option);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          await _storage.deleteAll();
        }
        handler.next(error);
      },
    );
  }

  Future<Map<String, dynamic>> findGoalsByUserId() async {
    try {
      final response = await _dio.get("/getGoalByUserId");
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? "Something went wrong");
    }
  }
}
