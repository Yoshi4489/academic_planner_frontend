import 'package:academic_planner_fe/core/services/api_service.dart';
import 'package:academic_planner_fe/features/auth/data/user_model.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const _sentinel = Object();

class AuthState {
  final bool isLoading;
  final UserModel? user;
  final String? error;
  final String? accessToken;

  AuthState({this.isLoading = false, this.user, this.error, this.accessToken});

  AuthState copyWith({
    bool? isLoading,
    UserModel? user,
    Object? error = _sentinel,
    Object? accessToken = _sentinel,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      error: error == _sentinel ? this.error : error as String?,
      accessToken: accessToken == _sentinel
          ? this.accessToken
          : accessToken as String?,
    );
  }
}

class AuthController extends StateNotifier<AuthState> {
  late final ApiService _apiService;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  AuthController() : super(AuthState()) {
    _apiService = ApiService(getAccessToken: () => state.accessToken);
  }

  Future<void> initAuth() async {
    try {
      final token = await _storage.read(key: 'refresh_token');

      if (token == null) {
        return;
      }

      final response = await _apiService.refreshToken(token: token);

      state = state.copyWith(
        isLoading: false,
        error: null,
        user: UserModel.fromJson(response['user']),
        accessToken: response['access_token'],
      );

    } on Exception catch (e) {
      await _storage.deleteAll();
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }
  Future<void> signUp(String name, String email, String password) async {
    if (state.isLoading) return;
    try {
      state = state.copyWith(isLoading: true, error: "");
      final response = await _apiService.createAccount(
        name: name,
        email: email,
        password: password,
      );
      await _storage.write(
        key: 'refresh_token',
        value: response['refresh_token'],
      );
      state = state.copyWith(
        isLoading: false,
        error: "",
        user: UserModel.fromJson(response['user']),
        accessToken: response['access_token'],
      );
    } on Exception catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> signIn(String email, String password) async {
    if (state.isLoading) return;
    try {
      state = state.copyWith(isLoading: true, error: "");
      final response = await _apiService.signInAccount(
        email: email,
        password: password,
      );
      await _storage.write(
        key: 'refresh_token',
        value: response['refresh_token'],
      );
      state = state.copyWith(
        isLoading: false,
        error: "",
        user: UserModel.fromJson(response['user']),
        accessToken: response['access_token'],
      );
    } on Exception catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> logOut() async {
    await _storage.deleteAll();
    state = AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthController, AuthState>(
  (ref) => AuthController(),
);
