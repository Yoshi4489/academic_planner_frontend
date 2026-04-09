import 'package:academic_planner_fe/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ThemeToggleButton extends ConsumerWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    return IconButton(
      onPressed: () {
        ref.watch(themeProvider.notifier).toggle();
      },
      icon: Icon(themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode),
    );
  }
}
