import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SemesterList extends StatefulWidget {
  const SemesterList({ super.key });

  @override
  State<SemesterList> createState() => _SemesterListState();
}

class _SemesterListState extends State<SemesterList> {
  final mockUpData = [
    {
      "term": "Year 1 Semester 1",
      "gpa": "3.88",
      "courses": ['1', '2']
    }
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: mockUpData.length,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final courses = mockUpData[index]['courses'] as List;
        final courseLen = courses.length;

        return Card(
          child: ListTile(
            contentPadding: const EdgeInsets.all(10),
            leading: const Icon(Icons.calendar_month, size: 30,),
            title: Text(mockUpData[index]['term'] as String, style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontFamily: GoogleFonts.roboto().fontFamily,
              fontSize: 18
            )),
            subtitle: Text(
              "$courseLen ${courseLen > 1 ? "courses" : "course"} enrolled",
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontFamily: GoogleFonts.roboto().fontFamily
                )
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(mockUpData[index]['gpa'] as String, style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontFamily: GoogleFonts.roboto().fontFamily
                )),
                const SizedBox(width: 5),
                const Icon(Icons.arrow_right),
              ],
            ),
          ),
        );
      },
    );
  }
}