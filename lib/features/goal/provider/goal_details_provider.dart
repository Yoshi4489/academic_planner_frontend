import 'package:academic_planner_fe/core/providers/api_providers.dart';
import 'package:academic_planner_fe/core/services/goal_api_service.dart';
import 'package:academic_planner_fe/features/goal/data/goal_model.dart';
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

  GoalDetailsProvider(this._apiService) : super(GoalDetailsState());

  Future<void> getGoalById({required String goalId}) async {
    if (state.isLoading) return;
    try {
      state = state.copyWith(isLoading: true, error: "");
      final response = await _apiService.findGoalById(goalId: goalId);
      final goal = GoalModel.fromJson(response['goal']);
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
      final response = await _apiService.updateGoal(
        goalId: goalId,
        name: name,
        isAchieved: isAchieved,
        targetGpa: targetGpa,
        targetSemesterId: targetSemesterId,
      );
      final goal = GoalModel.fromJson(response['goal']);
      state = state.copyWith(isLoading: false, error: "", goal: goal);
    } on Exception catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst("Exception: ", ""),
      );
    }
  }

  Future<void> removeGoal({required String goalId}) async{
    if (state.isLoading) return;
    try {
      state = state.copyWith(isLoading: true, error: "");
      final response = await _apiService.deleteGoal(goalId: goalId);
      state = state.copyWith(isLoading: false, error: "", goal: null);
    } on Exception catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst("Exception: ", ""),
      );
    }
  }
}

final goalDetailsProvider =
    StateNotifierProvider<GoalDetailsProvider, GoalDetailsState>((ref) {
      return GoalDetailsProvider(ref.read(goalApiServiceProvider));
    });
