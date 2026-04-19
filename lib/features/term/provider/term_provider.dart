import 'package:academic_planner_fe/core/services/api_service.dart';
import 'package:academic_planner_fe/features/term/data/term_model.dart';
import 'package:flutter_riverpod/legacy.dart';

class TermState {
  bool isLoading;
  String? error;
  List<TermModel>? terms;

  TermState({this.isLoading = false, this.error, this.terms});

  TermState copyWith({bool? isLoading, String? error, List<TermModel>? terms}) {
    return TermState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      terms: terms ?? this.terms,
    );
  }
}

class TermController extends StateNotifier<TermState> {
  final ApiService _apiService;

  TermController(this._apiService) : super(TermState());

  Future<void> addSemester(
    String name,
    String term,
    int term_no,
    bool is_complete,
    String user_id,
  ) async {}
}
