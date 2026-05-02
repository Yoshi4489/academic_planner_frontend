import 'package:academic_planner_fe/core/providers/api_providers.dart';
import 'package:academic_planner_fe/core/services/course_api_service.dart';
import 'package:academic_planner_fe/features/course/data/course_model.dart';
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

  CourseDetailsController(this._apiService) : super(CourseDetailState());
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
      state = state.copyWith(isLoading: false, error: "");
      final response = await _apiService.updateCourse(
        courseId: courseId,
        name: name,
        grade: grade,
        credit: credit,
        type: type,
        category: category,
      );
      final course = CourseModel.fromJson(response['course']);
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
      final response = await _apiService.deleteCourse(courseId: courseId);
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
      final response = await _apiService.getCourseById(courseId: courseId);
      final course = CourseModel.fromJson(response['course']);
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
      return CourseDetailsController(ref.read(courseApiServiceProvider));
    });
