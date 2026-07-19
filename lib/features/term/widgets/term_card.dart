import 'package:academic_planner_fe/features/term/data/term_model.dart';
import 'package:flutter/material.dart';

class TermCard extends StatelessWidget {
  final TermModel term;
  final VoidCallback onTap;

  const TermCard({super.key, required this.term, required this.onTap});

  Color _gpaColor(double gpa) {
    if (gpa >= 3.5) return const Color(0xFF22C55E);
    if (gpa >= 2.5) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gpa = term.gpas.isNotEmpty ? term.gpas.first.gpa : null;
    final gpaColor = gpa != null ? _gpaColor(gpa) : theme.colorScheme.outline;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: theme.colorScheme.outline.withOpacity(0.12),
          ),
        ),
        child: Row(
          children: [
            // ✅ Left icon with gradient
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.primary.withOpacity(0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  'S${term.termNo}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),

            // ✅ Center info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          'Year ${term.year} • Term ${term.term}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // ✅ Status dot
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: term.isComplete
                              ? const Color(0xFF22C55E)
                              : const Color(0xFFF59E0B),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${term.courses.length} ${term.courses.length == 1 ? 'course' : 'courses'} enrolled',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                  const SizedBox(height: 6),
                  // ✅ Mini GPA progress bar
                  if (gpa != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: (gpa / 4.0).clamp(0.0, 1.0),
                        backgroundColor: gpaColor.withOpacity(0.15),
                        valueColor: AlwaysStoppedAnimation<Color>(gpaColor),
                        minHeight: 4,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // ✅ Right GPA + arrow
            IntrinsicWidth(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    gpa != null ? gpa.toStringAsFixed(2) : '—',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: gpaColor,
                    ),
                  ),
                  Text(
                    'GPA',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right_rounded,
              color: theme.colorScheme.onSurface.withOpacity(0.3),
            ),
          ],
        ),
      ),
    );
  }
}
