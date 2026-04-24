import 'package:academic_planner_fe/core/services/course_api_service.dart';
import 'package:academic_planner_fe/core/services/term_api_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:academic_planner_fe/features/auth/providers/auth_provider.dart';

final termApiServiceProvider = Provider<TermApiService>((ref) {
  return TermApiService(getAccessToken: () => ref.read(authProvider).accessToken);
});

final courseApiServiceProvider = Provider<CourseApiService>((ref) {
  return CourseApiService(getAccessToken: () => ref.read(authProvider).accessToken);
});
