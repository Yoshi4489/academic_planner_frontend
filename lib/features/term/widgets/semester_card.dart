import 'package:flutter/material.dart';

class SemesterCard extends StatelessWidget {
  final int year;
  final String term;
  final int term_no;
  final bool is_complete;
  final List<Map<String, dynamic>> courses;
  final Map<String, dynamic> gpa;

  SemesterCard({
    super.key,
    required this.year,
    required this.term,
    required this.term_no,
    required this.is_complete,
    required this.courses,
    required this.gpa
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(Icons.calendar_month),
            Column(
              children: [
                Text(term),
                Text(
                  "${courses.isNotEmpty
                      ? courses.length > 1
                            ? "${courses.length} course"
                            : "${courses.length} courses"
                      : "0 course"} enrolled",
                ),
              ],
            ),
            Text(gpa['gpa']),
            Icon(Icons.arrow_left)
          ],
        ),
      ),
    );
  }
}
