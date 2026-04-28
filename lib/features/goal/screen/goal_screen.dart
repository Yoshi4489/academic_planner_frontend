import 'package:academic_planner_fe/core/widgets/banner_divider.dart';
import 'package:academic_planner_fe/core/widgets/banner_state.dart';
import 'package:academic_planner_fe/core/widgets/error_state.dart';
import 'package:academic_planner_fe/features/goal/provider/goal_provider.dart';
import 'package:academic_planner_fe/features/term/data/term_model.dart';
import 'package:academic_planner_fe/features/term/provider/term_provider.dart';
import 'package:academic_planner_fe/features/term/widgets/term_card.dart';
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
      ref.read(termProvider.notifier).getTemrsByUserId();
      ref.read(goalProvider.notifier).getGoalsByUserId();
    });
  }

  double _calcAvgGpa(List<TermModel> terms) {
    if (terms.isEmpty) return 0.0;
    terms.sort((a, b) {
      final y = a.year.compareTo(b.year);
      if (y != 0) return y;
      return a.termNo.compareTo(b.termNo);
    });
    final lastTerm = terms.last;
    if (lastTerm.gpas.isEmpty) return 0.0;
    return lastTerm.gpas.last.cumGpa;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final goalState = ref.watch(goalProvider);
    final termState = ref.watch(termProvider);
    final terms = termState.terms;
    final goals = goalState.goals;
    
    final termsGoal = terms
        .where((t) => goals.any((g) => g.targetSemesterId == t.id))
        .toList();

    final isLoading = termState.isLoading || goalState.isLoading;
    final error = goalState.error;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          // ── Header ────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Goals",
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Plan your goals. Stay on track. Achieve more.",
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.55),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Banner ────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.primary.withOpacity(0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    BannerStat(
                      label: "Total Goals",
                      value: goals.length.toString(),
                      icon: Icons.flag_rounded,
                    ),
                    const BannerDivider(),
                    BannerStat(
                      label: "Avg GPA",
                      value: _calcAvgGpa(terms).toStringAsFixed(2),
                      icon: Icons.stars_rounded,
                    ),
                    const BannerDivider(),
                    BannerStat(
                      label: "Achieved",
                      value: goals.where((g) => g.isAchieved).length.toString(),
                      icon: Icons.check_circle_outline_rounded,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Content ───────────────────────────────────────
          if (isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (error != null && error.isNotEmpty)
            SliverFillRemaining(child: ErrorState(error: error))
          else if (termsGoal.isEmpty)
              const SliverFillRemaining(child: _EmptyState())
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                sliver: SliverList.separated(
                  itemCount: termsGoal.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) => TermCard(
                    term: termsGoal[index],
                    onTap: () {},
                  ),
                ),
              ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Goal', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.flag_outlined,
              size: 40,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No goals yet',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Tap "Add Goal" to start tracking your progress',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
}