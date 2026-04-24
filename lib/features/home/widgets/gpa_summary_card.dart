import 'package:academic_planner_fe/features/term/provider/term_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class GPASummaryCard extends ConsumerStatefulWidget {
  const GPASummaryCard({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _GPASummaryCardState();
}

class _GPASummaryCardState extends ConsumerState<GPASummaryCard> {
  int totalCredits = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(termProvider.notifier).getTemrsByUserId();
    });
  }

  double _calcAvgGpa(TermState state) {
    if (state.terms.isEmpty) return 0.0;

    final termWithGpa = state.terms.where((t) => t.gpas.isNotEmpty).toList();

    termWithGpa.sort((a, b) {
      final yearComparison = a.year.compareTo(b.year);
      if (yearComparison != 0) return yearComparison;
      return a.termNo.compareTo(b.termNo);
    });

    return termWithGpa.last.gpas.last.cumGpa;
  }

  int _calTotalCredits(TermState state) {
    int totalCredits = 0;
    if (state.terms.isEmpty) return totalCredits;

    for (var t in state.terms) {
      if (t.gpas.isEmpty) continue;
      totalCredits += t.gpas[0].totalCredit;
    }
    return totalCredits;
  }

  @override
  Widget build(BuildContext context) {
    final term = ref.watch(termProvider);
    return Card(
      color: Theme.of(context).colorScheme.primary,
      shadowColor: Theme.of(context).colorScheme.primary.withOpacity(0.4),
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "CURRENT GPA",
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Colors.white.withOpacity(0.8),
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const FaIcon(
                  FontAwesomeIcons.graduationCap,
                  color: Colors.white,
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  "${_calcAvgGpa(term)}",
                  style: GoogleFonts.goblinOne(
                    fontSize: 48,
                    color: Colors.white,
                    height: 1.1,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  "/ 4.00",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontFamily: GoogleFonts.inriaSerif().fontFamily,
                    color: Colors.white.withOpacity(0.7),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Total Credits",
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: Colors.white.withOpacity(0.8),
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _calTotalCredits(term).toString(),
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontFamily: GoogleFonts.inriaSerif().fontFamily,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(
                        0.15,
                      ), // Lighter translucent background
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3), // Softer border
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Next Goals",
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: Colors.white.withOpacity(0.8),
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "4.00",
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontFamily: GoogleFonts.inriaSerif().fontFamily,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
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
