import 'package:academic_planner_fe/features/term/data/course_model.dart';
import 'package:flutter/material.dart';

class CourseCard extends StatelessWidget {
  final CourseModel course;
  const CourseCard({super.key, required this.course});
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.surface,
      shadowColor: Theme.of(context).colorScheme.tertiary,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(course.name, style: Theme.of(context).textTheme.headlineMedium,),
                Text("${course.credit} ${course.credit > 1 ? "credits": "credit"} · Grade Point: ${course.gradePoint}", style: Theme.of(context).textTheme.bodySmall,),
              ],
            ),
            Text(course.grade.displayName, style: Theme.of(context).textTheme.headlineMedium,)
          ],
        ),
      ),
    );
  }
}