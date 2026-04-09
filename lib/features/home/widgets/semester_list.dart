import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SemesterList extends StatefulWidget {
  const SemesterList({super.key});

  @override
  State<SemesterList> createState() => _SemesterListState();
}

class _SemesterListState extends State<SemesterList> {
  final mockUpData = [
    {
      "term": "Year 1 Semester 1",
      "gpa": "4.00",
      "courses": ['1', '2', '3'],
    },
    {
      "term": "Year 1 Semester 2",
      "gpa": "3.88",
      "courses": ['1', '2'],
    },
    {
      "term": "Year 2 Semester 1",
      "gpa": "3.92",
      "courses": ['1', '2', '3', '4'],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Recent Semester", style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 20,),
        ListView.builder(
          itemCount: mockUpData.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          itemBuilder: (context, index) {
            final data = mockUpData[index];
            final courses = data['courses'] as List;
            final courseLen = courses.length;

            return TweenAnimationBuilder<double>(
              duration: Duration(milliseconds: 400 + (index * 150)),
              tween: Tween<double>(begin: 0.0, end: 1.0),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: Opacity(opacity: value, child: child),
                );
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {},
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.calendar_today_rounded,
                              color: Colors.grey.shade500,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data['term'] as String,
                                  style: GoogleFonts.roboto(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey.shade800,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "$courseLen ${courseLen > 1 ? "courses" : "course"} enrolled",
                                  style: GoogleFonts.roboto(
                                    fontSize: 14,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // GPA and Chevron
                          Row(
                            children: [
                              Text(
                                data['gpa'] as String,
                                style: GoogleFonts.roboto(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: Colors.grey.shade400,
                                size: 16,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
