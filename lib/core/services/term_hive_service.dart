import 'package:hive_flutter/hive_flutter.dart';
import 'package:academic_planner_fe/features/term/data/term_model.dart';
import 'package:academic_planner_fe/core/services/guest_mode_exceptions.dart';

/// Service for managing Term data in Hive local storage
class TermHiveService {
  static const String boxName = 'guest_terms';
  static const int maxGuestTerms = 5;
  
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
    return _box.length >= maxGuestTerms;
  }

  /// Check if can add more terms
  bool canAddMore() {
    return _box.length < maxGuestTerms;
  }

  /// Get remaining slots
  int getRemainingSlots() {
    return maxGuestTerms - _box.length;
  }

  /// Save a term to local storage
  /// Throws [SemesterLimitException] if guest mode limit is reached
  Future<void> saveTerm(TermModel term) async {
    if (isLimitReached()) {
      throw SemesterLimitException(
        currentCount: _box.length,
        maxLimit: maxGuestTerms,
      );
    }
    await _box.put(term.id, term.toJson());
  }

  /// Get a specific term by ID
  TermModel? getTerm(String id) {
    final data = _box.get(id);
    if (data == null) return null;
    return TermModel.fromJson(Map<String, dynamic>.from(data));
  }

  /// Get all terms
  List<TermModel> getAllTerms() {
    return _box.values
        .map((e) => TermModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  /// Update a term
  Future<void> updateTerm(TermModel term) async {
    await _box.put(term.id, term.toJson());
  }

  /// Delete a term
  Future<void> deleteTerm(String id) async {
    await _box.delete(id);
  }

  /// Check if a term exists
  bool termExists(String id) {
    return _box.containsKey(id);
  }

  /// Clear all terms
  Future<void> clearAll() async {
    await _box.clear();
  }

  /// Get total count of terms
  int getCount() {
    return _box.length;
  }

  /// Export all terms as JSON
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
