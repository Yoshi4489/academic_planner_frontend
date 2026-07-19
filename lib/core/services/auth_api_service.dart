import 'package:academic_planner_fe/core/config/app_config.dart';
import 'package:academic_planner_fe/core/services/token_storage.dart';
import 'package:dio/dio.dart';

class AuthApiService {
  static const _retriedRequestKey = 'auth_retry';

  final TokenStorage _storage;
  final String? Function() getAccessToken;
  final void Function(String token)? onAccessTokenChanged;
  final void Function()? onAuthenticationFailed;
  late final Dio _dio;
  late final Dio _refreshDio;
  Future<String>? _refreshInProgress;

  AuthApiService({
    required this.getAccessToken,
    TokenStorage storage = const SecureTokenStorage(),
    String baseUrl = AppConfig.apiBaseUrl,
    Dio? dio,
    Dio? refreshDio,
    this.onAccessTokenChanged,
    this.onAuthenticationFailed,
  }) : _storage = storage {
    _dio =
        dio ??
        Dio(
          BaseOptions(
            baseUrl: baseUrl,
            headers: {'Content-Type': 'application/json'},
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 15),
          ),
        );
    _refreshDio =
        refreshDio ??
        Dio(
          BaseOptions(
            baseUrl: baseUrl,
            headers: {'Content-Type': 'application/json'},
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 15),
          ),
        );

    _dio.interceptors.add(_authInterceptor());
  }

  Dio get authenticatedDio => _dio;

  InterceptorsWrapper _authInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = getAccessToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        final isAuthEndpoint = error.requestOptions.path.startsWith('/auth/');
        final alreadyRetried =
            error.requestOptions.extra[_retriedRequestKey] == true;

        if (error.response?.statusCode == 401 &&
            !isAuthEndpoint &&
            !alreadyRetried) {
          try {
            final newAccessToken = await _refreshAccessToken();
            final request = error.requestOptions;
            request.extra[_retriedRequestKey] = true;
            request.headers['Authorization'] = 'Bearer $newAccessToken';
            final retried = await _dio.fetch(request);
            return handler.resolve(retried);
          } catch (_) {
            await _storage.clear();
            onAuthenticationFailed?.call();
          }
        }
        handler.next(error);
      },
    );
  }

  Future<String> _refreshAccessToken() {
    final activeRefresh = _refreshInProgress;
    if (activeRefresh != null) return activeRefresh;

    final refresh = _performRefresh();
    _refreshInProgress = refresh;
    return refresh.whenComplete(() {
      if (identical(_refreshInProgress, refresh)) {
        _refreshInProgress = null;
      }
    });
  }

  Future<String> _performRefresh() async {
    final storedRefreshToken = await _storage.readRefreshToken();
    if (storedRefreshToken == null || storedRefreshToken.isEmpty) {
      throw StateError('No refresh token is available');
    }

    final response = await _refreshDio.post(
      '/auth/refresh-token',
      options: Options(
        headers: {'Authorization': 'Bearer $storedRefreshToken'},
      ),
    );
    final accessToken = response.data['access_token'] as String?;
    if (accessToken == null || accessToken.isEmpty) {
      throw StateError('Refresh response did not include an access token');
    }

    // Render's backend returns a new access token but keeps the refresh token.
    onAccessTokenChanged?.call(accessToken);
    return accessToken;
  }

  Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _refreshDio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );
      return Map<String, dynamic>.from(response.data as Map);
    } on DioException catch (error) {
      throw Exception(_messageFrom(error));
    }
  }

  Future<Map<String, dynamic>> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _refreshDio.post(
        '/auth/register',
        data: {'name': name, 'email': email, 'password': password},
      );
      return Map<String, dynamic>.from(response.data as Map);
    } on DioException catch (error) {
      throw Exception(_messageFrom(error));
    }
  }

  Future<Map<String, dynamic>> refreshToken({required String token}) async {
    try {
      final response = await _refreshDio.post(
        '/auth/refresh-token',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return Map<String, dynamic>.from(response.data as Map);
    } on DioException catch (error) {
      throw Exception(_messageFrom(error));
    }
  }

  String _messageFrom(DioException error) {
    final data = error.response?.data;
    if (data is Map && data['message'] is String) {
      return data['message'] as String;
    }
    return 'Something went wrong';
  }
}
