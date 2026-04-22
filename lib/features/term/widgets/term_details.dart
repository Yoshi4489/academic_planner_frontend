import 'package:academic_planner_fe/features/term/data/gpa_model.dart';
import 'package:academic_planner_fe/features/term/data/term_model.dart';
import 'package:academic_planner_fe/features/term/provider/term_detail_provider.dart';
import 'package:academic_planner_fe/features/term/widgets/course_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class TermDetails extends ConsumerStatefulWidget {
  final String termId;
  const TermDetails({super.key, required this.termId});

  @override
  ConsumerState<TermDetails> createState() => _TermDetailsState();
}

class _TermDetailsState extends ConsumerState<TermDetails> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(termDetailProvider.notifier).getTermById(widget.termId);
    });
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Listen for errors — never navigate/show snackbar in build()
    ref.listen(termDetailProvider, (prev, next) {
      if (next.error != null && next.error!.isNotEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${next.error}')));
        GoRouter.of(context).pop();
      }
    });

    final state = ref.watch(termDetailProvider);

    // ✅ Loading before accessing term
    if (state.isLoading || state.term == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final term = state.term!;
    final gpa = term.gpas.isNotEmpty ? term.gpas.first : null;
    final totalCredits = term.courses.fold<int>(0, (sum, c) => sum + c.credit);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          _buildHeader(context, term, gpa),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatRow(context, term, gpa, totalCredits),
                  const SizedBox(height: 24),
                  if (gpa != null) ...[
                    _buildGpaCard(context, gpa),
                    const SizedBox(height: 24),
                  ],
                  _buildCoursesSection(context, term),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Hero Header ────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context, TermModel term, GpaModel? gpa) {
    final theme = Theme.of(context);
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: theme.colorScheme.primary,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
        onPressed: () => GoRouter.of(context).pop(),
      ),
      actions: [
        PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: Colors.white),
          onSelected: (value) {
            if (value == "edit") {
              showModalBottomSheet(
                context: context,
                builder: (BuildContext context) {
                  return Column(children: [

                  ],
                );
                },
              );
            } else if (value == 'delete') {
              // show modal delete
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'edit',
              padding: EdgeInsets.all(20),
              child: Row(
                children: [
                  Icon(Icons.edit),
                  const SizedBox(width: 10),
                  Text("Edit"),
                ],
              ),
            ),
            PopupMenuDivider(),
            PopupMenuItem(
              value: "delete",
              padding: EdgeInsets.all(20),
              child: Row(
                children: [
                  Icon(Icons.delete),
                  const SizedBox(width: 10),
                  Text("Delete"),
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
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.primary,
                theme.colorScheme.primary.withOpacity(0.75),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 56, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Status badge
                  _StatusBadge(isComplete: term.isComplete),
                  const SizedBox(height: 10),
                  Text(
                    'Semester ${term.termNo} — Term ${term.term}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Academic Year ${term.year}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white.withOpacity(0.75),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─── Stat Row ────────────────────────────────────────────────────
  Widget _buildStatRow(
    BuildContext context,
    TermModel term,
    GpaModel? gpa,
    int totalCredits,
  ) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.stars_rounded,
            label: 'GPA',
            value: gpa != null ? gpa.gpa.toStringAsFixed(2) : '—',
            color: _gpaColor(gpa?.gpa ?? 0),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            icon: Icons.trending_up_rounded,
            label: 'Cum GPA',
            value: gpa != null ? gpa.cumGpa.toStringAsFixed(2) : '—',
            color: _gpaColor(gpa?.cumGpa ?? 0),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            icon: Icons.workspace_premium_rounded,
            label: 'Credits',
            value: '$totalCredits',
            color: const Color(0xFF8B5CF6),
          ),
        ),
      ],
    );
  }

  // ─── GPA Card ────────────────────────────────────────────────────
  Widget _buildGpaCard(BuildContext context, GpaModel gpa) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'GPA Summary',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _GpaProgressRow(
            label: 'Semester GPA',
            value: gpa.gpa,
            color: _gpaColor(gpa.gpa),
          ),
          const SizedBox(height: 14),
          _GpaProgressRow(
            label: 'Cumulative GPA',
            value: gpa.cumGpa,
            color: _gpaColor(gpa.cumGpa),
          ),
          const Divider(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _MiniStat(label: 'Total Credits', value: '${gpa.totalCredit}'),
              _MiniStat(
                label: 'Grade Points',
                value: '${gpa.totalGradePoints.toInt()}',
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Courses Section ─────────────────────────────────────────────
  Widget _buildCoursesSection(BuildContext context, TermModel term) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Courses',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            FilledButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
              ),
            ),
          ],
        ),
        term.courses.isEmpty
            ? _EmptyState(
                icon: Icons.book_outlined,
                message: 'No courses yet',
                subtitle: 'Tap Add to enroll in a course',
              )
            : ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: term.courses.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) =>
                    CourseCard(course: term.courses[index]),
              ),
      ],
    );
  }

  // ─── Helpers ─────────────────────────────────────────────────────
  Color _gpaColor(double gpa) {
    if (gpa >= 3.5) return const Color(0xFF22C55E);
    if (gpa >= 2.5) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }
}

// ─── Status Badge ─────────────────────────────────────────────────
class _StatusBadge extends StatelessWidget {
  final bool isComplete;
  const _StatusBadge({required this.isComplete});

  @override
  Widget build(BuildContext context) {
    final color = isComplete ? const Color(0xFF22C55E) : Colors.white;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isComplete
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked,
            size: 13,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            isComplete ? 'Completed' : 'In Progress',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

// ─── Stat Card ────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.55),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── GPA Progress Row ─────────────────────────────────────────────
class _GpaProgressRow extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const _GpaProgressRow({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
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
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: (value / 4.0).clamp(0.0, 1.0),
                  backgroundColor: color.withOpacity(0.15),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  minHeight: 7,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Text(
          value.toStringAsFixed(2),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

// ─── Mini Stat ────────────────────────────────────────────────────
class _MiniStat extends StatelessWidget {
  final String label;
  final String value;

  const _MiniStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.55),
          ),
        ),
      ],
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final String subtitle;

  const _EmptyState({
    required this.icon,
    required this.message,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 40,
            color: theme.colorScheme.onSurface.withOpacity(0.25),
          ),
          const SizedBox(height: 10),
          Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface.withOpacity(0.45),
            ),
          ),
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.3),
            ),
          ),
        ],
      ),
    );
  }
}
