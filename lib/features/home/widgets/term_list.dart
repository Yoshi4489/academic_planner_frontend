import 'package:academic_planner_fe/core/widgets/error_state.dart';
import 'package:academic_planner_fe/features/term/provider/term_provider.dart';
import 'package:academic_planner_fe/features/term/widgets/term_card.dart';
import 'package:academic_planner_fe/features/term/widgets/term_skeleton_loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class TermList extends ConsumerStatefulWidget {
  const TermList({super.key});

  @override
  ConsumerState<TermList> createState() => _TermListState();
}

class _TermListState extends ConsumerState<TermList> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(termProvider.notifier).getTemrsByUserId();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(termProvider);
    final terms = state.terms;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Recent Semester", style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 20),

        if (state.isLoading)
        // ✅ shrinkWrap so ListView fits inside Column
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 5,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, __) => const TermSkeletonLoading(),
          )

        // ✅ Fix: was != which always showed error
        else if (state.error != null && state.error!.isNotEmpty)
          Center(child: ErrorState(error: state.error!))

        else if (terms.isEmpty)
            const Center(child: _EmptyState())

          else
          // ✅ shrinkWrap so ListView fits inside Column
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              // ✅ show max 5 recent terms
              itemCount: terms.length > 5 ? 5 : terms.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) => TermCard(
                term: terms[index],
                onTap: () => GoRouter.of(context).pushNamed(
                  "term-details",
                  pathParameters: {"termId": terms[index].id},
                ),
              ),
            ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.school_outlined, size: 40, color: theme.colorScheme.primary),
        ),
        const SizedBox(height: 16),
        Text(
          'No semesters yet',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}