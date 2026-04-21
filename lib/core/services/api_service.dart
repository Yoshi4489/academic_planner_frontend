import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final String? Function() getAccessToken;
  late final Dio _dio;
  late final Dio _refreshDio;

  ApiService({required this.getAccessToken}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: "http://192.168.1.33:8080/api/v1",
        headers: {'Content-Type': 'application/json'},
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
      ),
    );

    _refreshDio = Dio(
      BaseOptions(
        baseUrl: "http://192.168.1.33:8080/api/v1",
        headers: {'Content-Type': 'application/json'},
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
          try {
            final storedRefreshToken = await _storage.read(
              key: 'refresh_token',
            );
            if (storedRefreshToken == null) {
              await _onRefreshFailed();
              return;
            }

            final response = await _refreshDio.post(
              '/auth/refresh-token',
              options: Options(
                headers: {'Authorization': 'Bearer $storedRefreshToken'},
              ),
            );

            final newAccessToken = response.data['access_token'];
            final newRefreshToken = response.data['refresh_token'];

            await _storage.write(key: 'refresh_token', value: newRefreshToken);

            final opts = error.requestOptions;
            opts.headers['Authorization'] = 'Bearer $newAccessToken';
            final retried = await _dio.fetch(opts);
            return handler.resolve(retried);
          } catch (e) {
            await _onRefreshFailed();
          }
        }
        handler.next(error);
      },
    );
  }

  Future<void> _onRefreshFailed() async {
    await _storage.deleteAll();
  }

  Future<Map<String, dynamic>> signInAccount({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Something went wrong');
    }
  }

  Future<Map<String, dynamic>> createAccount({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/register',
        data: {'name': name, 'email': email, 'password': password},
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Something went wrong');
    }
  }

  Future<Map<String, dynamic>> refreshToken({required String token}) async {
    try {
      final response = await _refreshDio.post(
        '/auth/refresh-token',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Something went wrong');
    }
  }

  Future<Map<String, dynamic>> createTerm({
    required String term,
    required int year,
    required int termNo,
    required bool isComplete,
    required String userId,
  }) async {
    try {
      final response = await _dio.post(
        '/semesters/addSemester',
        data: {
          'term': term,
          'year': year,
          'term_no': termNo,
          'is_complete': isComplete,
          'user_id': userId,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Something went wrong');
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
    } on DioException catch(e) {
      throw Exception(e.response?.data['message'] ?? "Something went wrong");
    }
  }
}
