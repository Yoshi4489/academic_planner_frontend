import 'package:academic_planner_fe/core/services/api_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:academic_planner_fe/features/auth/providers/auth_provider.dart';

final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService(getAccessToken: () => ref.read(authProvider).accessToken);
});
