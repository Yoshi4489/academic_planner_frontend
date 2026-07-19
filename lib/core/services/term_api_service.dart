import 'package:dio/dio.dart';

class TermApiService {
  final Dio _dio;

  TermApiService(this._dio);

  Future<Map<String, dynamic>> createTerm({
    required String term,
    required int year,
    required int termNo,
    required bool isComplete,
  }) async {
    try {
      final response = await _dio.post(
        '/semesters/addSemester',
        data: {
          'term': term,
          'year': year,
          'term_no': termNo,
          'is_complete': isComplete,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Something went wrong');
    }
  }

  Future<Map<String, dynamic>> updateTerm({
    required String termId,
    String? name,
    int? year,
    int? termNo,
    bool? isComplete,
  }) async {
    try {
      final response = await _dio.patch(
        '/semesters/updateSemester/$termId',
        data: {
          if (name != null) 'term': name,
          if (year != null) 'year': year,
          if (termNo != null) 'term_no': termNo,
          if (isComplete != null) 'is_complete': isComplete,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Something went wrong');
    }
  }

  Future<Map<String, dynamic>> deleteTerm({required String termId}) async {
    try {
      final response = await _dio.delete("/semesters/deleteSemester/$termId");
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? "Something went wrong");
    }
  }

  Future<Map<String, dynamic>> findTermsByUserId() async {
    try {
      final response = await _dio.get('/semesters/getSemesters');
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Something went wrong');
    }
  }

  Future<Map<String, dynamic>> findTermById(String termId) async {
    try {
      final response = await _dio.get('/semesters/getSemesterById/$termId');
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Something went wrong');
    }
  }
}
