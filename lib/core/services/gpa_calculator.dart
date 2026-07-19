import 'package:academic_planner_fe/features/course/data/course_model.dart';

class SemesterGpaResult {
  final double gpa;
  final int totalCredits;
  final double totalGradePoints;

  const SemesterGpaResult({
    required this.gpa,
    required this.totalCredits,
    required this.totalGradePoints,
  });
}

class GpaCalculator {
  const GpaCalculator._();

  static double gradePoint(Grade grade) {
    return switch (grade) {
      Grade.A => 4.0,
      Grade.B_PLUS => 3.5,
      Grade.B => 3.0,
      Grade.C_PLUS => 2.5,
      Grade.C => 2.0,
      Grade.D_PLUS => 1.5,
      Grade.D => 1.0,
      Grade.F => 0.0,
    };
  }

  static SemesterGpaResult calculateSemester(Iterable<CourseModel> courses) {
    var totalGradePoints = 0.0;
    var totalCredits = 0;

    for (final course in courses) {
      if (course.credit <= 0) continue;
      totalGradePoints += gradePoint(course.grade) * course.credit;
      totalCredits += course.credit;
    }

    return SemesterGpaResult(
      gpa: totalCredits == 0
          ? 0
          : roundToTwoDecimals(totalGradePoints / totalCredits),
      totalCredits: totalCredits,
      totalGradePoints: totalGradePoints,
    );
  }

  static double cumulative({
    required double totalGradePoints,
    required int totalCredits,
  }) {
    if (totalCredits <= 0) return 0;
    return roundToTwoDecimals(totalGradePoints / totalCredits);
  }

  static double roundToTwoDecimals(double value) {
    return (value * 100).round() / 100;
  }
}
