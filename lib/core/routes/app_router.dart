import 'package:academic_planner_fe/core/widgets/scaffold_with_bottom_navigation.dart';
import 'package:academic_planner_fe/features/auth/providers/auth_provider.dart';
import 'package:academic_planner_fe/features/auth/screens/sign_up_screen.dart';
import 'package:academic_planner_fe/features/course/screens/course_details_screen.dart';
import 'package:academic_planner_fe/features/goal/screen/goal_details_screen.dart';
import 'package:academic_planner_fe/features/goal/screen/goal_screen.dart';
import 'package:academic_planner_fe/features/graph/screen/graph_screen.dart';
import 'package:academic_planner_fe/features/home/screens/home_screen.dart';
import 'package:academic_planner_fe/features/auth/screens/sign_in_screen.dart';
import 'package:academic_planner_fe/features/setting/screens/settings_screen.dart';
import 'package:academic_planner_fe/features/term/screens/term_screen.dart';
import 'package:academic_planner_fe/features/term/screens/term_details_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final navigatorKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  navigatorKey: navigatorKey,
  initialLocation: "/",
  redirect: (context, state) {
    final authState = ProviderScope.containerOf(context).read(authProvider);
    final isLoggedIn = authState.user != null;
    final isAuthRoute =
        state.matchedLocation == '/sign-in' ||
        state.matchedLocation == '/signup';

    if (isLoggedIn && isAuthRoute) {
      return '/';
    }

    return null;
  },
  routes: [
    GoRoute(
      path: "/",
      name: "home",
      builder: (context, state) => ScaffoldWithBottomNav(child: HomeScreen()),
    ),
    GoRoute(
      path: "/signup",
      name: "sign-up",
      builder: (context, data) => SignUpScreen(),
    ),
    GoRoute(
      path: "/sign-in",
      name: "sign-in",
      builder: (context, data) => SignInScreen(),
    ),
    GoRoute(
      path: "/terms",
      name: "terms",
      builder: (context, data) => ScaffoldWithBottomNav(child: TermScreen()),
    ),
    GoRoute(
      path: "/terms/:termId",
      name: "term-details",
      builder: (context, data) {
        final termId = data.pathParameters['termId'] ?? "";
        return TermDetailsScreen(termId: termId);
      },
    ),
    GoRoute(
      path: "/course/:courseId",
      name: "course-details",
      builder: (context, data) {
        final courseId = data.pathParameters['courseId'] ?? "";
        return CourseDetailsScreen(courseId: courseId);
      },
    ),
    GoRoute(
      path: "/goals",
      name: "goals",
      builder: (context, data) {
        return ScaffoldWithBottomNav(child: GoalScreen());
      },
    ),
    GoRoute(
      path: '/goal/:goalId',
      name: "goal-details",
      builder: (context, data) {
        final goalId = data.pathParameters['goalId'] ?? "";
        return GoalDetailsScreen(goalId: goalId);
      },
    ),
    GoRoute(
      path: "/graph",
      name: "graph",
      builder: (context, data) {
        return ScaffoldWithBottomNav(child: GraphScreen());
      },
    ),
    GoRoute(
      path: "/settings",
      name: "settings",
      builder: (context, data) {
        return ScaffoldWithBottomNav(child: SettingsScreen());
      },
    ),
  ],
);
