import 'package:hive_flutter/hive_flutter.dart';
import 'package:academic_planner_fe/features/course/data/course_model.dart';

/// Service for managing Course data in Hive local storage
class CourseHiveService {
  static const String boxName = 'guest_courses';
  late Box<dynamic> _box;
  bool _isInitialized = false;

  /// Initialize the box reference
  void init() {
    if (_isInitialized) return;
    _box = Hive.box(boxName);
    _isInitialized = true;
  }

  /// Save a course to local storage
  Future<void> saveCourse(CourseModel course) async {
    await _box.put(course.id, course.toJson());
  }

  /// Get a specific course by ID
  CourseModel? getCourse(String id) {
    final data = _box.get(id);
    if (data == null) return null;
    return CourseModel.fromJson(Map<String, dynamic>.from(data));
  }

  /// Get all courses
  List<CourseModel> getAllCourses() {
    return _box.values
        .map((e) => CourseModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  /// Get courses for a specific semester
  List<CourseModel> getCoursesBySemester(String semesterId) {
    return getAllCourses()
        .where((course) => course.semesterId == semesterId)
        .toList();
  }

  /// Update a course
  Future<void> updateCourse(CourseModel course) async {
    await _box.put(course.id, course.toJson());
  }

  /// Delete a course
  Future<void> deleteCourse(String id) async {
    await _box.delete(id);
  }

  /// Delete all courses for a semester
  Future<void> deleteCoursesBySemester(String semesterId) async {
    final courses = getCoursesBySemester(semesterId);
    for (var course in courses) {
      await _box.delete(course.id);
    }
  }

  /// Check if a course exists
  bool courseExists(String id) {
    return _box.containsKey(id);
  }

  /// Clear all courses
  Future<void> clearAll() async {
    await _box.clear();
  }

  /// Get total count of courses
  int getCount() {
    return _box.length;
  }

  /// Export all courses as JSON
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
