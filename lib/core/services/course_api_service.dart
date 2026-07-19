import 'package:dio/dio.dart';

class CourseApiService {
  final Dio _dio;

  CourseApiService(this._dio);

  Future<Map<String, dynamic>> createCourse({
    required String name,
    required String grade,
    required int credit,
    required String type,
    required String semesterId,
    required String category,
  }) async {
    try {
      final response = await _dio.post(
        "/courses/createCourse",
        data: {
          "name": name,
          "grade": grade,
          "credit": credit,
          "type": type,
          "semester_id": semesterId,
          "category": category,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? "Something went wrong");
    }
  }

  Future<Map<String, dynamic>> updateCourse({
    required String courseId,
    String? name,
    String? grade,
    int? credit,
    String? type,
    String? category,
  }) async {
    try {
      final response = await _dio.patch(
        "/courses/editCourse/$courseId",
        data: {
          if (name != null) "name": name,
          if (grade != null) "grade": grade,
          if (credit != null) "credit": credit,
          if (type != null) "type": type,
          if (category != null) "category": category,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? "Something went wrong");
    }
  }

  Future<Map<String, dynamic>> deleteCourse({required String courseId}) async {
    try {
      final response = await _dio.delete("/courses/deleteCourse/$courseId");
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? "Something went wrong");
    }
  }

  Future<Map<String, dynamic>> getCourseById({required String courseId}) async {
    try {
      final response = await _dio.get("/courses/getCourseById/$courseId");
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? "Something went wrong");
    }
  }
}