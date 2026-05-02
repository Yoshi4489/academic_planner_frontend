import 'package:academic_planner_fe/core/providers/api_providers.dart';
import 'package:academic_planner_fe/core/services/course_api_service.dart';
import 'package:academic_planner_fe/core/services/hive_service.dart';
import 'package:academic_planner_fe/features/auth/providers/auth_provider.dart';
import 'package:academic_planner_fe/features/course/data/course_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

class CourseDetailState {
  final bool isLoading;
  final String? error;
  final CourseModel? course;

  CourseDetailState({this.isLoading = false, this.error, this.course});

  CourseDetailState copyWith({
    bool? isLoading,
    String? error,
    CourseModel? course,
  }) {
    return CourseDetailState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      course: course ?? this.course,
    );
  }
}

class CourseDetailsController extends StateNotifier<CourseDetailState> {
  final CourseApiService _apiService;
  final HiveService _hiveService;
  final Ref _ref;

  CourseDetailsController(this._apiService, this._hiveService, this._ref) : super(CourseDetailState());

  bool get _isLoggedIn => _ref.read(authProvider).user != null;

  Future<void> editCourse({
    required String courseId,
    String? name,
    String? grade,
    int? credit,
    String? type,
    String? category,
  }) async {
    if (state.isLoading) return;
    try {
      state = state.copyWith(isLoading: true, error: "");

      CourseModel? course;

      if (_isLoggedIn) {
        // User is logged in - use API
        final response = await _apiService.updateCourse(
          courseId: courseId,
          name: name,
          grade: grade,
          credit: credit,
          type: type,
          category: category,
        );
        course = CourseModel.fromJson(response['course']);
      } else {
        // Guest mode - update in Hive
        final existingCourse = _hiveService.getCourse(courseId);
        if (existingCourse != null) {
          course = existingCourse.copyWith(
            name: name ?? existingCourse.name,
            grade: grade != null ? GradeExtension.fromString(grade) : existingCourse.grade,
            credit: credit ?? existingCourse.credit,
            type: type != null ? TypeExtension.fromString(type) : existingCourse.type,
            category: category != null ? CategoryExtension.fromString(category) : existingCourse.category,
          );
          await _hiveService.updateCourse(course);
          
          // Recalculate GPA for the semester after editing course
          await _hiveService.calculateAndUpdateGpa(existingCourse.semesterId, 'guest');
          await _hiveService.recalculateAllCumulativeGpas('guest');
        }
      }

      state = state.copyWith(course: course, isLoading: false, error: "");
    } on Exception catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst("Exception: ", ""),
      );
    }
  }

  Future<void> removeCourse({required String courseId}) async {
    if (state.isLoading) return;
    try {
      state = state.copyWith(isLoading: true, error: "");

      if (_isLoggedIn) {
        // User is logged in - delete via API
        await _apiService.deleteCourse(courseId: courseId);
      } else {
        // Guest mode - delete from Hive
        // Get the course before deleting to know which semester to recalculate
        final course = _hiveService.getCourse(courseId);
        await _hiveService.deleteCourse(courseId);
        
        // Recalculate GPA for the semester after deleting course
        if (course != null) {
          await _hiveService.calculateAndUpdateGpa(course.semesterId, 'guest');
          await _hiveService.recalculateAllCumulativeGpas('guest');
        }
      }

      state = state.copyWith(isLoading: false, error: "");
    } on Exception catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst("Exception: ", ""),
      );
    }
  }

  Future<void> findCourseById({required String courseId}) async {
    if (state.isLoading) return;
    try {
      state = state.copyWith(isLoading: true, error: "");

      CourseModel? course;

      if (_isLoggedIn) {
        // User is logged in - fetch from API
        final response = await _apiService.getCourseById(courseId: courseId);
        course = CourseModel.fromJson(response['course']);
      } else {
        // Guest mode - fetch from Hive
        course = _hiveService.getCourse(courseId);
      }

      state = state.copyWith(isLoading: false, course: course, error: "");
    } on Exception catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst("Exception: ", ""),
      );
    }
  }

  void reset() => state = CourseDetailState();
}

final courseDetailsProvider =
    StateNotifierProvider<CourseDetailsController, CourseDetailState>((ref) {
      return CourseDetailsController(
        ref.read(courseApiServiceProvider),
        ref.read(hiveServiceProvider),
        ref,
      );
    });
