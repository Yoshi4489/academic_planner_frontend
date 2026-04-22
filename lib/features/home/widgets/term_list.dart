import 'package:academic_planner_fe/features/term/provider/term_provider.dart';
import 'package:academic_planner_fe/features/term/widgets/term_card.dart';
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
    final term = state.terms;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Recent Semester", style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 20),
        ...term.map((term) {
          return Column(
            children: [
              TermCard(
                term: term,
                onTap: () => GoRouter.of(context).pushNamed(
                  'term-details',
                  pathParameters: {'termId': term.id},
                ),
              ),
              SizedBox(height: 10),
            ],
          );
        }),
      ],
    );
  }
}
