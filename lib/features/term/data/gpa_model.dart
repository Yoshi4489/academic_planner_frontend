class GpaModel {
  String userId;
  String semesterId;
  double gpa;
  double cumGpa;
  int totalCredit;
  double totalGradePoints;
  String calculatedAt;

  GpaModel({
    required this.userId,
    required this.semesterId,
    required this.gpa,
    required this.cumGpa,
    required this.totalCredit,
    required this.totalGradePoints,
    required this.calculatedAt,
  });

  factory GpaModel.fromJson(Map<String, dynamic> json) {
    return GpaModel(
      userId: json['user_id'] ?? '',
      semesterId: json['semester_id'] ?? '',
      gpa: (json['gpa'] ?? 0).toDouble(),
      cumGpa: (json['cum_gpa'] ?? 0).toDouble(),
      totalCredit: json['total_credits'] ?? 0,
      totalGradePoints: (json['total_grade_points'] ?? 0).toDouble(),
      calculatedAt: json['calculated_at'] ?? '',
    );
  }

  GpaModel copyWith({
    String? userId,
    String? semesterId,
    double? gpa,
    double? cumGpa,
    int? totalCredit,
    double? totalGradePoints,
    String? calculatedAt,
  }) {
    return GpaModel(
      userId: userId ?? this.userId,
      semesterId: semesterId ?? this.semesterId,
      gpa: gpa ?? this.gpa,
      cumGpa: cumGpa ?? this.cumGpa,
      totalCredit: totalCredit ?? this.totalCredit,
      totalGradePoints: totalGradePoints ?? this.totalGradePoints,
      calculatedAt: calculatedAt ?? this.calculatedAt,
    );
  }
}
