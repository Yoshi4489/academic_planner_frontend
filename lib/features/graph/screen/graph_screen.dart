import 'package:academic_planner_fe/features/goal/provider/goal_provider.dart';
import 'package:academic_planner_fe/features/term/data/term_model.dart';
import 'package:academic_planner_fe/features/term/provider/term_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GraphScreen extends ConsumerStatefulWidget {
  const GraphScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _GraphScreenState();
}

class _GraphScreenState extends ConsumerState<GraphScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(termProvider.notifier).getTemrsByUserId();
      ref.read(goalProvider.notifier).getGoalsByUserId();
    });
  }

  List<TermModel> _sortedTerms(List<TermModel> terms) {
    final sorted = [...terms];
    sorted.sort((a, b) {
      final y = a.year.compareTo(b.year);
      if (y != 0) return y;
      return a.termNo.compareTo(b.termNo);
    });
    return sorted;
  }

  List<FlSpot> _cumGpaSpots(List<TermModel> terms) {
    return [
      for (int i = 0; i < terms.length; i++)
        if (terms[i].gpas.isNotEmpty) FlSpot(i.toDouble(), terms[i].gpas.last.cumGpa),
    ];
  }

  List<FlSpot> _termGpaSpots(List<TermModel> terms) {
    return [
      for (int i = 0; i < terms.length; i++)
        if (terms[i].gpas.isNotEmpty) FlSpot(i.toDouble(), terms[i].gpas.last.gpa),
    ];
  }

  // Count grades across all courses in all terms
  Map<String, int> _gradeDistribution(List<TermModel> terms) {
    const gradeOrder = ['A', 'B_PLUS', 'B', 'C_PLUS', 'C', 'D_PLUS', 'D', 'F'];
    final map = {for (var g in gradeOrder) g: 0};
    for (final term in terms) {
      for (final course in term.courses) {
        final g = course.grade.name.toUpperCase();
        if (map.containsKey(g)) map[g] = map[g]! + 1;
      }
    }
    return map;
  }

  int _totalCredits(List<TermModel> terms) {
    return terms.fold(0, (sum, t) => sum + t.courses.fold(0, (s, c) => s + c.credit));
  }

  double _highestCumGpa(List<TermModel> terms) {
    double highest = 0;
    for (final t in terms) {
      if (t.gpas.isNotEmpty && t.gpas.last.cumGpa > highest) {
        highest = t.gpas.last.cumGpa;
      }
    }
    return highest;
  }

  double _lowestTermGpa(List<TermModel> terms) {
    double lowest = 4.0;
    for (final t in terms) {
      if (t.gpas.isNotEmpty && t.gpas.last.gpa < lowest) {
        lowest = t.gpas.last.gpa;
      }
    }
    return lowest == 4.0 ? 0.0 : lowest;
  }

  Color _gradeColor(String grade) {
    switch (grade) {
      case 'A':      return const Color(0xFF22C55E);
      case 'B_PLUS':
      case 'B':      return const Color(0xFF3B82F6);
      case 'C_PLUS':
      case 'C':      return const Color(0xFFF59E0B);
      case 'D_PLUS':
      case 'D':      return const Color(0xFFF97316);
      case 'F':      return const Color(0xFFEF4444);
      default:       return Colors.grey;
    }
  }

  String _gradeLabel(String grade) {
    return grade.replaceAll('_PLUS', '+').replaceAll('_', '');
  }

  Color _gpaColor(double gpa) {
    if (gpa >= 3.5) return const Color(0xFF22C55E);
    if (gpa >= 2.5) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final termState = ref.watch(termProvider);
    final goalState = ref.watch(goalProvider);
    final terms = _sortedTerms(termState.terms);
    final goals = goalState.goals;
    final cumSpots = _cumGpaSpots(terms);
    final termSpots = _termGpaSpots(terms);
    final hasData = cumSpots.isNotEmpty;
    final gradeMap = _gradeDistribution(terms);
    final totalCredits = _totalCredits(terms);
    final highestGpa = _highestCumGpa(terms);
    final lowestGpa = _lowestTermGpa(terms);
    final currentCumGpa = cumSpots.isNotEmpty ? cumSpots.last.y : 0.0;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ── Header ──────────────────────────────────
                Text(
                  "Analytics",
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Your academic performance at a glance.",
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.55),
                  ),
                ),
                const SizedBox(height: 20),

                // ─────────────────────────────────────────────
                // 1. BANNER
                // ─────────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.primary.withOpacity(0.75),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _BannerStat(
                        label: "Cum GPA",
                        value: currentCumGpa.toStringAsFixed(2),
                        icon: Icons.stars_rounded,
                      ),
                      _BannerDivider(),
                      _BannerStat(
                        label: "Highest",
                        value: highestGpa.toStringAsFixed(2),
                        icon: Icons.trending_up_rounded,
                      ),
                      _BannerDivider(),
                      _BannerStat(
                        label: "Lowest",
                        value: lowestGpa.toStringAsFixed(2),
                        icon: Icons.trending_down_rounded,
                      ),
                      _BannerDivider(),
                      _BannerStat(
                        label: "Credits",
                        value: totalCredits.toString(),
                        icon: Icons.auto_awesome_motion_rounded,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ─────────────────────────────────────────────
                // 2. GPA LINE CHART
                // ─────────────────────────────────────────────
                Text(
                  "GPA Over Time",
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.fromLTRB(12, 20, 16, 12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: theme.colorScheme.outline.withOpacity(0.1)),
                  ),
                  child: termState.isLoading
                      ? const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()))
                      : !hasData
                      ? const SizedBox(height: 200, child: Center(child: Text("No data yet")))
                      : Column(
                    children: [
                      Row(
                        children: [
                          _LegendDot(color: theme.colorScheme.primary, label: "Cumulative GPA"),
                          const SizedBox(width: 16),
                          _LegendDot(color: const Color(0xFFF59E0B), label: "Term GPA"),
                        ],
                      ),
                      const SizedBox(height: 12),
                      AspectRatio(
                        aspectRatio: 1.4,
                        child: LineChart(
                          LineChartData(
                            minY: 0,
                            maxY: 4.0,
                            minX: -0.2,
                            maxX: (terms.length - 1) + 0.2,
                            clipData: const FlClipData.all(),
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: false,
                              horizontalInterval: 1,
                              getDrawingHorizontalLine: (_) => FlLine(
                                color: theme.colorScheme.outline.withOpacity(0.1),
                                strokeWidth: 1,
                              ),
                            ),
                            borderData: FlBorderData(show: false),
                            titlesData: FlTitlesData(
                              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 36,
                                  interval: 1,
                                  getTitlesWidget: (value, meta) => Text(
                                    value.toStringAsFixed(1),
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                                    ),
                                  ),
                                ),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 48,
                                  interval: 1,
                                  getTitlesWidget: (value, meta) {
                                    final i = value.toInt();
                                    if (value != value.roundToDouble()) return const SizedBox.shrink();
                                    if (i < 0 || i >= terms.length) return const SizedBox.shrink();
                                    final label = terms[i].term.length > 6
                                        ? '${terms[i].term.substring(0, 6)}...'
                                        : terms[i].term;
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Transform.rotate(
                                        angle: -0.5,
                                        child: Text(
                                          label,
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: theme.colorScheme.onSurface.withOpacity(0.5),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            lineTouchData: LineTouchData(
                              touchTooltipData: LineTouchTooltipData(
                                getTooltipItems: (spots) => spots.map((spot) {
                                  final label = spot.barIndex == 0 ? 'Cum GPA' : 'Term GPA';
                                  return LineTooltipItem(
                                    '$label\n${spot.y.toStringAsFixed(2)}',
                                    TextStyle(color: spot.bar.color, fontWeight: FontWeight.bold, fontSize: 12),
                                  );
                                }).toList(),
                              ),
                            ),
                            lineBarsData: [
                              LineChartBarData(
                                spots: cumSpots,
                                isCurved: true,
                                color: theme.colorScheme.primary,
                                barWidth: 3,
                                dotData: FlDotData(
                                  show: true,
                                  getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                                    radius: 4,
                                    color: theme.colorScheme.primary,
                                    strokeWidth: 2,
                                    strokeColor: theme.colorScheme.surface,
                                  ),
                                ),
                                belowBarData: BarAreaData(
                                  show: true,
                                  color: theme.colorScheme.primary.withOpacity(0.08),
                                ),
                              ),
                              LineChartBarData(
                                spots: termSpots,
                                isCurved: true,
                                color: const Color(0xFFF59E0B),
                                barWidth: 3,
                                dashArray: [6, 4],
                                dotData: FlDotData(
                                  show: true,
                                  getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                                    radius: 4,
                                    color: const Color(0xFFF59E0B),
                                    strokeWidth: 2,
                                    strokeColor: theme.colorScheme.surface,
                                  ),
                                ),
                                belowBarData: BarAreaData(show: false),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ─────────────────────────────────────────────
                // 3. GRADE DISTRIBUTION
                // ─────────────────────────────────────────────
                Text(
                  "Grade Distribution",
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: theme.colorScheme.outline.withOpacity(0.1)),
                  ),
                  child: !hasData
                      ? const Center(child: Text("No courses yet"))
                      : Column(
                    children: gradeMap.entries
                        .where((e) => e.value > 0)
                        .map((e) {
                      final maxCount = gradeMap.values.fold(0, (a, b) => a > b ? a : b);
                      final ratio = maxCount > 0 ? e.value / maxCount : 0.0;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            // Grade label
                            SizedBox(
                              width: 36,
                              child: Text(
                                _gradeLabel(e.key),
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: _gradeColor(e.key),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Bar
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(999),
                                child: LinearProgressIndicator(
                                  value: ratio,
                                  minHeight: 10,
                                  backgroundColor: theme.colorScheme.outline.withOpacity(0.1),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    _gradeColor(e.key),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            // Count
                            SizedBox(
                              width: 28,
                              child: Text(
                                '${e.value}',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                                ),
                                textAlign: TextAlign.end,
                              ),
                            ),
                          ],
                        ),
                      );
                    })
                        .toList(),
                  ),
                ),
                const SizedBox(height: 24),

                // ─────────────────────────────────────────────
                // 4. GOAL PROGRESS
                // ─────────────────────────────────────────────
                Text(
                  "Goal Progress",
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                if (goalState.isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (goals.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: theme.colorScheme.outline.withOpacity(0.1)),
                    ),
                    child: Center(
                      child: Text(
                        "No goals yet — add one to track progress",
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                    ),
                  )
                else
                  Column(
                    children: goals.map((goal) {
                      // Find the target term's current cumGpa
                      final targetTerm = terms
                          .where((t) => t.id == goal.targetSemesterId)
                          .toList();
                      final currentGpa = targetTerm.isNotEmpty && targetTerm.first.gpas.isNotEmpty
                          ? targetTerm.first.gpas.last.cumGpa
                          : 0.0;
                      final progress = (currentGpa / goal.targetGpa).clamp(0.0, 1.0);
                      final progressColor = goal.isAchieved
                          ? const Color(0xFF22C55E)
                          : progress >= 0.75
                          ? const Color(0xFFF59E0B)
                          : theme.colorScheme.primary;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: goal.isAchieved
                                ? const Color(0xFF22C55E).withOpacity(0.3)
                                : theme.colorScheme.outline.withOpacity(0.1),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Goal name
                                Expanded(
                                  child: Text(
                                    goal.name,
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                // Status badge
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: (goal.isAchieved
                                        ? const Color(0xFF22C55E)
                                        : theme.colorScheme.primary)
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(
                                      color: (goal.isAchieved
                                          ? const Color(0xFF22C55E)
                                          : theme.colorScheme.primary)
                                          .withOpacity(0.3),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        goal.isAchieved
                                            ? Icons.check_circle_rounded
                                            : Icons.radio_button_unchecked,
                                        size: 11,
                                        color: goal.isAchieved
                                            ? const Color(0xFF22C55E)
                                            : theme.colorScheme.primary,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        goal.isAchieved ? 'Achieved' : 'In Progress',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: goal.isAchieved
                                              ? const Color(0xFF22C55E)
                                              : theme.colorScheme.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Current: ${currentGpa.toStringAsFixed(2)}",
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurface.withOpacity(0.55),
                                  ),
                                ),
                                Text(
                                  "Target: ${goal.targetGpa.toStringAsFixed(2)}",
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
                                minHeight: 8,
                                backgroundColor: theme.colorScheme.outline.withOpacity(0.1),
                                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "${(progress * 100).toStringAsFixed(0)}% complete",
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: progressColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Banner Components ─────────────────────────────────────────────
class _BannerStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _BannerStat({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.8), size: 18),
        const SizedBox(height: 6),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
        ),
      ],
    );
  }
}

class _BannerDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      width: 1,
      color: Colors.white.withOpacity(0.2),
    );
  }
}

// ── Legend Dot ────────────────────────────────────────────────────
class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }
}
