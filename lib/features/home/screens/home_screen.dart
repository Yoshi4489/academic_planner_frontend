import 'package:academic_planner_fe/core/widgets/theme_toggle_button.dart';
import 'package:academic_planner_fe/features/auth/providers/auth_provider.dart';
import 'package:academic_planner_fe/features/home/widgets/gpa_summary_card.dart';
import 'package:academic_planner_fe/features/home/widgets/quick_actions.dart';
import 'package:academic_planner_fe/features/home/widgets/semester_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.read(authProvider);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        leading: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: CircleAvatar(
            radius: 50,
            backgroundImage: Image.asset("asset/images/default_user.jpg").image,
          ),
        ),
        actions: [ThemeToggleButton()],
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            if (user.user?.id != null)
              Text(
                "Welcome Back",
                style: Theme.of(context).textTheme.headlineMedium,
              )
            else
              Text(
                "Ready to crush your goal?",
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 18),
              ),
            InkWell(
              child: Text("Sign Up", style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).colorScheme.primary
              )),
              onTap: () {
                GoRouter.of(context).pushNamed("sign-up");
              },
            )
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: GPASummaryCard()),
            SliverToBoxAdapter(child: QuickActions()),
            SliverToBoxAdapter(child: SemesterList()),
          ],
        ),
      ),
    );
  }
}
