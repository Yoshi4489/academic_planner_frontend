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
    final state = ref.watch(termDetailProvider);
    final term = state.term;
    final courses = term?.courses;
    final gpa = term!.gpas[0];
    int totalCredit = 0;


    if (courses!.isNotEmpty) {
      for (var c in courses) {
        totalCredit += c.credit;
      }
    }


    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != "") {
      GoRouter.of(context).pop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Erorr: ${state.error}")));
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        leading: IconButton(
          onPressed: () {
            GoRouter.of(context).pop();
          },
          icon: Icon(Icons.arrow_back, color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                color: Theme.of(context).colorScheme.primaryContainer,
                padding: EdgeInsets.fromLTRB(20, 100, 20, 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Term header
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "SEMESTER OVERVIEW",
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                        Text(
                          term.term,
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          gpa.gpa.toString(),
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                        Text(
                          "GPA",
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Card
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            Text("Total Credits"),
                            Text("$totalCredit")
                          ],
                        ),
                        Column(
                          children: [
                            Text("Status"),
                            Text(term.isComplete.toString())
                          ],
                        )
                      ],
                    ),
                    SizedBox(height: 10,),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("GPA HISTORY"),
                        SizedBox(height: 10,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              children: [
                                Text("GPA"),
                                Text(gpa.gpa.toString())
                              ],
                            ),
                            Column(
                              children: [
                                Text("CUM GPA"),
                                Text(gpa.cumGpa.toString())
                              ],
                            )
                          ],
                        )
                      ],
                    )
                  ],
                ),
              ),
              // Course
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Curriculum"),
                        ElevatedButton(onPressed: () {}, child: Text("+ Add Course"))
                      ],
                    ),
                    SizedBox(height: 20,),
                    ...courses.map((course) {
                      return Column(
                        children: [
                          CourseCard(course: course),
                          SizedBox(height: 15,)
                        ],
                      );
                    })
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

