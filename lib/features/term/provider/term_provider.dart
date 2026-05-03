import 'package:academic_planner_fe/core/providers/api_providers.dart';
import 'package:academic_planner_fe/core/services/term_api_service.dart';
import 'package:academic_planner_fe/core/services/hive_service.dart';
import 'package:academic_planner_fe/core/services/guest_mode_exceptions.dart';
import 'package:academic_planner_fe/features/auth/providers/auth_provider.dart';
import 'package:academic_planner_fe/features/term/data/term_model.dart';
import 'package:academic_planner_fe/features/term/data/gpa_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  final TermApiService _apiService;
  final HiveService _hiveService;
  final Ref _ref;

  TermController(this._apiService, this._hiveService, this._ref)
    : super(TermState());

  bool get _isLoggedIn => _ref.read(authProvider).user != null;

  Future<void> addTerm({
    required String term,
    required int year,
    required int termNo,
    required bool isComplete,
  }) async {
    if (state.isLoading) return;
    try {
      state = state.copyWith(isLoading: true, error: "");

      TermModel newTerm;

      if (_isLoggedIn) {
        // User is logged in - use API
        final response = await _apiService.createTerm(
          term: term,
          year: year,
          termNo: termNo,
          isComplete: isComplete,
        );
        newTerm = TermModel.fromJson(response['semester']);
      } else {
        // Guest mode - use Hive
        final id = 'term_${DateTime.now().millisecondsSinceEpoch}';
        final initialGpa = GpaModel(
          userId: 'guest',
          semesterId: id,
          gpa: 0.0,
          cumGpa: 0.0,
          totalCredit: 0,
          totalGradePoints: 0.0,
          calculatedAt: DateTime.now().toIso8601String(),
        );
        newTerm = TermModel(
          id: id,
          term: term,
          year: year,
          termNo: termNo,
          isComplete: isComplete,
          userId: 'guest',
          createdAt: DateTime.now().toIso8601String(),
          courses: [],
          gpas: [initialGpa],
        );
        await _hiveService.saveTerm(newTerm);

        // Auto-create initial GPA record for the new semester
        await _hiveService.saveGpa(initialGpa);
      }

      state = state.copyWith(
        isLoading: false,
        error: "",
        terms: [...state.terms, newTerm],
      );
    } on SemesterLimitException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } on Exception catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> removeTerm(String termId) async {
    final terms = state.terms.where((t) => t.id != termId).toList();

    if (!_isLoggedIn) {
      // Guest mode - delete from Hive
      // Delete all goals associated with this semester
      final goals = _hiveService.getAllGoals();
      for (var goal in goals) {
        if (goal.targetSemesterId == termId) {
          await _hiveService.deleteGoal(goal.id);
        }
      }

      // Delete all courses associated with this semester
      final courses = _hiveService.getCoursesBySemester(termId);
      for (var course in courses) {
        await _hiveService.deleteCourse(course.id);
      }

      // Delete GPA records for this semester
      final gpas = _hiveService.getAllGpas();
      for (var gpa in gpas) {
        if (gpa.semesterId == termId) {
          await _hiveService.deleteGpa(gpa.semesterId);
        }
      }

      // Finally delete the term itself
      await _hiveService.deleteTerm(termId);

      // Recalculate cumulative GPA for remaining semesters
      await _hiveService.recalculateAllCumulativeGpas('guest');
    }

    state = state.copyWith(terms: terms);
  }

  Future<void> getTemrsByUserId() async {
    if (state.isLoading) return;
    try {
      state = state.copyWith(isLoading: true, error: "");

      List<TermModel> terms;

      if (_isLoggedIn) {
        // User is logged in - fetch from API
        final response = await _apiService.findTermsByUserId();
        terms = (response['semesters'] as List)
            .map((e) => TermModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        // Guest mode - fetch from Hive
        terms = _hiveService.getAllTerms();
      }

      state = state.copyWith(isLoading: false, error: "", terms: terms);
    } on Exception catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst("Exception: ", ""),
      );
    }
  }

  void reset() => state = TermState();
}

final termProvider = StateNotifierProvider<TermController, TermState>((ref) {
  return TermController(
    ref.read(termApiServiceProvider),
    ref.read(hiveServiceProvider),
    ref,
  );
});
