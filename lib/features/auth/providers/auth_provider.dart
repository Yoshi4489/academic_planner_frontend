import 'package:academic_planner_fe/core/services/auth_api_service.dart';
import 'package:academic_planner_fe/features/auth/data/user_model.dart';
import 'package:academic_planner_fe/features/course/provider/course_details_provider.dart';
import 'package:academic_planner_fe/features/course/provider/course_provider.dart';
import 'package:academic_planner_fe/features/goal/provider/goal_details_provider.dart';
import 'package:academic_planner_fe/features/goal/provider/goal_provider.dart';
import 'package:academic_planner_fe/features/term/provider/term_detail_provider.dart';
import 'package:academic_planner_fe/features/term/provider/term_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:academic_planner_fe/core/services/token_storage.dart';

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
  final Ref _ref;
  late final AuthApiService _apiService;
  final TokenStorage _storage;

  AuthController(this._ref, {TokenStorage storage = const SecureTokenStorage()})
    : _storage = storage,
      super(AuthState()) {
    _apiService = AuthApiService(
      getAccessToken: () => state.accessToken,
      storage: _storage,
      onAccessTokenChanged: (token) {
        state = state.copyWith(accessToken: token, error: null);
      },
      onAuthenticationFailed: () {
        _resetSessionState();
      },
    );
  }

  AuthApiService get apiService => _apiService;

  Future<void> initAuth() async {
    try {
      final token = await _storage.readRefreshToken();

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
      await _storage.clear();
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
      final response = await _apiService.signUp(
        name: name,
        email: email,
        password: password,
      );
      await _storage.writeRefreshToken(response['refresh_token'] as String);
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
      final response = await _apiService.signIn(
        email: email,
        password: password,
      );
      await _storage.writeRefreshToken(response['refresh_token'] as String);
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
    await _storage.clear();

    _resetSessionState();
  }

  void _resetSessionState() {
    _ref.read(termProvider.notifier).reset();
    _ref.read(goalProvider.notifier).reset();
    _ref.read(courseProvider.notifier).reset();
    _ref.read(termDetailProvider.notifier).reset();
    _ref.read(courseDetailsProvider.notifier).reset();
    _ref.read(goalDetailsProvider.notifier).reset();

    state = AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthController, AuthState>(
  (ref) => AuthController(ref),
);
