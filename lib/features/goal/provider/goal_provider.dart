import 'package:academic_planner_fe/core/providers/api_providers.dart';
import 'package:academic_planner_fe/core/services/goal_api_service.dart';
import 'package:academic_planner_fe/core/services/hive_service.dart';
import 'package:academic_planner_fe/core/services/guest_mode_exceptions.dart';
import 'package:academic_planner_fe/features/auth/providers/auth_provider.dart';
import 'package:academic_planner_fe/features/goal/data/goal_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  final HiveService _hiveService;
  final Ref _ref;

  GoalController(this._apiService, this._hiveService, this._ref) : super(GoalState());

  bool get _isLoggedIn => _ref.read(authProvider).user != null;

  Future<void> getGoalsByUserId() async {
    if (state.isLoading) return;
    try {
      state = state.copyWith(isLoading: true, error: "");

      List<GoalModel> goals;

      if (_isLoggedIn) {
        // User is logged in - fetch from API
        final response = await _apiService.findGoalsByUserId();
        print(response['goals']);
        goals = (response['goals'] as List)
            .map((g) => GoalModel.fromJson(g))
            .toList();
      } else {
        // Guest mode - fetch from Hive
        goals = _hiveService.getAllGoals();
      }

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

      GoalModel goal;

      if (_isLoggedIn) {
        // User is logged in - use API
        final response = await _apiService.addGoal(
          name: name,
          targetGpa: targetGpa,
          semesterId: semesterId,
          isAchieved: isAchieved,
        );
        goal = GoalModel.fromJson(response['goal']);
      } else {
        // Guest mode - use Hive
        final id = 'goal_${DateTime.now().millisecondsSinceEpoch}';
        goal = GoalModel(
          id: id,
          name: name,
          targetGpa: targetGpa,
          isAchieved: isAchieved,
          targetSemesterId: semesterId,
          userId: 'guest',
        );
        await _hiveService.saveGoal(goal);
      }

      state = state.copyWith(
        isLoading: false,
        error: "",
        goals: [...state.goals, goal],
      );
    } on GoalLimitException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
      );
    } on Exception catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst("Exception: ", ""),
      );
    }
  }

  void reset() => state = GoalState();
}

final goalProvider = StateNotifierProvider<GoalController, GoalState>((ref) {
  return GoalController(
    ref.read(goalApiServiceProvider),
    ref.read(hiveServiceProvider),
    ref,
  );
});
