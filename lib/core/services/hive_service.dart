import 'package:hive_flutter/hive_flutter.dart';
import 'package:academic_planner_fe/features/term/data/term_model.dart';
import 'package:academic_planner_fe/features/goal/data/goal_model.dart';
import 'package:academic_planner_fe/features/course/data/course_model.dart';
import 'package:academic_planner_fe/features/term/data/gpa_model.dart';
import 'package:academic_planner_fe/core/services/term_hive_service.dart';
import 'package:academic_planner_fe/core/services/goal_hive_service.dart';
import 'package:academic_planner_fe/core/services/course_hive_service.dart';
import 'package:academic_planner_fe/core/services/gpa_hive_service.dart';

/// Main Hive service that coordinates all specialized Hive services
/// This service maintains backward compatibility while delegating to specialized services
class HiveService {
  static final HiveService _instance = HiveService._internal();

  factory HiveService() => _instance;

  HiveService._internal();

  // Specialized services
  final TermHiveService _termService = TermHiveService();
  final GoalHiveService _goalService = GoalHiveService();
  final CourseHiveService _courseService = CourseHiveService();
  final GpaHiveService _gpaService = GpaHiveService();

  bool _isInitialized = false;

  /// Initialize Hive and open all boxes
  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(TermHiveService.boxName);
    await Hive.openBox(GoalHiveService.boxName);
    await Hive.openBox(CourseHiveService.boxName);
    await Hive.openBox(GpaHiveService.boxName);
  }

  /// Setup box references (call after init)
  void setupBoxes() {
    if (_isInitialized) return;
    
    _termService.init();
    _goalService.init();
    _courseService.init();
    _gpaService.init();
    
    _isInitialized = true;
  }

  // ==================== TERM OPERATIONS ====================

  /// Save a term to local storage
  Future<void> saveTerm(TermModel term) async {
    await _termService.saveTerm(term);
  }

  /// Get a specific term by ID
  TermModel? getTerm(String id) {
    return _termService.getTerm(id);
  }

  /// Get all terms
  List<TermModel> getAllTerms() {
    return _termService.getAllTerms();
  }

  /// Update a term
  Future<void> updateTerm(TermModel term) async {
    await _termService.updateTerm(term);
  }

  /// Delete a term
  Future<void> deleteTerm(String id) async {
    await _termService.deleteTerm(id);
  }

  /// Check if a term exists
  bool termExists(String id) {
    return _termService.termExists(id);
  }

  // ==================== GOAL OPERATIONS ====================

  /// Save a goal to local storage
  Future<void> saveGoal(GoalModel goal) async {
    await _goalService.saveGoal(goal);
  }

  /// Get a specific goal by ID
  GoalModel? getGoal(String id) {
    return _goalService.getGoal(id);
  }

  /// Get all goals
  List<GoalModel> getAllGoals() {
    return _goalService.getAllGoals();
  }

  /// Get goals for a specific semester
  List<GoalModel> getGoalsBySemester(String semesterId) {
    return _goalService.getGoalsBySemester(semesterId);
  }

  /// Update a goal
  Future<void> updateGoal(GoalModel goal) async {
    await _goalService.updateGoal(goal);
  }

  /// Delete a goal
  Future<void> deleteGoal(String id) async {
    await _goalService.deleteGoal(id);
  }

  /// Check if a goal exists
  bool goalExists(String id) {
    return _goalService.goalExists(id);
  }

  // ==================== COURSE OPERATIONS ====================

  /// Save a course to local storage
  Future<void> saveCourse(CourseModel course) async {
    await _courseService.saveCourse(course);
  }

  /// Get a specific course by ID
  CourseModel? getCourse(String id) {
    return _courseService.getCourse(id);
  }

  /// Get all courses
  List<CourseModel> getAllCourses() {
    return _courseService.getAllCourses();
  }

  /// Get courses for a specific semester
  List<CourseModel> getCoursesBySemester(String semesterId) {
    return _courseService.getCoursesBySemester(semesterId);
  }

  /// Update a course
  Future<void> updateCourse(CourseModel course) async {
    await _courseService.updateCourse(course);
  }

  /// Delete a course
  Future<void> deleteCourse(String id) async {
    await _courseService.deleteCourse(id);
  }

  /// Delete all courses for a semester
  Future<void> deleteCoursesBySemester(String semesterId) async {
    await _courseService.deleteCoursesBySemester(semesterId);
  }

  /// Check if a course exists
  bool courseExists(String id) {
    return _courseService.courseExists(id);
  }

  // ==================== GPA OPERATIONS ====================

  /// Save a GPA record to local storage
  Future<void> saveGpa(GpaModel gpa) async {
    await _gpaService.saveGpa(gpa);
  }

  /// Get GPA for a specific semester
  GpaModel? getGpaBySemester(String semesterId) {
    return _gpaService.getGpaBySemester(semesterId);
  }

  /// Get all GPA records
  List<GpaModel> getAllGpas() {
    return _gpaService.getAllGpas();
  }

  /// Update a GPA record
  Future<void> updateGpa(GpaModel gpa) async {
    await _gpaService.updateGpa(gpa);
  }

  /// Delete a GPA record
  Future<void> deleteGpa(String semesterId) async {
    await _gpaService.deleteGpa(semesterId);
  }

  // ==================== UTILITY OPERATIONS ====================

  /// Clear all guest data (useful when user logs in)
  Future<void> clearAllGuestData() async {
    await _termService.clearAll();
    await _goalService.clearAll();
    await _courseService.clearAll();
    await _gpaService.clearAll();
  }

  /// Get total count of all stored items
  int getTotalItemCount() {
    return _termService.getCount() +
        _goalService.getCount() +
        _courseService.getCount() +
        _gpaService.getCount();
  }

  /// Check if any guest data exists
  bool hasGuestData() {
    return getTotalItemCount() > 0;
  }

  /// Export all data as JSON (useful for debugging or migration)
  Map<String, dynamic> exportAllData() {
    return {
      'terms': _termService.exportData(),
      'goals': _goalService.exportData(),
      'courses': _courseService.exportData(),
      'gpas': _gpaService.exportData(),
    };
  }

  /// Close all boxes (call when app is closing)
  Future<void> closeBoxes() async {
    await _termService.close();
    await _goalService.close();
    await _courseService.close();
    await _gpaService.close();
    _isInitialized = false;
  }

  // ==================== GUEST MODE LIMIT CHECKS ====================

  /// Check if term limit is reached
  bool isTermLimitReached() => _termService.isLimitReached();

  /// Check if can add more terms
  bool canAddMoreTerms() => _termService.canAddMore();

  /// Get remaining term slots
  int getRemainingTermSlots() => _termService.getRemainingSlots();

  /// Check if goal limit is reached
  bool isGoalLimitReached() => _goalService.isLimitReached();

  /// Check if can add more goals
  bool canAddMoreGoals() => _goalService.canAddMore();

  /// Get remaining goal slots
  int getRemainingGoalSlots() => _goalService.getRemainingSlots();

  /// Check if course limit is reached
  bool isCourseLimitReached() => _courseService.isLimitReached();

  /// Check if can add more courses
  bool canAddMoreCourses() => _courseService.canAddMore();

  /// Get remaining course slots
  int getRemainingCourseSlots() => _courseService.getRemainingSlots();

  /// Get guest mode limits summary
  Map<String, dynamic> getGuestModeLimits() {
    return {
      'terms': {
        'current': _termService.getCount(),
        'max': TermHiveService.maxGuestTerms,
        'remaining': _termService.getRemainingSlots(),
        'canAddMore': _termService.canAddMore(),
      },
      'goals': {
        'current': _goalService.getCount(),
        'max': GoalHiveService.maxGuestGoals,
        'remaining': _goalService.getRemainingSlots(),
        'canAddMore': _goalService.canAddMore(),
      },
      'courses': {
        'current': _courseService.getCount(),
        'max': CourseHiveService.maxGuestCourses,
        'remaining': _courseService.getRemainingSlots(),
        'canAddMore': _courseService.canAddMore(),
      },
    };
  }

  // ==================== DIRECT SERVICE ACCESS ====================
  // For advanced use cases, you can access the specialized services directly

  /// Get the term service for advanced operations
  TermHiveService get termService => _termService;

  /// Get the goal service for advanced operations
  GoalHiveService get goalService => _goalService;

  /// Get the course service for advanced operations
  CourseHiveService get courseService => _courseService;

  /// Get the GPA service for advanced operations
  GpaHiveService get gpaService => _gpaService;
}

// Made with Bob
