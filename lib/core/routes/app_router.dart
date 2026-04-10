import 'package:academic_planner_fe/features/auth/screens/sign_up_screen.dart';
import 'package:academic_planner_fe/features/home/screens/home_screen.dart';
import 'package:go_router/go_router.dart';

final router = GoRouter(
  initialLocation: "/",
  routes: [
    GoRoute(path: "/", builder: (context, state) => HomeScreen()),
    GoRoute(path: "/signup", builder: (context, data) => SignUpScreen()),
  ],
);