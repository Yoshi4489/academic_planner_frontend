enum Category { GEN_ED, MAJOR_REQUIRED, MAJOR_ELECTIVE, MINOR, FREE_ELECTIVE }
enum Grade { A, B_PLUS, B, C_PLUS, C, D_PLUS, D, F }
enum Type { ACTUAL, PLAN }

extension CategoryExtension on Category {
  static Category fromString(String value) {
    return Category.values.firstWhere(
          (e) => e.name == value,
      orElse: () => Category.FREE_ELECTIVE,
    );
  }

  String get displayName {
    return name.replaceAll('_', ' ');
  }
}

extension GradeExtension on Grade {
  static Grade fromString(String value) {
    final mapped = value
        .replaceAll('+', '_PLUS')
        .replaceAll('-', '_MINUS');
    return Grade.values.firstWhere(
          (e) => e.name == mapped,
      orElse: () => Grade.F,
    );
  }

  String get displayName {
    return name.replaceAll('_PLUS', '+').replaceAll('_MINUS', '-');
  }
}

extension TypeExtension on Type {
  static Type fromString(String value) {
    return Type.values.firstWhere(
          (e) => e.name == value,
      orElse: () => Type.ACTUAL,
    );
  }
}

class CourseModel {
  final String id;
  final String name;
  final Category category;
  final Grade grade;
  final double gradePoint;
  final int credit;
  final Type type;
  final String createdAt;
  final String semesterId;

  CourseModel({
    required this.id,
    required this.name,
    required this.category,
    required this.grade,
    required this.gradePoint,
    required this.credit,
    required this.type,
    required this.createdAt,
    required this.semesterId,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      category: CategoryExtension.fromString(json['category'] ?? ''),
      grade: GradeExtension.fromString(json['grade'] ?? ''),
      gradePoint: (json['grade_point'] ?? 0).toDouble(),
      credit: json['credit'] ?? 0,
      type: TypeExtension.fromString(json['type'] ?? ''),
      createdAt: json['created_at'] ?? '',
      semesterId: json['semester_id'] ?? '',
    );
  }

  CourseModel copyWith({
    String? id,
    String? name,
    Category? category,
    Grade? grade,
    double? gradePoint,
    int? credit,
    Type? type,
    String? createdAt,
    String? semesterId,
  }) {
    return CourseModel(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      grade: grade ?? this.grade,
      gradePoint: gradePoint ?? this.gradePoint,
      credit: credit ?? this.credit,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      semesterId: semesterId ?? this.semesterId,
    );
  }
}