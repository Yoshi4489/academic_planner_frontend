import 'package:academic_planner_fe/features/course/data/course_model.dart';
import 'package:academic_planner_fe/features/goal/data/goal_model.dart';
import 'package:academic_planner_fe/features/term/data/term_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses a Render semester response with nested courses and GPA', () {
    final term = TermModel.fromJson({
      'id': 'semester-1',
      'year': 2026,
      'term': 'Semester 1',
      'term_no': 1,
      'is_complete': false,
      'created_at': '2026-01-01T00:00:00.000Z',
      'user_id': 'user-1',
      'courses': [
        {
          'id': 'course-1',
          'name': 'Algorithms',
          'category': 'MAJOR_REQUIRED',
          'grade': 'B+',
          'grade_point': 3.5,
          'credit': 3,
          'type': 'PLAN',
          'created_at': '2026-01-01T00:00:00.000Z',
          'semester_id': 'semester-1',
        },
      ],
      'gpas': [
        {
          'user_id': 'user-1',
          'semester_id': 'semester-1',
          'gpa': 3.5,
          'cum_gpa': 3.5,
          'total_credits': 3,
          'total_grade_points': 10.5,
          'calculated_at': '2026-01-01T00:00:00.000Z',
        },
      ],
    });

    expect(term.termNo, 1);
    expect(term.courses.single.grade, Grade.B_PLUS);
    expect(term.courses.single.type, Type.PLAN);
    expect(term.gpas.single.cumGpa, 3.5);
  });

  test('parses and serializes the goal API contract', () {
    final goal = GoalModel.fromJson({
      'id': 'goal-1',
      'name': 'Dean list',
      'target_gpa': 3.75,
      'is_achieved': false,
      'target_semester_id': 'semester-1',
      'user_id': 'user-1',
    });

    expect(goal.targetGpa, 3.75);
    expect(goal.toJson()['target_semester_id'], 'semester-1');
  });
}
