import 'package:academic_planner_fe/routes/app_router.dart';
import 'package:academic_planner_fe/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:academic_planner_fe/theme/theme.dart';

void main() {
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    return MaterialApp(
      title: 'Academic Planner App',
      theme: lightMode,
      darkTheme: darkMode,
      themeMode: themeMode,
      routes: router
    );
  }
}
