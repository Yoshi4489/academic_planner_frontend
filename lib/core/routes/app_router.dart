import 'package:academic_planner_fe/features/auth/screens/sign_up_screen.dart';
import 'package:academic_planner_fe/features/home/screens/home_screen.dart';
import 'package:academic_planner_fe/features/auth/screens/sign_in_screen.dart';
import 'package:go_router/go_router.dart';

final router = GoRouter(
  initialLocation: "/",
  routes: [
    GoRoute(path: "/", name: "home", builder: (context, state) => HomeScreen()),
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
  ],
);
