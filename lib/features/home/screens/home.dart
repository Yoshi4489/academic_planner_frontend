import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: AppBar(
            backgroundColor: Theme.of(context).colorScheme.surface,
            leading: CircleAvatar(
              radius: 50,
              backgroundImage: Image.asset("asset/images/default_user.jpg").image,
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Welcome Back", style: Theme.of(context).textTheme.titleMedium),
                Text("Ready to crush your goal?", style: Theme.of(context).textTheme.titleSmall,)
              ]
            )
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: [

        ],
      )
    );
  }
}
