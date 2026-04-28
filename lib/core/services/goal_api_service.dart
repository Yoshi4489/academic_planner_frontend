import 'package:dio/dio.dart';

class GoalApiService {
  final Dio _dio;

  GoalApiService(this._dio);

  Future<Map<String, dynamic>> findGoalsByUserId() async {
    try {
      final response = await _dio.get("/goals/getGoalByUserId");
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? "Something went wrong");
    }
  }

  Future<Map<String, dynamic>> addGoal({
    required String name,
    required int targetGpa,
    required String semesterId,
    required bool isAchieved,
  }) async {
    try {
      final response = await _dio.get(
        "/goals/createGoal",
        data: {
          'name': name,
          'target_gpa': targetGpa,
          "target_semester_id": semesterId,
          "is_achieved": isAchieved,
        },
      );

      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? "Something went wrong");
    }
  }
}
