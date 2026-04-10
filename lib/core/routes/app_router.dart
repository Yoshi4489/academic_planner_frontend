import 'package:academic_planner_fe/features/auth/screens/sign_up_screen.dart';
import 'package:academic_planner_fe/features/home/screens/home.dart';

final router = {
  '/': (context) => const Home(),
  '/login': (context) => SignUpScreen()
};