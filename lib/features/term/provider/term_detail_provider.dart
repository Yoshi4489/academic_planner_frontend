import 'package:academic_planner_fe/core/providers/api_providers.dart';
import 'package:academic_planner_fe/core/services/term_api_service.dart';
import 'package:academic_planner_fe/features/term/data/term_model.dart';
import 'package:flutter_riverpod/legacy.dart';

class TermDetailsState {
  bool isLoading;
  String? error;
  TermModel? term;

  TermDetailsState({this.isLoading = false, this.error, this.term});

  TermDetailsState copyWith({bool? isLoading, String? error, TermModel? term}) {
    return TermDetailsState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      term: term ?? this.term,
    );
  }
}

class TermDetailProvider extends StateNotifier<TermDetailsState> {
  final TermApiService _apiService;

  TermDetailProvider(this._apiService) : super(TermDetailsState());

  Future<void> getTermById(String termId) async {
    try {
      if (state.isLoading) return;
      state = state.copyWith(isLoading: true, error: "");
      final response = await _apiService.findTermById(termId);
      final termMap = response['semester'];
      final term = TermModel.fromJson(termMap);
      state = state.copyWith(isLoading: false, error: "", term: term);
    } on Exception catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst("Exception: ", ""),
      );
    }
  }

  Future<void> editTerm({
    required String termId,
    String? name,
    int? year,
    int? termNo,
    bool? isComplete,
  }) async {
    if (state.isLoading) return;
    try {
      state = state.copyWith(isLoading: true, error: "");
      final response = await _apiService.updateTerm(
        termId: termId,
        name: name,
        year: year,
        termNo: termNo,
        isComplete: isComplete,
      );
      final termMap = response['semester'];
      final term = TermModel.fromJson(termMap);
      state = state.copyWith(isLoading: false, term: term, error: "");
    } on Exception catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst("Exception: ", ""),
      );
    }
  }
}

final termDetailProvider =
    StateNotifierProvider<TermDetailProvider, TermDetailsState>((ref) {
      return TermDetailProvider(ref.read(termApiServiceProvider));
    });
