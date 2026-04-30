import 'package:academic_planner_fe/core/widgets/stat_card.dart';
import 'package:academic_planner_fe/features/goal/data/goal_model.dart';
import 'package:academic_planner_fe/features/goal/provider/goal_details_provider.dart';
import 'package:academic_planner_fe/features/goal/provider/goal_provider.dart';
import 'package:academic_planner_fe/features/goal/widgets/goal_sheet.dart';
import 'package:academic_planner_fe/features/term/data/term_model.dart';
import 'package:academic_planner_fe/features/term/provider/term_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class GoalDetailsScreen extends ConsumerStatefulWidget {
  final String goalId;
  const GoalDetailsScreen({super.key, required this.goalId});

  @override
  ConsumerState<GoalDetailsScreen> createState() => _GoalDetailScreenState();
}

class _GoalDetailScreenState extends ConsumerState<GoalDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(goalDetailsProvider.notifier).getGoalById(goalId: widget.goalId);
    });
  }

  Color _gpaColor(double gpa) {
    if (gpa >= 3.5) return const Color(0xFF22C55E);
    if (gpa >= 2.5) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  void _showEditSheet(GoalModel goal) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => GoalSheet(
        header: "Edit Goal",
        label: "Update",
        goalId: goal.id,
        name: goal.name,
        targetGpa: goal.targetGpa.toString(),
        selectedTerm: goal.targetSemesterId,
        isAchieved: goal.isAchieved,
      ),
    );
  }

  void _showDeleteDialog(GoalModel goal) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.redAccent.shade200.withOpacity(0.15),
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Icon(
                Icons.warning_rounded,
                color: Colors.red,
                size: 36,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Delete Goal",
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "Are you sure you want to delete \"${goal.name}\"?",
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            Text(
              "This action cannot be undone.",
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text("Cancel"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () async {
                      Navigator.of(dialogContext).pop();
                      await ref
                          .read(goalDetailsProvider.notifier)
                          .removeGoal(goalId: goal.id);
                      await ref
                          .read(goalProvider.notifier)
                          .getGoalsByUserId();
                      GoRouter.of(context).pop();
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Delete",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(goalDetailsProvider);

    ref.listen(goalDetailsProvider, (prev, next) {
      if (next.error != null &&
          next.error!.isNotEmpty &&
          prev?.error != next.error) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.error!)));
        GoRouter.of(context).pop();
      }
    });

    if (state.isLoading || state.goal == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final goal = state.goal!;
    final terms = ref.watch(termProvider).terms;

    // Safely find the term
    final termMatches = terms
        .where((t) => t.id == goal.targetSemesterId)
        .toList();
    final goalTerm = termMatches.isNotEmpty ? termMatches.first : null;
    final currentGpa = goalTerm != null && goalTerm.gpas.isNotEmpty
        ? goalTerm.gpas.last.gpa
        : 0.0;
    final progress = (currentGpa / goal.targetGpa).clamp(0.0, 1.0);
    final progressColor = goal.isAchieved
        ? const Color(0xFF22C55E)
        : progress >= 0.75
        ? const Color(0xFFF59E0B)
        : theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          // ── App Bar ───────────────────────────────────────
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: theme.colorScheme.primary,
            leading: IconButton(
              onPressed: () => GoRouter.of(context).pop(),
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
              ),
            ),
            actions: [
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onSelected: (v) {
                  if (v == 'edit') _showEditSheet(goal);
                  if (v == 'delete') _showDeleteDialog(goal);
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    padding: EdgeInsets.all(20),
                    value: "edit",
                    child: Row(
                      children: [
                        Icon(Icons.edit),
                        SizedBox(width: 12),
                        Text("Edit"),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                    padding: EdgeInsets.all(20),
                    value: "delete",
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 12),
                        Text("Delete", style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.primary.withOpacity(0.75),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 48, 20, 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color:
                                (goal.isAchieved
                                        ? const Color(0xFF22C55E)
                                        : Colors.white)
                                    .withOpacity(0.15),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color:
                                  (goal.isAchieved
                                          ? const Color(0xFF22C55E)
                                          : Colors.white)
                                      .withOpacity(0.5),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                goal.isAchieved
                                    ? Icons.check_circle_rounded
                                    : Icons.radio_button_unchecked,
                                size: 13,
                                color: goal.isAchieved
                                    ? const Color(0xFF22C55E)
                                    : Colors.white,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                goal.isAchieved ? 'Achieved' : 'In Progress',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: goal.isAchieved
                                      ? const Color(0xFF22C55E)
                                      : Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          goal.name,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          goalTerm != null
                              ? goalTerm.term
                              : 'No semester linked',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Stat Row ──────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          icon: Icons.my_location_rounded,
                          label: "Target GPA",
                          value: goal.targetGpa.toStringAsFixed(2),
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatCard(
                          icon: Icons.stars_rounded,
                          label: "Current GPA",
                          value: currentGpa.toStringAsFixed(2),
                          color: _gpaColor(currentGpa),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatCard(
                          icon: Icons.trending_up_rounded,
                          label: "Remaining",
                          value:
                              "+${(goal.targetGpa - currentGpa).clamp(0.0, 4.0).toStringAsFixed(2)}",
                          color: goal.isAchieved
                              ? const Color(0xFF22C55E)
                              : const Color(0xFFEF4444),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ── Progress Card ─────────────────────────
                  Text(
                    "GPA Progress",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest
                          .withOpacity(0.5),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: theme.colorScheme.outline.withOpacity(0.1),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Current: ${currentGpa.toStringAsFixed(2)}",
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(
                                  0.55,
                                ),
                              ),
                            ),
                            Text(
                              "Goal: ${goal.targetGpa.toStringAsFixed(2)}",
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(
                                  0.55,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 10,
                            backgroundColor: theme.colorScheme.primary
                                .withOpacity(0.15),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              progressColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Center(
                          child: Text(
                            "${(progress * 100).toStringAsFixed(0)}% towards your goal",
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: progressColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Details Card ──────────────────────────
                  Text(
                    "Goal Details",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest
                          .withOpacity(0.5),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: theme.colorScheme.outline.withOpacity(0.1),
                      ),
                    ),
                    child: Column(
                      children: [
                        _DetailTile(
                          icon: Icons.flag_outlined,
                          label: "Goal Name",
                          value: goal.name,
                        ),
                        Divider(
                          height: 1,
                          color: theme.colorScheme.outline.withOpacity(0.1),
                        ),
                        _DetailTile(
                          icon: Icons.my_location_rounded,
                          label: "Target GPA",
                          value: goal.targetGpa.toStringAsFixed(2),
                          valueColor: theme.colorScheme.primary,
                        ),
                        Divider(
                          height: 1,
                          color: theme.colorScheme.outline.withOpacity(0.1),
                        ),
                        _DetailTile(
                          icon: Icons.calendar_month_outlined,
                          label: "Target Semester",
                          value: goalTerm?.term ?? 'Not linked',
                        ),
                        Divider(
                          height: 1,
                          color: theme.colorScheme.outline.withOpacity(0.1),
                        ),
                        _DetailTile(
                          icon: Icons.school_outlined,
                          label: "Semester No.",
                          value: goalTerm != null
                              ? 'Semester ${goalTerm.termNo}'
                              : '-',
                        ),
                        Divider(
                          height: 1,
                          color: theme.colorScheme.outline.withOpacity(0.1),
                        ),
                        _DetailTile(
                          icon: Icons.check_circle_outline_rounded,
                          label: "Status",
                          value: goal.isAchieved ? "Achieved ✓" : "In Progress",
                          valueColor: goal.isAchieved
                              ? const Color(0xFF22C55E)
                              : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Detail Tile ───────────────────────────────────────────────────
class _DetailTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailTile({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 18,
              color: theme.colorScheme.onSurface.withOpacity(0.55),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.55),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: valueColor ?? theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
