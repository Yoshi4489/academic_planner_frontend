import 'package:academic_planner_fe/core/services/gpa_calculator.dart';
import 'package:academic_planner_fe/features/course/data/course_model.dart';
import 'package:flutter_test/flutter_test.dart';

CourseModel course({
  required String id,
  required Grade grade,
  required int credit,
  Type type = Type.ACTUAL,
}) {
  return CourseModel(
    id: id,
    name: id,
    category: Category.MAJOR_REQUIRED,
    grade: grade,
    gradePoint: GpaCalculator.gradePoint(grade),
    credit: credit,
    type: type,
    createdAt: '2026-01-01T00:00:00.000Z',
    semesterId: 'semester-1',
  );
}

void main() {
  test('maps every supported grade to the backend grade-point scale', () {
    expect(Grade.values.map(GpaCalculator.gradePoint).toList(), [
      4.0,
      3.5,
      3.0,
      2.5,
      2.0,
      1.5,
      1.0,
      0.0,
    ]);
  });

  test('calculates a credit-weighted semester GPA', () {
    final result = GpaCalculator.calculateSemester([
      course(id: 'A', grade: Grade.A, credit: 3),
      course(id: 'B', grade: Grade.B, credit: 3),
    ]);

    expect(result.gpa, 3.5);
    expect(result.totalCredits, 6);
    expect(result.totalGradePoints, 21);
  });

  test('includes planned and actual courses in projected GPA', () {
    final result = GpaCalculator.calculateSemester([
      course(id: 'planned', grade: Grade.C_PLUS, credit: 2, type: Type.PLAN),
      course(id: 'actual', grade: Grade.A, credit: 1),
    ]);

    expect(result.gpa, 3.0);
    expect(result.totalCredits, 3);
    expect(result.totalGradePoints, 9);
  });

  test('returns zero for empty and non-positive-credit courses', () {
    expect(GpaCalculator.calculateSemester([]).gpa, 0);
    expect(
      GpaCalculator.calculateSemester([
        course(id: 'zero', grade: Grade.A, credit: 0),
      ]).gpa,
      0,
    );
  });

  test('calculates and rounds cumulative GPA to backend precision', () {
    expect(
      GpaCalculator.cumulative(totalGradePoints: 30, totalCredits: 9),
      3.33,
    );
  });
}
