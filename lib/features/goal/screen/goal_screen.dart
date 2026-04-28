import 'package:academic_planner_fe/core/widgets/banner_divider.dart';
import 'package:academic_planner_fe/core/widgets/banner_state.dart';
import 'package:academic_planner_fe/features/goal/provider/goal_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GoalScreen extends ConsumerStatefulWidget {
  const GoalScreen({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _GoalScreenState();
}

class _GoalScreenState extends ConsumerState<GoalScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(goalProvider.notifier).getGoalsByUserId();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Goals", style: theme.textTheme.headlineMedium),
          Text(
            "Plan your goals. Stay on track. Achieve more.",
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.55),
            ),
          ),
          SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.primary.withOpacity(0.7),
                ],
                begin: AlignmentGeometry.topLeft,
                end: AlignmentGeometry.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                BannerStat(
                  label: "Total Goals",
                  value: "2",
                  icon: Icons.eighteen_mp,
                ),
                BannerDivider(),
                BannerStat(
                  label: "AVG GPA",
                  value: "4.00",
                  icon: Icons.eighteen_mp,
                ),
                BannerDivider(),
                BannerStat(
                  label: "Next Goals",
                  value: "4.00",
                  icon: Icons.eighteen_mp,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
