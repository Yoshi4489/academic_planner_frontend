import 'package:academic_planner_fe/features/goal/provider/goal_details_provider.dart';
import 'package:academic_planner_fe/features/goal/provider/goal_provider.dart';
import 'package:academic_planner_fe/features/term/provider/term_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class GoalSheet extends ConsumerStatefulWidget {
  final String? goalId;
  final String header;
  final String label;
  final String? name;
  final String? targetGpa;
  final String? selectedTerm;
  final bool? isAchieved;

  const GoalSheet({
    super.key,
    this.goalId,
    required this.header,
    required this.label,
    this.name,
    this.targetGpa,
    this.selectedTerm,
    this.isAchieved,
  });

  bool get isEditing => goalId != null;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _GoalSheetState();
}

class _GoalSheetState extends ConsumerState<GoalSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _targetGpaController;
  String? _selectedTerm;
  late bool _isAchieved;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name ?? "");
    _targetGpaController = TextEditingController(text: widget.targetGpa ?? "");
    _selectedTerm = widget.selectedTerm;
    _isAchieved = widget.isAchieved ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _targetGpaController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final createNotifier = ref.read(goalProvider.notifier);
    final updateNotifier = ref.read(goalDetailsProvider.notifier);

    if (widget.isEditing) {
      await updateNotifier.editGoal(
        goalId: widget.goalId ?? "",
        name: _nameController.text,
        targetGpa: double.parse(_targetGpaController.text),
        targetSemesterId: _selectedTerm,
        isAchieved: _isAchieved,
      );
    } else {
      await createNotifier.createGoal(
        name: _nameController.text,
        targetGpa: double.parse(_targetGpaController.text),
        semesterId: _selectedTerm!,
        isAchieved: _isAchieved,
      );
    }

    if (mounted) GoRouter.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final goalState = ref.watch(goalProvider);
    final termState = ref.watch(termProvider);
    final terms = termState.terms;
    final hasNoTerms = terms.isEmpty;
    final isLoading = goalState.isLoading;

    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.fromLTRB(
          24,
          24,
          24,
          MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outline.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              widget.header,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            if (hasNoTerms) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.withOpacity(0.4)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.orange,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "No terms available",
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "You need to create a term before adding a goal.",
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.orange.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => GoRouter.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text("Go Back"),
                ),
              ),
            ] else ...[
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: "Name",
                        hintText: "eg. My first goal!",
                        prefixIcon: const Icon(Icons.flag_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (v) =>
                          v == null || v.isEmpty ? "Name is required" : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _targetGpaController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        labelText: "Target GPA",
                        hintText: "eg. 3.75",
                        prefixIcon: const Icon(Icons.my_location_rounded),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty)
                          return "Target GPA is required";
                        final parsed = double.tryParse(v);
                        if (parsed == null) return "Enter a valid number";
                        if (parsed < 0.0 || parsed > 4.0)
                          return "GPA must be between 0.00 and 4.00";
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedTerm,
                      decoration: InputDecoration(
                        labelText: "Target Semester",
                        prefixIcon: const Icon(Icons.calendar_month_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: terms
                          .map(
                            (term) => DropdownMenuItem(
                              value: term.id,
                              child: Text(term.term),
                            ),
                          )
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _selectedTerm = value),
                      validator: (v) =>
                          v == null ? "Please select a semester" : null,
                    ),
                    SwitchListTile(
                      value: _isAchieved,
                      onChanged: (v) => setState(() => _isAchieved = v),
                      title: const Text("Mark as Achieved"),
                      contentPadding: EdgeInsets.zero,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: isLoading ? null : _submit,
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
                            : Text(widget.label),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
