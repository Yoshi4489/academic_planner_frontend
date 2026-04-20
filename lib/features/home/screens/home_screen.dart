import 'package:academic_planner_fe/features/home/widgets/gpa_summary_card.dart';
import 'package:academic_planner_fe/features/home/widgets/quick_actions.dart';
import 'package:academic_planner_fe/features/home/widgets/semester_list.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: GPASummaryCard()),
          SliverToBoxAdapter(child: QuickActions()),
          SliverToBoxAdapter(child: SemesterList()),
        ],
      ),
    );
  }
}
