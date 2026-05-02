import 'package:academic_planner_fe/core/providers/api_providers.dart';
import 'package:academic_planner_fe/core/services/course_api_service.dart';
import 'package:academic_planner_fe/core/services/hive_service.dart';
import 'package:academic_planner_fe/core/services/guest_mode_exceptions.dart';
import 'package:academic_planner_fe/features/auth/providers/auth_provider.dart';
import 'package:academic_planner_fe/features/course/data/course_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

const _courseSentinel = Object();

class CourseState {
  final bool isLoading;
  final String? error;
  final List<CourseModel> courses;

  CourseState({this.isLoading = false, this.error, this.courses = const []});

  CourseState copyWith({
    bool? isLoading,
    Object? error = _courseSentinel,
    List<CourseModel>? courses,
  }) {
    return CourseState(
      isLoading: isLoading ?? this.isLoading,
      error: error == _courseSentinel ? this.error : error as String?,
      courses: courses ?? this.courses,
    );
  }
}

class CourseController extends StateNotifier<CourseState> {
  final CourseApiService _apiService;
  final HiveService _hiveService;
  final Ref _ref;

  CourseController(this._apiService, this._hiveService, this._ref) : super(CourseState());

  bool get _isLoggedIn => _ref.read(authProvider).user != null;

  // Helper function to calculate grade point
  double _calculateGradePoint(String grade) {
    final gradePoints = {
      'A': 4.0,
      'B_PLUS': 3.5,
      'B': 3.0,
      'C_PLUS': 2.5,
      'C': 2.0,
      'D_PLUS': 1.5,
      'D': 1.0,
      'F': 0.0,
    };
    return gradePoints[grade] ?? 0.0;
  }

  Future<void> addCourse({
    required String name,
    required String grade,
    required int credit,
    required String type,
    required String semesterId,
    required String category,
  }) async {
    if (state.isLoading) return;
    try {
      state = state.copyWith(isLoading: true, error: "");

      CourseModel course;

      if (_isLoggedIn) {
        // User is logged in - use API
        final response = await _apiService.createCourse(
          name: name,
          grade: grade,
          credit: credit,
          type: type,
          semesterId: semesterId,
          category: category,
        );
        course = CourseModel.fromJson(response['course']);
      } else {
        // Guest mode - use Hive
        final id = 'course_${DateTime.now().millisecondsSinceEpoch}';
        course = CourseModel(
          id: id,
          name: name,
          category: CategoryExtension.fromString(category),
          grade: GradeExtension.fromString(grade),
          gradePoint: _calculateGradePoint(grade),
          credit: credit,
          type: TypeExtension.fromString(type),
          createdAt: DateTime.now().toIso8601String(),
          semesterId: semesterId,
        );
        await _hiveService.saveCourse(course);
        
        // Recalculate GPA for the semester after adding course
        await _hiveService.calculateAndUpdateGpa(semesterId, 'guest');
        await _hiveService.recalculateAllCumulativeGpas('guest');
      }

      state = state.copyWith(
        isLoading: false,
        error: "",
        courses: [...state.courses, course],
      );
    } on CourseLimitException catch (e) {
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

  void reset() => state = CourseState();
}

final courseProvider = StateNotifierProvider<CourseController, CourseState>((
  ref,
) {
  return CourseController(
    ref.read(courseApiServiceProvider),
    ref.read(hiveServiceProvider),
    ref,
  );
});
