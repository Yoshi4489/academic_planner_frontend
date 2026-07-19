import 'package:academic_planner_fe/features/course/data/course_model.dart';
import 'package:academic_planner_fe/features/term/data/gpa_model.dart';

class TermModel {
  String id;
  int year;
  String term;
  int termNo;
  bool isComplete;
  String createdAt;
  String userId;
  List<CourseModel> courses;
  List<GpaModel> gpas;

  TermModel({
    required this.id,
    required this.year,
    required this.term,
    required this.termNo,
    required this.isComplete,
    required this.createdAt,
    required this.userId,
    required this.courses,
    required this.gpas,
  });

  factory TermModel.fromJson(Map<String, dynamic> json) {
    return TermModel(
      id: json["id"] ?? "",
      year: json["year"] ?? 0,
      term: json['term'] ?? "",
      termNo: json['term_no'] ?? 0,
      isComplete: json["is_complete"] ?? false,
      createdAt: json['created_at'] ?? "",
      userId: json['user_id'] ?? "",
      courses: (json['courses'] as List<dynamic>? ?? [])
          .map((e) => CourseModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      gpas: (json['gpas'] as List<dynamic>? ?? [])
          .map((e) => GpaModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'year': year,
      'term': term,
      'term_no': termNo,
      'is_complete': isComplete,
      'created_at': createdAt,
      'user_id': userId,
      'courses': courses.map((c) => c.toJson()).toList(),
      'gpas': gpas.map((g) => g.toJson()).toList(),
    };
  }

  TermModel copyWith({
    String? id,
    int? year,
    String? term,
    int? termNo,
    bool? isComplete,
    String? createdAt,
    String? userId,
    List<CourseModel>? courses,
    List<GpaModel>? gpas,
  }) {
    return TermModel(
      id: id ?? this.id,
      year: year ?? this.year,
      term: term ?? this.term,
      termNo: termNo ?? this.termNo,
      isComplete: isComplete ?? this.isComplete,
      createdAt: createdAt ?? this.createdAt,
      userId: userId ?? this.userId,
      courses: courses ?? this.courses,
      gpas: gpas ?? this.gpas,
    );
  }
}
