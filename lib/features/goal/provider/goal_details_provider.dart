import 'package:academic_planner_fe/core/providers/api_providers.dart';
import 'package:academic_planner_fe/core/services/goal_api_service.dart';
import 'package:academic_planner_fe/core/services/hive_service.dart';
import 'package:academic_planner_fe/features/auth/providers/auth_provider.dart';
import 'package:academic_planner_fe/features/goal/data/goal_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

class GoalDetailsState {
  final bool isLoading;
  final String? error;
  final GoalModel? goal;

  GoalDetailsState({this.isLoading = false, this.error, this.goal});

  GoalDetailsState copyWith({bool? isLoading, String? error, GoalModel? goal}) {
    return GoalDetailsState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      goal: goal ?? this.goal,
    );
  }
}

class GoalDetailsProvider extends StateNotifier<GoalDetailsState> {
  final GoalApiService _apiService;
  final HiveService _hiveService;
  final Ref _ref;

  GoalDetailsProvider(this._apiService, this._hiveService, this._ref) : super(GoalDetailsState());

  bool get _isLoggedIn => _ref.read(authProvider).user != null;

  Future<void> getGoalById({required String goalId}) async {
    if (state.isLoading) return;
    try {
      state = state.copyWith(isLoading: true, error: "");

      GoalModel? goal;

      if (_isLoggedIn) {
        // User is logged in - fetch from API
        final response = await _apiService.findGoalById(goalId: goalId);
        goal = GoalModel.fromJson(response['goal']);
      } else {
        // Guest mode - fetch from Hive
        goal = _hiveService.getGoal(goalId);
      }

      state = state.copyWith(isLoading: false, error: "", goal: goal);
    } on Exception catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst("Exception: ", ""),
      );
    }
  }

  Future<void> editGoal({
    required String goalId,
    String? name,
    bool? isAchieved,
    String? targetSemesterId,
    double? targetGpa,
  }) async {
    if (state.isLoading) return;
    try {
      state = state.copyWith(isLoading: true, error: "");

      GoalModel? goal;

      if (_isLoggedIn) {
        // User is logged in - use API
        final response = await _apiService.updateGoal(
          goalId: goalId,
          name: name,
          isAchieved: isAchieved,
          targetGpa: targetGpa,
          targetSemesterId: targetSemesterId,
        );
        goal = GoalModel.fromJson(response['goal']);
      } else {
        // Guest mode - update in Hive
        final existingGoal = _hiveService.getGoal(goalId);
        if (existingGoal != null) {
          goal = existingGoal.copyWith(
            name: name ?? existingGoal.name,
            isAchieved: isAchieved ?? existingGoal.isAchieved,
            targetGpa: targetGpa ?? existingGoal.targetGpa,
            targetSemesterId: targetSemesterId ?? existingGoal.targetSemesterId,
          );
          await _hiveService.updateGoal(goal);
        }
      }

      state = state.copyWith(isLoading: false, error: "", goal: goal);
    } on Exception catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst("Exception: ", ""),
      );
    }
  }

  Future<void> removeGoal({required String goalId}) async {
    if (state.isLoading) return;
    try {
      state = state.copyWith(isLoading: true, error: "");

      if (_isLoggedIn) {
        // User is logged in - delete via API
        await _apiService.deleteGoal(goalId: goalId);
      } else {
        // Guest mode - delete from Hive
        await _hiveService.deleteGoal(goalId);
      }

      state = state.copyWith(isLoading: false, error: "", goal: null);
    } on Exception catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst("Exception: ", ""),
      );
    }
  }

  void reset() => state = GoalDetailsState();
}

final goalDetailsProvider =
    StateNotifierProvider<GoalDetailsProvider, GoalDetailsState>((ref) {
      return GoalDetailsProvider(
        ref.read(goalApiServiceProvider),
        ref.read(hiveServiceProvider),
        ref,
      );
    });
