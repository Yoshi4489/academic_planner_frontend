import 'package:academic_planner_fe/core/providers/api_providers.dart';
import 'package:academic_planner_fe/core/services/goal_api_service.dart';
import 'package:academic_planner_fe/features/goal/data/goal_model.dart';
import 'package:flutter_riverpod/legacy.dart';

class GoalState {
  bool isLoading;
  String? error;
  List<GoalModel> goals;

  GoalState({this.isLoading = false, this.goals = const [], this.error});

  GoalState copyWith({bool? isLoading, String? error, List<GoalModel>? goals}) {
    return GoalState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      goals: goals ?? this.goals,
    );
  }
}

class GoalController extends StateNotifier<GoalState> {
  final GoalApiService _apiService;

  GoalController(this._apiService) : super(GoalState());

  Future<void> getGoalsByUserId() async {
    if (state.isLoading) return;
    try {
      state = state.copyWith(isLoading: false, error: "");
      final response = await _apiService.findGoalsByUserId();
      print(response['goals']);
      final goals = (response['goals'] as List)
          .map((g) => GoalModel.fromJson(g))
          .toList();
      state = state.copyWith(isLoading: false, error: "", goals: goals);
    } on Exception catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst("Exception: ", ""),
      );
    }
  }

  Future<void> createGoal({
    required String name,
    required double targetGpa,
    required String semesterId,
    required bool isAchieved,
  }) async {
    if (state.isLoading) return;
    try {
      state = state.copyWith(isLoading: true, error: "");
      final response = await _apiService.addGoal(
        name: name,
        targetGpa: targetGpa,
        semesterId: semesterId,
        isAchieved: isAchieved,
      );
      final goal = GoalModel.fromJson(response['goal']);
      state = state.copyWith(
        isLoading: false,
        error: "",
        goals: [...state.goals, goal],
      );
    } on Exception catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst("Exception: ", ""),
      );
    }
  }
}

final goalProvider = StateNotifierProvider<GoalController, GoalState>((ref) {
  return GoalController(ref.read(goalApiServiceProvider));
});
