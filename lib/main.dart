import 'package:academic_planner_fe/core/routes/app_router.dart';
import 'package:academic_planner_fe/core/theme/theme_provider.dart';
import 'package:academic_planner_fe/features/auth/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:academic_planner_fe/core/theme/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final container = ProviderContainer();

  try {
    await container.read(authProvider.notifier).initAuth();
  } catch (e) {
    debugPrint('initAuth failed: $e');
  }

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    return MaterialApp.router(
      title: 'Academic Planner App',
      theme: lightMode,
      darkTheme: darkMode,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
