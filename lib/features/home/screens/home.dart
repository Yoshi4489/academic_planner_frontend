import 'package:academic_planner_fe/features/home/widgets/gpa_summary_card.dart';
import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        leading: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: CircleAvatar(
            radius: 50,
            backgroundImage: Image.asset("asset/images/default_user.jpg").image,
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Welcome Back", style: Theme.of(context).textTheme.titleMedium),
            Text("Ready to crush your goal?", style: Theme.of(context).textTheme.titleSmall,)
          ]
        )
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: GPASummaryCard(),
          )
        ],
      )
    );
  }
}
