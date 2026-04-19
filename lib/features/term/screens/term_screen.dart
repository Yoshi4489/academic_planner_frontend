import 'package:academic_planner_fe/core/widgets/default_app_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TermScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<TermScreen> createState() => _TermStateScreen();
}

class _TermStateScreen extends ConsumerState<TermScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DefaultAppBar(),
    );
  }
}