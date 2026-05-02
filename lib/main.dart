import 'package:academic_planner_fe/core/routes/app_router.dart';
import 'package:academic_planner_fe/core/theme/theme_provider.dart';
import 'package:academic_planner_fe/features/auth/providers/auth_provider.dart';
import 'package:academic_planner_fe/core/services/hive_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:academic_planner_fe/core/theme/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive for local storage
  await HiveService.init();
  
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Setup Hive boxes
      HiveService().setupBoxes();
      
      // Initialize authentication
      await ref.read(authProvider.notifier).initAuth();
      
      if (mounted) setState(() => _isInitializing = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'Academic Planner App',
      theme: lightMode,
      darkTheme: darkMode,
      themeMode: themeMode,
      routerConfig: router,
      builder: (context, child) {
        if (_isInitializing) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return child!;
      },
    );
  }
}