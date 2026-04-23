import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TermApiService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final String? Function() getAccessToken;
  late final Dio _dio;

  TermApiService({required this.getAccessToken}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: "https://academic-planner-backend-vfbf.onrender.com/api/v1",
        headers: {'Content-Type': 'application/json'},
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

  Future<Map<String, dynamic>> createTerm({
    required String term,
    required int year,
    required int termNo,
    required bool isComplete,
  }) async {
    try {
      final response = await _dio.post(
        '/semesters/addSemester',
        data: {
          'term': term,
          'year': year,
          'term_no': termNo,
          'is_complete': isComplete,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Something went wrong');
    }
  }

  Future<Map<String, dynamic>> updateTerm({
    required String termId,
    String? name,
    int? year,
    int? termNo,
    bool? isComplete,
  }) async {
    try {
      final response = await _dio.patch(
        '/semesters/updateSemester/$termId',
        data: {
          if (name != null) 'term': name,
          if (year != null) 'year': year,
          if (termNo != null) 'term_no': termNo,
          if (isComplete != null) 'is_complete': isComplete,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Something went wrong');
    }
  }

  Future<Map<String, dynamic>> deleteTerm({required String termId}) async {
    try {
      final response = await _dio.delete("/semesters/deleteSemester/$termId");
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? "Something went wrong");
    }
  }

  Future<Map<String, dynamic>> findTermsByUserId() async {
    try {
      final response = await _dio.get('/semesters/getSemesters');
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Something went wrong');
    }
  }

  Future<Map<String, dynamic>> findTermById(String termId) async {
    try {
      final response = await _dio.get('/semesters/getSemesterById/$termId');
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Something went wrong');
    }
  }
}
