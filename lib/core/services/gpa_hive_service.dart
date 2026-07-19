import 'package:hive_flutter/hive_flutter.dart';
import 'package:academic_planner_fe/features/term/data/gpa_model.dart';

/// Service for managing GPA data in Hive local storage
class GpaHiveService {
  static const String boxName = 'guest_gpas';
  late Box<dynamic> _box;
  bool _isInitialized = false;

  /// Initialize the box reference
  void init() {
    if (_isInitialized) return;
    _box = Hive.box(boxName);
    _isInitialized = true;
  }

  /// Save a GPA record to local storage
  Future<void> saveGpa(GpaModel gpa) async {
    await _box.put(gpa.semesterId, gpa.toJson());
  }

  /// Get GPA for a specific semester
  GpaModel? getGpaBySemester(String semesterId) {
    final data = _box.get(semesterId);
    if (data == null) return null;
    return GpaModel.fromJson(Map<String, dynamic>.from(data));
  }

  /// Get all GPA records
  List<GpaModel> getAllGpas() {
    return _box.values
        .map((e) => GpaModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  /// Update a GPA record
  Future<void> updateGpa(GpaModel gpa) async {
    await _box.put(gpa.semesterId, gpa.toJson());
  }

  /// Delete a GPA record
  Future<void> deleteGpa(String semesterId) async {
    await _box.delete(semesterId);
  }

  /// Clear all GPA records
  Future<void> clearAll() async {
    await _box.clear();
  }

  /// Get total count of GPA records
  int getCount() {
    return _box.length;
  }

  /// Export all GPA records as JSON
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
