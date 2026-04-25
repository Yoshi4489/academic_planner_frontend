import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CourseApiService {
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  final String? Function() getAccessToken;
  late final Dio _dio;

  CourseApiService({required this.getAccessToken}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: "https://academic-planner-backend-vfbf.onrender.com/api/v1",
        headers: {"Content-Type": 'application/json'},
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
      ),
    );

    _dio.interceptors.add(_authInterceptor());
  }

  InterceptorsWrapper _authInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = getAccessToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          await _storage.deleteAll();
        }
        handler.next(error);
      },
    );
  }

  Future<Map<String, dynamic>> createCourse({
    required String name,
    required String grade,
    required int credit,
    required String type,
    required String semesterId,
    required String category,
  }) async {
    try {
      final response = await _dio.post(
        "/courses/createCourse",
        data: {
          "name": name,
          "grade": grade,
          "credit": credit,
          "type": type,
          "semester_id": semesterId,
          "category": category,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? "Something went wrong");
    }
  }

  Future<Map<String, dynamic>> updateCourse({
    required String courseId,
    String? name,
    String? grade,
    int? credit,
    String? type,
    String? category,
  }) async {
    try {
      final data = {
        if (name != null) "name": name,
        if (grade != null) "grade": grade,
        if (credit != null) "credit": credit,
        if (type != null) "type": type,
        if (category != null) "category": category,
      };
      final response = await _dio.patch(
        "/courses/editCourse/$courseId",
        data: data,
      );

      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? "Something went wrong");
    }
  }
}
