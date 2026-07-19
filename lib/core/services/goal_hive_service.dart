import 'package:hive_flutter/hive_flutter.dart';
import 'package:academic_planner_fe/features/goal/data/goal_model.dart';
import 'package:academic_planner_fe/core/services/guest_mode_exceptions.dart';

/// Service for managing Goal data in Hive local storage
class GoalHiveService {
  static const String boxName = 'guest_goals';
  static const int maxGuestGoals = 5;
  
  late Box<dynamic> _box;
  bool _isInitialized = false;

  /// Initialize the box reference
  void init() {
    if (_isInitialized) return;
    _box = Hive.box(boxName);
    _isInitialized = true;
  }

  /// Check if guest mode limit is reached
  bool isLimitReached() {
    return _box.length >= maxGuestGoals;
  }

  /// Check if can add more goals
  bool canAddMore() {
    return _box.length < maxGuestGoals;
  }

  /// Get remaining slots
  int getRemainingSlots() {
    return maxGuestGoals - _box.length;
  }

  /// Save a goal to local storage
  /// Throws [GoalLimitException] if guest mode limit is reached
  Future<void> saveGoal(GoalModel goal) async {
    if (isLimitReached()) {
      throw GoalLimitException(
        currentCount: _box.length,
        maxLimit: maxGuestGoals,
      );
    }
    await _box.put(goal.id, goal.toJson());
  }

  /// Get a specific goal by ID
  GoalModel? getGoal(String id) {
    final data = _box.get(id);
    if (data == null) return null;
    return GoalModel.fromJson(Map<String, dynamic>.from(data));
  }

  /// Get all goals
  List<GoalModel> getAllGoals() {
    return _box.values
        .map((e) => GoalModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  /// Get goals for a specific semester
  List<GoalModel> getGoalsBySemester(String semesterId) {
    return getAllGoals()
        .where((goal) => goal.targetSemesterId == semesterId)
        .toList();
  }

  /// Update a goal
  Future<void> updateGoal(GoalModel goal) async {
    await _box.put(goal.id, goal.toJson());
  }

  /// Delete a goal
  Future<void> deleteGoal(String id) async {
    await _box.delete(id);
  }

  /// Check if a goal exists
  bool goalExists(String id) {
    return _box.containsKey(id);
  }

  /// Clear all goals
  Future<void> clearAll() async {
    await _box.clear();
  }

  /// Get total count of goals
  int getCount() {
    return _box.length;
  }

  /// Export all goals as JSON
  List<dynamic> exportData() {
    return _box.values.toList();
  }

  /// Close the box
  Future<void> close() async {
    await _box.close();
    _isInitialized = false;
  }
}

// Made with Bob
