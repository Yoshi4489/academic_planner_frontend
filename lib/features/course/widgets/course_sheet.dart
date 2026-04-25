import 'package:academic_planner_fe/features/term/provider/term_detail_provider.dart';
import 'package:academic_planner_fe/features/term/provider/term_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:academic_planner_fe/features/course/provider/course_provider.dart';

class CourseSheet extends ConsumerStatefulWidget {
  final String header;
  final String buttonLabel;
  final String termId;

  final String? courseId;
  final String? name;
  final int? credit;
  final String? grade;
  final String? type;
  final String? category;

  const CourseSheet({
    super.key,
    required this.header,
    required this.buttonLabel,
    required this.termId,
    this.courseId,
    this.name,
    this.credit,
    this.grade,
    this.type,
    this.category,
  });

  bool get isEditing => courseId != null;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CourseSheetState();
}

class _CourseSheetState extends ConsumerState<CourseSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _creditController;
  String? _selectedGrade;
  String? _selectedType;
  String? _selectedCategory;

  static const _grades = [
    "A",
    "B_PLUS",
    "B",
    "C_PLUS",
    "C",
    "D_PLUS",
    "D",
    "F",
  ];
  static const _categories = [
    "GEN_ED",
    "MAJOR_REQUIRED",
    "MAJOR_ELECTIVE",
    "MINOR",
    "FREE_ELECTIVE",
  ];
  static const _types = ["ACTUAL", "PLAN"];

  String _gradeLabel(String g) =>
      g
              .replaceAll('_', '+')
              .replaceAll('PLUS', '')
              .replaceAll('  ', ' ')
              .trim() ==
          g
      ? g
      : g.replaceAll('_PLUS', '+');

  String _categoryLabel(String c) => c.replaceAll('_', ' ');

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name ?? "");
    _creditController = TextEditingController(
      text: widget.credit?.toString() ?? "",
    );
    _selectedGrade = widget.grade;
    _selectedType = widget.type;
    _selectedCategory = widget.category;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _creditController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final notifier = ref.read(courseProvider.notifier);

    if (widget.isEditing) {
      // edit here
    } else {
      await notifier.addCourse(
        semesterId: widget.termId,
        name: _nameController.text,
        credit: int.parse(_creditController.text),
        grade: _selectedGrade!,
        type: _selectedType!,
        category: _selectedCategory!,
      );
    }

    await ref.read(termProvider.notifier).getTemrsByUserId();
    await ref.read(termDetailProvider.notifier).getTermById(widget.termId);
    if (mounted) GoRouter.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLoading = ref.watch(courseProvider).isLoading;

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
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
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
              const SizedBox(height: 16),
              Text(
                widget.header,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.edit_outlined),
                  hintText: "eg. Thai Language",
                  labelText: "Course Name",
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? "Name is required" : null,
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _creditController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        labelText: "Credit",
                        hintText: "eg. 3",
                        prefixIcon: const Icon(Icons.star_outline),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return "Required";
                        if (int.tryParse(v) == null || int.parse(v) <= 0)
                          return "Must be > 0";
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedGrade,
                      decoration: InputDecoration(
                        labelText: "Grade",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: _grades
                          .map(
                            (g) => DropdownMenuItem(
                              value: g,
                              child: Text(_gradeLabel(g)),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _selectedGrade = v),
                      validator: (v) => v == null ? "Required" : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: InputDecoration(
                  labelText: "Category",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: _categories
                    .map(
                      (c) => DropdownMenuItem(
                        value: c,
                        child: Text(_categoryLabel(c)),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _selectedCategory = v),
                validator: (v) => v == null ? "Required" : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: InputDecoration(
                  labelText: "Type",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: _types
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedType = v),
                validator: (v) => v == null ? "Required" : null,
              ),
              const SizedBox(height: 24),
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
                      : Text(widget.buttonLabel),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
