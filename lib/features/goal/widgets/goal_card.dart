import 'package:flutter/material.dart';

class GoalCard extends StatelessWidget {
  final String goalName;
  final String termName;
  final String termNo;
  final double targetGpa;
  final double currentGpa;
  final bool isAchieved;
  final VoidCallback? onTap;

  const GoalCard({
    super.key,
    required this.goalName,
    required this.termName,
    required this.termNo,
    required this.targetGpa,
    required this.currentGpa,
    required this.isAchieved,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = (currentGpa / targetGpa).clamp(0.0, 1.0);
    final progressColor = isAchieved
        ? const Color(0xFF22C55E)
        : progress >= 0.75
        ? const Color(0xFFF59E0B)
        : theme.colorScheme.primary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isAchieved
                ? const Color(0xFF22C55E).withOpacity(0.3)
                : theme.colorScheme.outline.withOpacity(0.12),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // ── Term Badge ──────────────────────────────
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isAchieved
                          ? [const Color(0xFF22C55E), const Color(0xFF16A34A)]
                          : [
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
                      'S$termNo',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // ── Goal Name + Term Name ────────────────────
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goalName,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        termName,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // ── isAchieved badge ─────────────────────────
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isAchieved
                        ? const Color(0xFF22C55E).withOpacity(0.12)
                        : theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: isAchieved
                          ? const Color(0xFF22C55E).withOpacity(0.4)
                          : theme.colorScheme.primary.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isAchieved
                            ? Icons.check_circle_rounded
                            : Icons.radio_button_unchecked,
                        size: 12,
                        color: isAchieved
                            ? const Color(0xFF22C55E)
                            : theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isAchieved ? 'Achieved' : 'In Progress',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isAchieved
                              ? const Color(0xFF22C55E)
                              : theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Progress Bar ────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'GPA Progress',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.5),
                            ),
                          ),
                          Text(
                            '${currentGpa.toStringAsFixed(2)} / ${targetGpa.toStringAsFixed(2)}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: progressColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 6,
                          backgroundColor: theme.colorScheme.outline.withOpacity(0.15),
                          valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: theme.colorScheme.onSurface.withOpacity(0.3),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}