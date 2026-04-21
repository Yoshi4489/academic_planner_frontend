import 'dart:math';

import 'package:academic_planner_fe/features/term/provider/term_provider.dart';
import 'package:academic_planner_fe/features/term/widgets/term_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class TermScreen extends ConsumerStatefulWidget {
  const TermScreen({super.key});

  @override
  ConsumerState<TermScreen> createState() => _TermScreenState();
}

class _TermScreenState extends ConsumerState<TermScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(termProvider.notifier).getTemrsByUserId();
    });
  }

  void _showAddTermSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _AddTermSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(termProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ─── Header ─────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Semesters',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Manage your academic journey term by term.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.55),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ─── Summary Banner ──────────────────────────────────
            if (state.terms.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  child: _SummaryBanner(
                    termCount: state.terms.length,
                    completedCount:
                    state.terms.where((t) => t.isComplete).length,
                    avgGpa: _calcAvgGpa(state),
                  ),
                ),
              ),

            // ─── Content ─────────────────────────────────────────
            if (state.isLoading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (state.error != null && state.error!.isNotEmpty)
              SliverFillRemaining(
                child: _ErrorState(error: state.error!),
              )
            else if (state.terms.isEmpty)
                const SliverFillRemaining(
                  child: _EmptyState(),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                  sliver: SliverList.separated(
                    itemCount: state.terms.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final term = state.terms[index];
                      return TermCard(
                        term: term,
                        onTap: () => GoRouter.of(context).pushNamed(
                          'term-details',
                          pathParameters: {'termId': term.id},
                        ),
                      );
                    },
                  ),
                ),
          ],
        ),
      ),
      // ✅ FAB as second entry point
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddTermSheet,
        icon: const Icon(Icons.add),
        label: const Text('Add Term'),
      ),
    );
  }

  double _calcAvgGpa(TermState state) {
    if (state.terms.isEmpty) return 0.0;

    state.terms.sort((a, b) {
      final yearComparison = a.year.compareTo(b.year);
      if (yearComparison != 0) return yearComparison;
      return a.termNo.compareTo(b.termNo);
    });

    return state.terms.last.gpas.last.cumGpa;
  }
}

// ─── Summary Banner ───────────────────────────────────────────────
class _SummaryBanner extends StatelessWidget {
  final int termCount;
  final int completedCount;
  final double avgGpa;

  const _SummaryBanner({
    required this.termCount,
    required this.completedCount,
    required this.avgGpa,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withOpacity(0.8),
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
            label: 'Total Terms',
            value: '$termCount',
            icon: Icons.calendar_today_rounded,
          ),
          _BannerDivider(),
          _BannerStat(
            label: 'Completed',
            value: '$completedCount',
            icon: Icons.check_circle_outline_rounded,
          ),
          _BannerDivider(),
          _BannerStat(
            label: 'Avg GPA',
            value: avgGpa.toStringAsFixed(2),
            icon: Icons.stars_rounded,
          ),
        ],
      ),
    );
  }
}

class _BannerStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _BannerStat({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.8), size: 18),
        const SizedBox(height: 6),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: Colors.white
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 12,
          ),
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

// ─── Empty State ──────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.school_outlined,
              size: 40,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No semesters yet',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Tap "Add Term" to start your academic journey',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Error State ──────────────────────────────────────────────────
class _ErrorState extends StatelessWidget {
  final String error;
  const _ErrorState({required this.error});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline,
              size: 48, color: Theme.of(context).colorScheme.error),
          const SizedBox(height: 12),
          Text(error, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

// ─── Add Term Bottom Sheet ────────────────────────────────────────
class _AddTermSheet extends ConsumerStatefulWidget {
  const _AddTermSheet();

  @override
  ConsumerState<_AddTermSheet> createState() => _AddTermSheetState();
}

class _AddTermSheetState extends ConsumerState<_AddTermSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String _selectedTerm = '1';
  int _selectedTermNo = 1;
  bool _isComplete = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLoading = ref.watch(termProvider).isLoading;

    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.fromLTRB(
          24, 24, 24,
          MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outline.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Add New Term',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
      
              // Term name
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Term Name',
                  hintText: 'e.g. First Semester 2025',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.edit_outlined),
                ),
                validator: (v) =>
                v == null || v.isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: 16),
      
              // Term & Term No row
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedTerm,
                      decoration: InputDecoration(
                        labelText: 'Term',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: ['1', '2', '3']
                          .map((t) => DropdownMenuItem(
                        value: t,
                        child: Text('Term $t'),
                      ))
                          .toList(),
                      onChanged: (v) => setState(() => _selectedTerm = v!),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: _selectedTermNo,
                      decoration: InputDecoration(
                        labelText: 'Semester No.',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: List.generate(8, (i) => i + 1)
                          .map((n) => DropdownMenuItem(
                        value: n,
                        child: Text('Semester $n'),
                      ))
                          .toList(),
                      onChanged: (v) => setState(() => _selectedTermNo = v!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
      
              // Is complete toggle
              SwitchListTile(
                value: _isComplete,
                onChanged: (v) => setState(() => _isComplete = v),
                title: const Text('Mark as Completed'),
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 20),
      
              // Submit button
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                    if (!_formKey.currentState!.validate()) return;
                    // TODO: wire up to termProvider.addSemester()
                    Navigator.pop(context);
                  },
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : const Text('Add Term'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}