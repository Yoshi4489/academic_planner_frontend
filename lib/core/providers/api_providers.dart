import 'package:academic_planner_fe/core/services/auth_api_service.dart';
import 'package:academic_planner_fe/core/services/course_api_service.dart';
import 'package:academic_planner_fe/core/services/term_api_service.dart';
import 'package:academic_planner_fe/core/services/hive_service.dart';
import 'package:academic_planner_fe/features/auth/providers/auth_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/goal_api_service.dart';

// Hive Service Provider for local storage (guest mode)
final hiveServiceProvider = Provider<HiveService>((ref) {
  return HiveService();
});

final authenticatedDioProvider = Provider<Dio>((ref) {
  return ref.read(authApiServiceProvider).authenticatedDio;
});

final authApiServiceProvider = Provider<AuthApiService>((ref) {
  return AuthApiService(
    getAccessToken: () => ref.read(authProvider).accessToken,
  );
});

final courseApiServiceProvider = Provider<CourseApiService>((ref) {
  return CourseApiService(ref.read(authenticatedDioProvider));
});

final termApiServiceProvider = Provider<TermApiService>((ref) {
  return TermApiService(ref.read(authenticatedDioProvider));
});

final goalApiServiceProvider = Provider<GoalApiService>((ref) {
  return GoalApiService(ref.read(authenticatedDioProvider));
});
