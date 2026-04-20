import 'package:academic_planner_fe/features/term/provider/term_provider.dart';
import 'package:academic_planner_fe/features/term/widgets/term_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TermScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<TermScreen> createState() => _TermStateScreen();
}

class _TermStateScreen extends ConsumerState<TermScreen> {
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

    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.error!.isNotEmpty) {
      return Center(child: Text('Error: ${state.error}'));
    }

    if (state.terms.isEmpty) {
      return const Center(child: Text('No terms found.'));
    }

    return Padding(
      padding: EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          children: state.terms
              .map(
                (term) => TermCard(
                  year: term.year,
                  term: term.term,
                  termNo: term.term_no,
                  isComplete: term.is_complete,
                  courses: term.courses,
                  gpa: term.gpas,
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
