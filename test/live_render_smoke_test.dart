import 'package:academic_planner_fe/core/config/app_config.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

const email = String.fromEnvironment('E2E_EMAIL');
const password = String.fromEnvironment('E2E_PASSWORD');
const hasCredentials = email != '' && password != '';

void main() {
  test(
    'dedicated account completes Render CRUD and GPA smoke flow',
    () async {
      final dio = Dio(
        BaseOptions(
          baseUrl: AppConfig.apiBaseUrl,
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
          headers: {'Content-Type': 'application/json'},
        ),
      );

      final login = await dio.post<Map<String, dynamic>>(
        '/auth/login',
        data: {'email': email, 'password': password},
      );
      final accessToken = login.data?['access_token'] as String?;
      expect(accessToken, isNotNull);
      dio.options.headers['Authorization'] = 'Bearer $accessToken';

      final existingResponse = await dio.get<Map<String, dynamic>>(
        '/semesters/getSemesters',
      );
      final existing = List<Map<String, dynamic>>.from(
        existingResponse.data?['semesters'] as List? ?? const [],
      );
      final usedSlots = existing
          .map((semester) => '${semester['year']}-${semester['term_no']}')
          .toSet();

      int? testYear;
      for (var year = 2200; year >= 2100; year--) {
        if (!usedSlots.contains('$year-11') &&
            !usedSlots.contains('$year-12')) {
          testYear = year;
          break;
        }
      }
      expect(testYear, isNotNull, reason: 'No free E2E semester slots');

      final createdSemesterIds = <String>[];
      final createdGoalIds = <String>[];

      try {
        final first = await dio.post<Map<String, dynamic>>(
          '/semesters/addSemester',
          data: {
            'term': '[E2E] GPA semester one',
            'year': testYear,
            'term_no': 11,
            'is_complete': false,
          },
        );
        final firstId = first.data?['semester']['id'] as String;
        createdSemesterIds.add(firstId);

        final second = await dio.post<Map<String, dynamic>>(
          '/semesters/addSemester',
          data: {
            'term': '[E2E] GPA semester two',
            'year': testYear,
            'term_no': 12,
            'is_complete': false,
          },
        );
        final secondId = second.data?['semester']['id'] as String;
        createdSemesterIds.add(secondId);

        Future<void> addCourse(
          String name,
          String semesterId,
          String grade,
          int credit,
          String type,
        ) async {
          await dio.post<Map<String, dynamic>>(
            '/courses/createCourse',
            data: {
              'name': '[E2E] $name',
              'grade': grade,
              'credit': credit,
              'type': type,
              'semester_id': semesterId,
              'category': 'MAJOR_REQUIRED',
            },
          );
        }

        await addCourse('A actual', firstId, 'A', 3, 'ACTUAL');
        await addCourse('B planned', firstId, 'B', 3, 'PLAN');
        await addCourse('C+ planned', secondId, 'C_PLUS', 2, 'PLAN');
        await addCourse('A actual', secondId, 'A', 1, 'ACTUAL');

        final goal = await dio.post<Map<String, dynamic>>(
          '/goals/createGoal',
          data: {
            'name': '[E2E] GPA target',
            'target_gpa': 3.5,
            'target_semester_id': secondId,
            'is_achieved': false,
          },
        );
        createdGoalIds.add(goal.data?['goal']['id'] as String);

        final firstDetails = await dio.get<Map<String, dynamic>>(
          '/semesters/getSemesterById/$firstId',
        );
        final secondDetails = await dio.get<Map<String, dynamic>>(
          '/semesters/getSemesterById/$secondId',
        );
        final firstGpa = firstDetails.data?['semester']['gpas'][0];
        final secondGpa = secondDetails.data?['semester']['gpas'][0];

        expect((firstGpa['gpa'] as num).toDouble(), 3.5);
        expect((firstGpa['cum_gpa'] as num).toDouble(), 3.5);
        expect((secondGpa['gpa'] as num).toDouble(), 3.0);
        expect((secondGpa['cum_gpa'] as num).toDouble(), 3.33);
      } finally {
        for (final goalId in createdGoalIds.reversed) {
          await dio.delete<void>('/goals/deleteGoal/$goalId');
        }
        for (final semesterId in createdSemesterIds.reversed) {
          await dio.delete<void>('/semesters/deleteSemester/$semesterId');
        }
      }
    },
    skip: hasCredentials
        ? false
        : 'Set E2E_EMAIL and E2E_PASSWORD with --dart-define to run.',
    timeout: const Timeout(Duration(minutes: 2)),
  );
}
