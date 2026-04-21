import 'package:academic_planner_fe/core/services/api_service.dart';
import 'package:academic_planner_fe/features/auth/providers/auth_provider.dart';
import 'package:academic_planner_fe/features/term/data/term_model.dart';
import 'package:flutter_riverpod/legacy.dart';

const _termSentinel = Object();

class TermState {
  final bool isLoading;
  final String? error;
  final List<TermModel> terms;

  TermState({this.isLoading = false, this.error, this.terms = const []});

  TermState copyWith({
    bool? isLoading,
    Object? error = _termSentinel,
    List<TermModel>? terms,
  }) {
    return TermState(
      isLoading: isLoading ?? this.isLoading,
      error: error == _termSentinel ? this.error : error as String?,
      terms: terms ?? this.terms,
    );
  }
}

class TermController extends StateNotifier<TermState> {
  final ApiService _apiService;

  TermController(this._apiService) : super(TermState());

  Future<void> addTerm({
    required String term,
    required int year,
    required int termNo,
    required bool isComplete,
    required String userId,
  }) async {
    if (state.isLoading) return;
    try {
      state = state.copyWith(isLoading: true, error: "");

      final response = await _apiService.createTerm(
        term: term,
        year: year,
        termNo: termNo,
        isComplete: isComplete,
        userId: userId,
      );

      final newTerm = TermModel.fromJson(response['semester']);
      state = state.copyWith(
        isLoading: false,
        error: "",
        terms: [...state.terms, newTerm],
      );
    } on Exception catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> getTemrsByUserId() async {
      if (state.isLoading) return;
      try {
        state = state.copyWith(isLoading: true, error: "");
        final response = await _apiService.findTermsByUserId();

        final terms = (response['semesters'] as List)
            .map((e) => TermModel.fromJson(e as Map<String, dynamic>))
            .toList();

        state = state.copyWith(isLoading: false, error: "", terms: terms);
      } on Exception catch (e) {
        state = state.copyWith(
          isLoading: false,
          error: e.toString().replaceFirst("Exception: ", ""),
        );
      }
  }
}

final termProvider = StateNotifierProvider<TermController, TermState>((ref) {
  final apiService = ApiService(
    getAccessToken: () => ref.read(authProvider).accessToken,
  );

  return TermController(apiService);
});
