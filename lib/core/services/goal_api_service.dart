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
    required double targetGpa,
    required String semesterId,
    required bool isAchieved,
  }) async {
    try {
      final response = await _dio.post(
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

  Future<Map<String, dynamic>> findGoalById({required String goalId}) async {
    try {
      final response = await _dio.get("/goals/getGoalById/$goalId");
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? "Something went wrong");
    }
  }

  Future<Map<String, dynamic>> updateGoal({
    required String goalId,
    String? name,
    bool? isAchieved,
    String? targetSemesterId,
    double? targetGpa,
  }) async {
    try {
      final response = await _dio.patch("/goals/updateGoal/$goalId", data: {
        if (name != null) "name": name,
        if (isAchieved != null) "is_achieved": isAchieved,
        if (targetSemesterId != null) "target_semester_id": targetSemesterId,
        if (targetGpa != null) "target_gpa": targetGpa
      });
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? "Something went wrong");
    }
  }

  Future<Map<String, dynamic>> deleteGoal({required String goalId}) async {
    try {
      final response = await _dio.delete("/goals/deleteGoal/$goalId");
      return response.data;
    }
    on DioException catch(e) {
      throw Exception(e.response?.data['message'] ?? "Something went wrong");
    }
  }
}
