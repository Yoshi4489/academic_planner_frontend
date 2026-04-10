import 'package:academic_planner_fe/core/services/api_service.dart';
import 'package:academic_planner_fe/features/auth/data/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

class AuthState {
  final bool isLoading;
  final UserModel? user;
  final String? error;
  final String? accessToken;

  AuthState({this.isLoading = false, this.user, this.error, this.accessToken});

  AuthState copyWith({bool? isLoading, UserModel? user, String? error, String? accessToken}) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      error: error ?? this.error,
      accessToken: accessToken ?? this.accessToken,
    );
  }
}

class AuthController extends StateNotifier<AuthState> {
  final ApiService _apiService;
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  AuthController(this._apiService) : super(AuthState());

  Future<void> initAuth() async{
    try {
      final token = await _storage.read(key: "refresh_token");

      if (token == null) {
        return;
      }
      final response = await _apiService.refreshToken(token: token);
      state = state.copyWith(
        error: null,
        isLoading: false,
        user: UserModel.fromJson(response['user']),
        accessToken: response['access_token']
      );
    } on Exception catch(e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst("Exception", '')
      );
    }
  }

  Future<void> signUp(String name, String email, String password) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final response = await _apiService.signUp(name: name, email: email, password: password);
      state = state.copyWith(
        isLoading: false,
        user: UserModel.fromJson(response['user']),
        accessToken: response['access_token'],
      );
      
      await _storage.write(key: "refresh_token", value: response['refresh_token']);
    } on Exception catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst("Exception", '')
      );
    }
  }

  Future<void> signIn(String email, String password) async{
    try {
      state = state.copyWith(isLoading: true, error: null);
      final response = await _apiService.signIn(email: email, password: password);
      state = state.copyWith(
        isLoading: false,
        user: UserModel.fromJson(response['user']),
        accessToken: response['access_token'],
      );

      await _storage.write(key: "refresh_token", value: response['refresh_token']);
    } on Exception catch(e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst("Exception", '')
      );
    }
  }

  Future<void> logOut() async {
    await _storage.delete(key: "refresh_token");
    state = AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(ref.read(apiServiceProvider));
});
