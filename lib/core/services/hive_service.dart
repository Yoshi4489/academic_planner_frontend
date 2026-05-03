import 'package:hive_flutter/hive_flutter.dart';
import 'package:academic_planner_fe/features/term/data/term_model.dart';
import 'package:academic_planner_fe/features/goal/data/goal_model.dart';
import 'package:academic_planner_fe/features/course/data/course_model.dart';
import 'package:academic_planner_fe/features/term/data/gpa_model.dart';
import 'package:academic_planner_fe/core/services/term_hive_service.dart';
import 'package:academic_planner_fe/core/services/goal_hive_service.dart';
import 'package:academic_planner_fe/core/services/course_hive_service.dart';
import 'package:academic_planner_fe/core/services/gpa_hive_service.dart';

/// Helper function to calculate grade point from grade
double _gradeToPoint(Grade grade) {
  switch (grade) {
    case Grade.A:
      return 4.0;
    case Grade.B_PLUS:
      return 3.5;
    case Grade.B:
      return 3.0;
    case Grade.C_PLUS:
      return 2.5;
    case Grade.C:
      return 2.0;
    case Grade.D_PLUS:
      return 1.5;
    case Grade.D:
      return 1.0;
    case Grade.F:
      return 0.0;
  }
}

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

  // ==================== GPA CALCULATION ====================

  /// Calculate and update GPA for a semester based on its courses
  Future<void> calculateAndUpdateGpa(String semesterId, String userId) async {
    // Get all courses for this semester
    final courses = getCoursesBySemester(semesterId);
    TermModel? term = getTerm(semesterId);

    if (term == null) {
      return;
    }

    // Calculate GPA
    double totalGradePoints = 0.0;
    int totalCredits = 0;

    for (var course in courses) {
      final gradePoint = _gradeToPoint(course.grade);
      totalGradePoints += gradePoint * course.credit;
      totalCredits += course.credit;
    }

    final gpa = totalCredits > 0 ? totalGradePoints / totalCredits : 0.0;

    // Calculate cumulative GPA (average of all semesters)
    final allGpas = getAllGpas();
    double cumGpa = gpa; // Default to current GPA

    if (allGpas.isNotEmpty) {
      double totalGpa = gpa;
      int count = 1;

      for (var existingGpa in allGpas) {
        if (existingGpa.semesterId != semesterId) {
          totalGpa += existingGpa.gpa;
          count++;
        }
      }

      cumGpa = totalGpa / count;
    }

    // Create or update GPA model
    final gpaModel = GpaModel(
      userId: userId,
      semesterId: semesterId,
      gpa: gpa,
      cumGpa: cumGpa,
      totalCredit: totalCredits,
      totalGradePoints: totalGradePoints,
      calculatedAt: DateTime.now().toIso8601String(),
    );

    term = term.copyWith(gpas: [gpaModel], courses: courses);

    await updateTerm(term);
    await saveGpa(gpaModel);
  }

  /// Recalculate cumulative GPA for all semesters
  Future<void> recalculateAllCumulativeGpas(String userId) async {
    final allGpas = getAllGpas();

    if (allGpas.isEmpty) return;

    // Calculate average GPA
    double totalGpa = 0.0;
    for (var gpa in allGpas) {
      totalGpa += gpa.gpa;
    }
    final cumGpa = totalGpa / allGpas.length;

    // Update all GPAs with new cumulative GPA
    for (var gpa in allGpas) {
      final updatedGpa = gpa.copyWith(
        cumGpa: cumGpa,
        calculatedAt: DateTime.now().toIso8601String(),
      );
      await updateGpa(updatedGpa);
    }
  }
}
