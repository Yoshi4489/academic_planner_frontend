import 'package:academic_planner_fe/features/auth/providers/auth_provider.dart';
import 'package:academic_planner_fe/features/term/provider/term_detail_provider.dart';
import 'package:academic_planner_fe/features/term/provider/term_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class TermSheet extends ConsumerStatefulWidget {
  final String header;
  final String buttonLabel;

  final String? termId;
  final String? name;
  final String? year;
  final int? termNo;
  final bool? isComplete;
  const TermSheet({
    super.key,
    required this.header,
    required this.buttonLabel,
    this.termId,
    this.name,
    this.year,
    this.termNo,
    this.isComplete,
  });

  bool get isEditing => termId != null;

  @override
  ConsumerState<TermSheet> createState() => _TermSheetState();
}

class _TermSheetState extends ConsumerState<TermSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _yearController;
  late int _selectedTermNo;
  late bool _isComplete;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name ?? "");
    _yearController = TextEditingController(
      text: widget.year?.toString() ?? "",
    );
    _selectedTermNo = widget.termNo ?? 1;
    _isComplete = widget.isComplete ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLoading = ref.watch(termProvider).isLoading;

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
              Text(widget.header),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: "Term Name",
                  hintText:
                      "eg First Semester of ${DateTime.now().year.toString()}",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefix: const Icon(Icons.edit_outlined),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? "Name is required" : null,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _yearController,
                      decoration: InputDecoration(
                        labelText: "Term year",
                        hintText: "eg ${DateTime.now().year.toString()}",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefix: const Icon(Icons.calendar_month),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return "Year is required";
                        if (int.tryParse(v) == null || int.parse(v) < 1) {
                          return "Please enter a valid year";
                        }
                        return null; // Change "" to null
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField(
                      initialValue: _selectedTermNo,
                      items: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
                          .map(
                            (t) => DropdownMenuItem(
                              value: t,
                              child: Text('Term $t'),
                            ),
                          )
                          .toList(),
                      decoration: InputDecoration(
                        labelText: "Semester No.",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onChanged: (int? value) {
                        setState(() {
                          _selectedTermNo = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              SwitchListTile(
                value: _isComplete,
                onChanged: (v) => setState(() => _isComplete = v),
                title: const Text('Mark as Completed'),
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          if (!_formKey.currentState!.validate()) return;
                          if (widget.isEditing) {
                            print("Term id: ${widget.termId}");
                            await ref
                                .read(termDetailProvider.notifier)
                                .editTerm(
                                  termId: widget.termId ?? "",
                                  name: _nameController.text,
                                  year: int.parse(_yearController.text),
                                  termNo: _selectedTermNo,
                                  isComplete: _isComplete,
                                );
                          } else {
                            await ref
                                .read(termProvider.notifier)
                                .addTerm(
                                  term: _nameController.text,
                                  termNo: _selectedTermNo,
                                  isComplete: _isComplete,
                                  year: int.parse(_yearController.text),
                                );
                            GoRouter.of(context).pop();
                          }
                        },
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadiusGeometry.circular(12),
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
                      : Text(widget.buttonLabel, style: const TextStyle(color: Colors.white),),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
