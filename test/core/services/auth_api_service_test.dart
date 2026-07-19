import 'dart:convert';
import 'dart:typed_data';

import 'package:academic_planner_fe/core/services/auth_api_service.dart';
import 'package:academic_planner_fe/core/services/token_storage.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

class MemoryTokenStorage implements TokenStorage {
  String? refreshToken;
  int clearCount = 0;

  MemoryTokenStorage(this.refreshToken);

  @override
  Future<void> clear() async {
    clearCount++;
    refreshToken = null;
  }

  @override
  Future<String?> readRefreshToken() async => refreshToken;

  @override
  Future<void> writeRefreshToken(String token) async {
    refreshToken = token;
  }
}

class CallbackAdapter implements HttpClientAdapter {
  final Future<ResponseBody> Function(RequestOptions options) callback;

  CallbackAdapter(this.callback);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    return callback(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody jsonResponse(int status, Map<String, dynamic> body) {
  return ResponseBody.fromString(
    jsonEncode(body),
    status,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}

void main() {
  test(
    'secure token storage reads, replaces, and clears refresh token',
    () async {
      FlutterSecureStorage.setMockInitialValues({
        'refresh_token': 'initial-token',
      });
      const storage = SecureTokenStorage();

      expect(await storage.readRefreshToken(), 'initial-token');
      await storage.writeRefreshToken('replacement-token');
      expect(await storage.readRefreshToken(), 'replacement-token');
      await storage.clear();
      expect(await storage.readRefreshToken(), isNull);
    },
  );

  test('refreshes once and retries concurrent unauthorized requests', () async {
    final storage = MemoryTokenStorage('refresh-token');
    var refreshCalls = 0;
    var accessToken = 'expired-access';

    final protectedDio = Dio(BaseOptions(baseUrl: 'https://test.invalid'));
    protectedDio.httpClientAdapter = CallbackAdapter((options) async {
      if (options.headers['Authorization'] == 'Bearer new-access') {
        return jsonResponse(200, {'ok': true});
      }
      return jsonResponse(401, {'message': 'Invalid token'});
    });

    final refreshDio = Dio(BaseOptions(baseUrl: 'https://test.invalid'));
    refreshDio.httpClientAdapter = CallbackAdapter((options) async {
      refreshCalls++;
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(options.path, '/auth/refresh-token');
      expect(options.headers['Authorization'], 'Bearer refresh-token');
      return jsonResponse(200, {
        'access_token': 'new-access',
        'user': {'id': 'user-1'},
      });
    });

    final service = AuthApiService(
      getAccessToken: () => accessToken,
      storage: storage,
      dio: protectedDio,
      refreshDio: refreshDio,
      onAccessTokenChanged: (token) => accessToken = token,
    );

    final responses = await Future.wait([
      service.authenticatedDio.get<Map<String, dynamic>>('/protected/one'),
      service.authenticatedDio.get<Map<String, dynamic>>('/protected/two'),
    ]);

    expect(responses.every((response) => response.data?['ok'] == true), isTrue);
    expect(refreshCalls, 1);
    expect(accessToken, 'new-access');
    expect(storage.refreshToken, 'refresh-token');
  });

  test(
    'missing refresh token rejects promptly and clears auth state',
    () async {
      final storage = MemoryTokenStorage(null);
      var authFailed = false;

      final protectedDio = Dio(BaseOptions(baseUrl: 'https://test.invalid'));
      protectedDio.httpClientAdapter = CallbackAdapter(
        (_) async => jsonResponse(401, {'message': 'Invalid token'}),
      );

      final service = AuthApiService(
        getAccessToken: () => 'expired-access',
        storage: storage,
        dio: protectedDio,
        refreshDio: Dio(BaseOptions(baseUrl: 'https://test.invalid')),
        onAuthenticationFailed: () => authFailed = true,
      );

      await expectLater(
        service.authenticatedDio
            .get<void>('/protected')
            .timeout(const Duration(seconds: 1)),
        throwsA(isA<DioException>()),
      );
      expect(authFailed, isTrue);
      expect(storage.clearCount, 1);
    },
  );

  test('login 401 does not attempt a refresh', () async {
    final storage = MemoryTokenStorage('refresh-token');
    var calls = 0;
    final publicDio = Dio(BaseOptions(baseUrl: 'https://test.invalid'));
    publicDio.httpClientAdapter = CallbackAdapter((_) async {
      calls++;
      return jsonResponse(401, {'message': 'Invalid credentials'});
    });

    final service = AuthApiService(
      getAccessToken: () => null,
      storage: storage,
      dio: Dio(BaseOptions(baseUrl: 'https://test.invalid')),
      refreshDio: publicDio,
    );

    await expectLater(
      service.signIn(email: 'user@example.com', password: 'wrong-password'),
      throwsA(
        predicate((error) => error.toString().contains('Invalid credentials')),
      ),
    );
    expect(calls, 1);
    expect(storage.refreshToken, 'refresh-token');
  });
}
