import 'dart:io';

import 'package:academic_planner_fe/core/services/goal_hive_service.dart';
import 'package:academic_planner_fe/core/services/gpa_calculator.dart';
import 'package:academic_planner_fe/core/services/gpa_hive_service.dart';
import 'package:academic_planner_fe/core/services/guest_mode_exceptions.dart';
import 'package:academic_planner_fe/core/services/hive_service.dart';
import 'package:academic_planner_fe/core/services/course_hive_service.dart';
import 'package:academic_planner_fe/core/services/term_hive_service.dart';
import 'package:academic_planner_fe/features/course/data/course_model.dart';
import 'package:academic_planner_fe/features/goal/data/goal_model.dart';
import 'package:academic_planner_fe/features/term/data/gpa_model.dart';
import 'package:academic_planner_fe/features/term/data/term_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';

TermModel term(String id, int year, int termNo) {
  final gpa = GpaModel(
    userId: 'guest',
    semesterId: id,
    gpa: 0,
    cumGpa: 0,
    totalCredit: 0,
    totalGradePoints: 0,
    calculatedAt: '2026-01-01T00:00:00.000Z',
  );
  return TermModel(
    id: id,
    year: year,
    term: 'Semester $termNo',
    termNo: termNo,
    isComplete: false,
    createdAt: '$year-01-0${termNo}T00:00:00.000Z',
    userId: 'guest',
    courses: const [],
    gpas: [gpa],
  );
}

CourseModel course(
  String id,
  String semesterId,
  Grade grade,
  int credit,
  Type type,
) {
  return CourseModel(
    id: id,
    name: id,
    category: Category.MAJOR_REQUIRED,
    grade: grade,
    gradePoint: GpaCalculator.gradePoint(grade),
    credit: credit,
    type: type,
    createdAt: '2026-01-01T00:00:00.000Z',
    semesterId: semesterId,
  );
}

void main() {
  late Directory tempDirectory;
  final service = HiveService();

  setUpAll(() async {
    tempDirectory = Directory.systemTemp.createTempSync('planner_hive_test_');
    Hive.init(tempDirectory.path);
    await Hive.openBox(TermHiveService.boxName);
    await Hive.openBox(GoalHiveService.boxName);
    await Hive.openBox(CourseHiveService.boxName);
    await Hive.openBox(GpaHiveService.boxName);
    service.setupBoxes();
  });

  setUp(service.clearAllGuestData);

  tearDownAll(() async {
    await service.clearAllGuestData();
    await service.closeBoxes();
    tempDirectory.deleteSync(recursive: true);
  });

  test('stores chronological credit-weighted cumulative GPA', () async {
    // Save out of order to prove chronology does not depend on Hive insertion.
    final second = term('semester-2', 2026, 2);
    final first = term('semester-1', 2026, 1);
    await service.saveTerm(second);
    await service.saveGpa(second.gpas.single);
    await service.saveTerm(first);
    await service.saveGpa(first.gpas.single);

    await service.saveCourse(course('c1', first.id, Grade.A, 3, Type.ACTUAL));
    await service.saveCourse(course('c2', first.id, Grade.B, 3, Type.PLAN));
    await service.saveCourse(
      course('c3', second.id, Grade.C_PLUS, 2, Type.PLAN),
    );
    await service.saveCourse(course('c4', second.id, Grade.A, 1, Type.ACTUAL));

    await service.calculateAndUpdateGpa(first.id, 'guest');
    await service.calculateAndUpdateGpa(second.id, 'guest');
    await service.recalculateAllCumulativeGpas('guest');

    expect(service.getGpaBySemester(first.id)?.gpa, 3.5);
    expect(service.getGpaBySemester(first.id)?.cumGpa, 3.5);
    expect(service.getGpaBySemester(second.id)?.gpa, 3.0);
    expect(service.getGpaBySemester(second.id)?.cumGpa, 3.33);
    expect(service.getTerm(second.id)?.gpas.single.cumGpa, 3.33);
  });

  test('supports guest CRUD, filtering, export, and cascade helpers', () async {
    final termService = TermHiveService()..init();
    final goalService = GoalHiveService()..init();
    final courseService = CourseHiveService()..init();
    final gpaService = GpaHiveService()..init();
    final guestTerm = term('semester-crud', 2026, 1);

    expect(termService.canAddMore(), isTrue);
    expect(termService.isLimitReached(), isFalse);
    expect(termService.getRemainingSlots(), TermHiveService.maxGuestTerms);
    await service.saveTerm(guestTerm);
    expect(service.termExists(guestTerm.id), isTrue);
    expect(service.getAllTerms(), hasLength(1));
    expect(termService.getCount(), 1);
    expect(termService.exportData(), hasLength(1));
    await service.updateTerm(guestTerm.copyWith(term: 'Updated term'));
    expect(service.getTerm(guestTerm.id)?.term, 'Updated term');

    final guestGoal = GoalModel(
      id: 'goal-crud',
      name: 'Target GPA',
      targetGpa: 3.5,
      isAchieved: false,
      targetSemesterId: guestTerm.id,
      userId: 'guest',
    );
    expect(goalService.canAddMore(), isTrue);
    expect(goalService.isLimitReached(), isFalse);
    expect(goalService.getRemainingSlots(), GoalHiveService.maxGuestGoals);
    await service.saveGoal(guestGoal);
    expect(service.goalExists(guestGoal.id), isTrue);
    expect(service.getGoal(guestGoal.id)?.name, 'Target GPA');
    expect(service.getGoalsBySemester(guestTerm.id), hasLength(1));
    expect(service.getAllGoals(), hasLength(1));
    expect(goalService.getCount(), 1);
    expect(goalService.exportData(), hasLength(1));
    await service.updateGoal(guestGoal.copyWith(isAchieved: true));
    expect(service.getGoal(guestGoal.id)?.isAchieved, isTrue);

    final guestCourse = course(
      'course-crud',
      guestTerm.id,
      Grade.B_PLUS,
      3,
      Type.PLAN,
    );
    expect(courseService.canAddMore(), isTrue);
    expect(courseService.isLimitReached(), isFalse);
    expect(
      courseService.getRemainingSlots(),
      CourseHiveService.maxGuestCourses,
    );
    await service.saveCourse(guestCourse);
    expect(service.courseExists(guestCourse.id), isTrue);
    expect(service.getCourse(guestCourse.id)?.grade, Grade.B_PLUS);
    expect(service.getCoursesBySemester(guestTerm.id), hasLength(1));
    expect(service.getAllCourses(), hasLength(1));
    expect(courseService.getCount(), 1);
    expect(courseService.exportData(), hasLength(1));
    await service.updateCourse(guestCourse.copyWith(grade: Grade.A));
    expect(service.getCourse(guestCourse.id)?.grade, Grade.A);

    final guestGpa = guestTerm.gpas.single.copyWith(
      gpa: 3.5,
      cumGpa: 3.5,
      totalCredit: 3,
      totalGradePoints: 10.5,
    );
    await service.saveGpa(guestGpa);
    expect(service.getAllGpas(), hasLength(1));
    expect(service.getGpaBySemester(guestTerm.id)?.gpa, 3.5);
    expect(gpaService.getCount(), 1);
    expect(gpaService.exportData(), hasLength(1));
    await service.updateGpa(guestGpa.copyWith(gpa: 4));
    expect(service.getGpaBySemester(guestTerm.id)?.gpa, 4);

    expect(service.hasGuestData(), isTrue);
    expect(service.getTotalItemCount(), 4);
    final exported = service.exportAllData();
    expect(exported['terms'], hasLength(1));
    expect(exported['goals'], hasLength(1));
    expect(exported['courses'], hasLength(1));
    expect(exported['gpas'], hasLength(1));

    await service.deleteCoursesBySemester(guestTerm.id);
    expect(service.getCoursesBySemester(guestTerm.id), isEmpty);
    await service.deleteGoal(guestGoal.id);
    await service.deleteGpa(guestTerm.id);
    await service.deleteTerm(guestTerm.id);
    expect(service.hasGuestData(), isFalse);
  });

  test('enforces guest semester, goal, and course limits', () async {
    for (var index = 0; index < TermHiveService.maxGuestTerms; index++) {
      await service.saveTerm(term('term-$index', 2026, index + 1));
    }
    await expectLater(
      service.saveTerm(term('term-over-limit', 2027, 1)),
      throwsA(isA<SemesterLimitException>()),
    );

    for (var index = 0; index < GoalHiveService.maxGuestGoals; index++) {
      await service.saveGoal(
        GoalModel(
          id: 'goal-$index',
          name: 'Goal $index',
          targetGpa: 3.5,
          isAchieved: false,
          targetSemesterId: 'term-0',
          userId: 'guest',
        ),
      );
    }
    await expectLater(
      service.saveGoal(
        GoalModel(
          id: 'goal-over-limit',
          name: 'Extra goal',
          targetGpa: 4,
          isAchieved: false,
          targetSemesterId: 'term-0',
          userId: 'guest',
        ),
      ),
      throwsA(isA<GoalLimitException>()),
    );

    for (var index = 0; index < CourseHiveService.maxGuestCourses; index++) {
      await service.saveCourse(
        course('course-$index', 'term-0', Grade.A, 1, Type.PLAN),
      );
    }
    await expectLater(
      service.saveCourse(
        course('course-over-limit', 'term-0', Grade.A, 1, Type.ACTUAL),
      ),
      throwsA(isA<CourseLimitException>()),
    );
  });
}
