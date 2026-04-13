import 'package:academic_planner_fe/core/widgets/default_app_bar.dart';
import 'package:academic_planner_fe/features/home/widgets/gpa_summary_card.dart';
import 'package:academic_planner_fe/features/home/widgets/quick_actions.dart';
import 'package:academic_planner_fe/features/home/widgets/semester_list.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: DefaultAppBar(),
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
