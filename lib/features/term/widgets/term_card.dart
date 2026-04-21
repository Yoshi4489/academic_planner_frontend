import 'package:academic_planner_fe/features/term/data/course_model.dart';
import 'package:academic_planner_fe/features/term/data/gpa_model.dart';
import 'package:flutter/material.dart';

class TermCard extends StatelessWidget {
  final int year;
  final String term;
  final int termNo;
  final bool isComplete;
  final List<CourseModel> courses;
  final List<GpaModel> gpa;

  const TermCard({
    super.key,
    required this.year,
    required this.term,
    required this.termNo,
    required this.isComplete,
    required this.courses,
    required this.gpa,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shadowColor: Theme.of(context).colorScheme.tertiary,
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.calendar_month, color: Theme.of(context).colorScheme.tertiary,),
            SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Term name: $term",
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    "${courses.length} ${courses.length == 1 ? 'course' : 'courses'} enrolled",
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            SizedBox(width: 10),
            Text(gpa.isNotEmpty ? gpa[0].gpa.toString() : '-', style: Theme.of(context).textTheme.bodyMedium,),
            Icon(Icons.arrow_right, color: Theme.of(context).colorScheme.tertiary,),
          ],
        ),
      ),
    );
  }
}
