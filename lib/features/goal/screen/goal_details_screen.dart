import 'package:academic_planner_fe/features/goal/provider/goal_details_provider.dart';
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(goalDetailsProvider);

    // ✅ Fix 2: navigate in listen, not in build
    ref.listen(goalDetailsProvider, (prev, next) {
      if (next.error != null && next.error!.isNotEmpty && prev?.error != next.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!)),
        );
        GoRouter.of(context).pop();
      }
    });

    if (state.isLoading || state.goal == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // ✅ Fix 3: use goal data
    final goal = state.goal!;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          // ✅ Fix 1: header is inline so it can access goal + ref
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: theme.colorScheme.primary,
            leading: IconButton(
              onPressed: () => GoRouter.of(context).pop(),
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
            ),
            actions: [
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onSelected: (v) {
                  if (v == 'edit') {
                    // show edit sheet — has access to goal here
                  } else if (v == 'delete') {
                    // show delete dialog — has access to ref here
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    padding: EdgeInsets.all(20),
                    value: "edit",
                    child: Row(children: [
                      Icon(Icons.edit),
                      SizedBox(width: 12),
                      Text("Edit"),
                    ]),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                    padding: EdgeInsets.all(20),
                    value: "delete",
                    child: Row(children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 12),
                      Text("Delete", style: TextStyle(color: Colors.red)),
                    ]),
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
                        // Status badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: (goal.isAchieved
                                ? const Color(0xFF22C55E)
                                : Colors.white)
                                .withOpacity(0.15),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: (goal.isAchieved
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
                          'Target GPA: ${goal.targetGpa.toStringAsFixed(2)}',
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

          // ── Body content goes here ─────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                "Goal details content here",
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
