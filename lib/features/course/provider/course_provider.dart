import 'package:academic_planner_fe/core/providers/api_providers.dart';
import 'package:academic_planner_fe/core/services/course_api_service.dart';
import 'package:academic_planner_fe/features/course/data/course_model.dart';
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

  CourseController(this._apiService) : super(CourseState());

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
      final response = await _apiService.createCourse(
        name: name,
        grade: grade,
        credit: credit,
        type: type,
        semesterId: semesterId,
        category: category,
      );
      final course = CourseModel.fromJson(response['course']);
      state = state.copyWith(
        isLoading: false,
        error: "",
        courses: [...state.courses, course],
      );
    } on Exception catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> editCourse({
    required String courseId,
    String? name,
    String? grade,
    int? credit,
    String? type,
    String? category,
}) async{
    if (state.isLoading) return;
    try {
      state = state.copyWith(isLoading: false, error: "");
      final response = await _apiService.updateCourse(courseId: courseId);
      final course = CourseModel.fromJson(response['course']);
      // will perfome this in course detail later
    }
        on Exception catch(e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst("Exception: ", "")
      );
        }
  }
}

final courseProvider = StateNotifierProvider<CourseController, CourseState>((
  ref,
) {
  return CourseController(ref.read(courseApiServiceProvider));
});
