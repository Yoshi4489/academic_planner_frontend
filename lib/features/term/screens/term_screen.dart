import 'package:academic_planner_fe/core/widgets/banner_divider.dart';
import 'package:academic_planner_fe/core/widgets/banner_state.dart';
import 'package:academic_planner_fe/core/widgets/error_state.dart';
import 'package:academic_planner_fe/features/term/provider/term_provider.dart';
import 'package:academic_planner_fe/features/term/widgets/term_card.dart';
import 'package:academic_planner_fe/features/term/widgets/term_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class TermScreen extends ConsumerStatefulWidget {
  const TermScreen({super.key});

  @override
  ConsumerState<TermScreen> createState() => _TermScreenState();
}

class _TermScreenState extends ConsumerState<TermScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(termProvider.notifier).getTemrsByUserId();
    });
  }

  void _showAddTermSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          const TermSheet(header: "Add new term", buttonLabel: "Add Term"),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(termProvider, (prev, next) {
      if (next.error != "" && prev?.error != next.error) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.error ?? "Unknown error")));
      }
    });

    final state = ref.watch(termProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ─── Header ─────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Semesters',
                      style: theme.textTheme.headlineMedium
                    ),
                    Text(
                      'Manage your academic journey term by term.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.55),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ─── Summary Banner ──────────────────────────────────
            if (state.terms.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  child: _SummaryBanner(
                    termCount: state.terms.length,
                    completedCount: state.terms
                        .where((t) => t.isComplete)
                        .length,
                    avgGpa: _calcAvgGpa(state),
                  ),
                ),
              ),

            // ─── Content ─────────────────────────────────────────
            if (state.isLoading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (state.error != "" && state.error!.isNotEmpty)
              SliverFillRemaining(child: ErrorState(error: state.error!))
            else if (state.terms.isEmpty)
              const SliverFillRemaining(child: _EmptyState())
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                sliver: SliverList.separated(
                  itemCount: state.terms.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final term = state.terms[index];
                    return TermCard(
                      term: term,
                      onTap: () => GoRouter.of(context).pushNamed(
                        'term-details',
                        pathParameters: {'termId': term.id},
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
      // ✅ FAB as second entry point
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddTermSheet,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Term', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  double _calcAvgGpa(TermState state) {
    if (state.terms.isEmpty) return 0.0;

    state.terms.sort((a, b) {
      final yearComparison = a.year.compareTo(b.year);
      if (yearComparison != 0) return yearComparison;
      return a.termNo.compareTo(b.termNo);
    });

    final lastTerm = state.terms.last;

    if (lastTerm.gpas.isEmpty) return 0.0;

    return lastTerm.gpas.last.cumGpa;
  }
}

// ─── Summary Banner ───────────────────────────────────────────────
class _SummaryBanner extends StatelessWidget {
  final int termCount;
  final int completedCount;
  final double avgGpa;

  const _SummaryBanner({
    required this.termCount,
    required this.completedCount,
    required this.avgGpa,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          BannerStat(
            label: 'Total Terms',
            value: '$termCount',
            icon: Icons.calendar_today_rounded,
          ),
          BannerDivider(),
          BannerStat(
            label: 'Completed',
            value: '$completedCount',
            icon: Icons.check_circle_outline_rounded,
          ),
          BannerDivider(),
          BannerStat(
            label: 'Avg GPA',
            value: avgGpa.toStringAsFixed(2),
            icon: Icons.stars_rounded,
          ),
        ],
      ),
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────
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
              Icons.school_outlined,
              size: 40,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No semesters yet',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Tap "Add Term" to start your academic journey',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
}
