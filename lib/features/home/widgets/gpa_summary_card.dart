import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class GPASummaryCard extends StatelessWidget {
  const GPASummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.primary,
      shadowColor: Theme.of(context).colorScheme.primary,
      elevation: 5,
      child: Container(
        padding: EdgeInsets.all(15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "CURRENT GPA",
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                FaIcon(FontAwesomeIcons.graduationCap, color: Colors.white),
              ],
            ),
            const SizedBox(height: 10,),
            Row(
              children: [
                Text(
                  "3.85",
                  style: GoogleFonts.goblinOne(
                    fontSize: 50,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  "/ 4.00",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontFamily: GoogleFonts.inriaSerif().fontFamily,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white, width: 1.1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Total Credits",
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "42",
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(
                                fontFamily: GoogleFonts.inriaSerif().fontFamily,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white, width: 1.1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Next Goals",
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "4.00",
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(
                                fontFamily: GoogleFonts.inriaSerif().fontFamily,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
