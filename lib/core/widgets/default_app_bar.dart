import 'package:academic_planner_fe/core/widgets/theme_toggle_button.dart';
import 'package:academic_planner_fe/features/auth/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class DefaultAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const DefaultAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final isLoggedIn = user != null;

    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.surface,
      leading: Padding(
        padding: const EdgeInsets.only(left: 10),
        child: CircleAvatar(
          radius: 50,
          backgroundImage: Image.asset("asset/images/default_user.jpg").image,
        ),
      ),
      actions: [const ThemeToggleButton()],
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            isLoggedIn ? "Welcome Back, ${user.name}!" : "Ready to crush your goal?",
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          if (!isLoggedIn)
            InkWell(
              onTap: () => GoRouter.of(context).pushNamed("sign-up"),
              child: Text(
                "Sign Up / Sign In",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            )
          else
            Text(
              "Ready to crush your goal?",
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontSize: 14),
            ),
        ],
      ),
    );
  }
}
