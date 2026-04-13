import 'package:academic_planner_fe/core/widgets/default_app_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SemesterScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<SemesterScreen> createState() => _SemesterStateScreen();
}

class _SemesterStateScreen extends ConsumerState<SemesterScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DefaultAppBar(),

    );
  }
}