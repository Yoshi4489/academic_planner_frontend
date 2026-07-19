import 'package:academic_planner_fe/core/providers/api_providers.dart';
import 'package:academic_planner_fe/core/services/term_api_service.dart';
import 'package:academic_planner_fe/core/services/hive_service.dart';
import 'package:academic_planner_fe/features/auth/providers/auth_provider.dart';
import 'package:academic_planner_fe/features/term/data/term_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  final HiveService _hiveService;
  final Ref _ref;

  TermDetailProvider(this._apiService, this._hiveService, this._ref) : super(TermDetailsState());

  bool get _isLoggedIn => _ref.read(authProvider).user != null;

  Future<void> getTermById(String termId) async {
    try {
      if (state.isLoading) return;
      state = state.copyWith(isLoading: true, error: "");

      TermModel? term;

      if (_isLoggedIn) {
        // User is logged in - fetch from API
        final response = await _apiService.findTermById(termId);
        final termMap = response['semester'];
        term = TermModel.fromJson(termMap);
      } else {
        // Guest mode - fetch from Hive
        term = _hiveService.getTerm(termId);
      }

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

      TermModel? term;

      if (_isLoggedIn) {
        // User is logged in - use API
        final response = await _apiService.updateTerm(
          termId: termId,
          name: name,
          year: year,
          termNo: termNo,
          isComplete: isComplete,
        );
        final termMap = response['semester'];
        term = TermModel.fromJson(termMap);
      } else {
        // Guest mode - update in Hive
        final existingTerm = _hiveService.getTerm(termId);
        if (existingTerm != null) {
          term = existingTerm.copyWith(
            term: name ?? existingTerm.term,
            year: year ?? existingTerm.year,
            termNo: termNo ?? existingTerm.termNo,
            isComplete: isComplete ?? existingTerm.isComplete,
          );
          await _hiveService.updateTerm(term);
        }
      }

      state = state.copyWith(isLoading: false, term: term, error: "");
    } on Exception catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst("Exception: ", ""),
      );
    }
  }

  Future<void> removeTerm({required String termId}) async {
    if (state.isLoading) return;
    try {
      state = state.copyWith(isLoading: true, error: "");

      if (_isLoggedIn) {
        // User is logged in - delete via API
        await _apiService.deleteTerm(termId: termId);
      } else {
        // Guest mode - delete from Hive
        await _hiveService.deleteTerm(termId);
      }

      state = state.copyWith(isLoading: false);
    } on Exception catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst("Exception: ", ""),
      );
    }
  }

  void reset() => state = TermDetailsState();
}

final termDetailProvider =
    StateNotifierProvider<TermDetailProvider, TermDetailsState>((ref) {
      return TermDetailProvider(
        ref.read(termApiServiceProvider),
        ref.read(hiveServiceProvider),
        ref,
      );
    });
