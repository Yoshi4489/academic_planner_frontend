import 'package:academic_planner_fe/core/widgets/stat_card.dart';
import 'package:academic_planner_fe/features/course/data/course_model.dart';
import 'package:academic_planner_fe/features/course/provider/course_details_provider.dart';
import 'package:academic_planner_fe/features/course/widgets/course_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CourseDetailsScreen extends ConsumerStatefulWidget {
  final String courseId;
  const CourseDetailsScreen({super.key, required this.courseId});

  @override
  ConsumerState<CourseDetailsScreen> createState() =>
      _CourseDetailsScreenState();
}

class _CourseDetailsScreenState extends ConsumerState<CourseDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(courseDetailsProvider.notifier)
          .findCourseById(courseId: widget.courseId);
    });
  }

  void _showEditSheet(CourseModel course) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CourseSheet(
        header: "Edit Course",
        buttonLabel: "Update",
        termId: course.semesterId,
        courseId: course.id,
        name: course.name,
        credit: course.credit,
        grade: course.grade.displayName,
        type: course.type.displayName,
        category: course.category.displayName,
      ),
    );
  }

  void _showDeleteDialog(CourseModel course) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
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
                "Delete Course",
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                "Are you sure you want to delete this course?",
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
                      child: Text(
                        "Cancel",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.tertiary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () async {
                        final router = GoRouter.of(context);
                        Navigator.of(dialogContext).pop();
                        await ref
                            .read(courseDetailsProvider.notifier)
                            .removeCourse(courseId: widget.courseId);
                        router.pop();
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
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(courseDetailsProvider, (prev, next) {
      if (next.error != null &&
          next.error!.isNotEmpty &&
          prev?.error != next.error) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${next.error}')));
        GoRouter.of(context).pop();
      }
    });

    final state = ref.watch(courseDetailsProvider);

    if (state.isLoading || state.course == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final course = state.course!;
    final theme = Theme.of(context);
    final gradeColor = _gradeColor(course.grade.displayName);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          // ── Hero Header — matches term_details ──────────────
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: theme.colorScheme.primary,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
              ),
              onPressed: () => GoRouter.of(context).pop(),
            ),
            actions: [
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onSelected: (value) {
                  if (value == 'edit') _showEditSheet(course);
                  if (value == 'delete') _showDeleteDialog(course);
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    padding: EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Icon(Icons.edit),
                        SizedBox(width: 10),
                        Text("Edit"),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                    value: 'delete',
                    padding: EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 10),
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
                        // Grade badge — matches _StatusBadge in term_details
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: gradeColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: gradeColor.withOpacity(0.5),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.grade_rounded,
                                size: 13,
                                color: gradeColor,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                course.grade.displayName.replaceAll('_', '+'),
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: gradeColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          course.name,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _HeaderChip(
                              label: course.category.displayName.replaceAll(
                                '_',
                                ' ',
                              ),
                            ),
                            const SizedBox(width: 8),
                            _HeaderChip(label: course.type.displayName),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Body ─────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Stat Row — same as term_details ──────────
                  Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          icon: Icons.stars_rounded,
                          label: "Grade Point",
                          value: course.gradePoint.toStringAsFixed(2),
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatCard(
                          icon: Icons.auto_awesome_motion_rounded,
                          label: "Credits",
                          value: '${course.credit}',
                          color: const Color(0xFFF59E0B),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatCard(
                          icon: Icons.grade_rounded,
                          label: "Grade",
                          value: course.grade.displayName.replaceAll('_', '+'),
                          color: gradeColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ── Details Card ─────────────────────────────
                  Text(
                    "Course Details",
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
                          icon: Icons.book_outlined,
                          label: "Course Name",
                          value: course.name,
                        ),
                        Divider(
                          height: 1,
                          color: theme.colorScheme.outline.withOpacity(0.1),
                        ),
                        _DetailTile(
                          icon: Icons.category_outlined,
                          label: "Category",
                          value: course.category.displayName.replaceAll(
                            '_',
                            ' ',
                          ),
                        ),
                        Divider(
                          height: 1,
                          color: theme.colorScheme.outline.withOpacity(0.1),
                        ),
                        _DetailTile(
                          icon: Icons.label_outline,
                          label: "Type",
                          value: course.type.displayName,
                        ),
                        Divider(
                          height: 1,
                          color: theme.colorScheme.outline.withOpacity(0.1),
                        ),
                        _DetailTile(
                          icon: Icons.credit_score_outlined,
                          label: "Credits",
                          value: '${course.credit} credits',
                        ),
                        Divider(
                          height: 1,
                          color: theme.colorScheme.outline.withOpacity(0.1),
                        ),
                        _DetailTile(
                          icon: Icons.grade_outlined,
                          label: "Grade",
                          value: course.grade.displayName.replaceAll('_', '+'),
                          valueColor: gradeColor,
                        ),
                        Divider(
                          height: 1,
                          color: theme.colorScheme.outline.withOpacity(0.1),
                        ),
                        _DetailTile(
                          icon: Icons.stars_outlined,
                          label: "Grade Point",
                          value: course.gradePoint.toStringAsFixed(2),
                          valueColor: theme.colorScheme.primary,
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

  Color _gradeColor(String grade) {
    switch (grade) {
      case 'A':
        return const Color(0xFF22C55E);
      case 'B_PLUS':
      case 'B':
        return const Color(0xFF3B82F6);
      case 'C_PLUS':
      case 'C':
        return const Color(0xFFF59E0B);
      case 'D_PLUS':
      case 'D':
        return const Color(0xFFF97316);
      case 'F':
        return const Color(0xFFEF4444);
      default:
        return Colors.grey;
    }
  }
}

// ── Header Chip — matches _StatusBadge style ──────────────────────
class _HeaderChip extends StatelessWidget {
  final String label;
  const _HeaderChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.titleSmall?.copyWith(color: Colors.white),
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
