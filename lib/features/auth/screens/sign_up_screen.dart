import 'package:academic_planner_fe/features/auth/widgets/auth_text_field.dart';
import 'package:flutter/material.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Create Account",
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                Text(
                  "Join our academia and plan your success today.",
                  style: Theme.of(
                    context,
                  ).textTheme.headlineSmall?.copyWith(fontSize: 18),
                ),
                const SizedBox(height: 40),
                AuthTextField(
                  icon: Icons.person,
                  type: TextInputType.text,
                  hintText: "Enter your name",
                  label: "Username",
                ),
                const SizedBox(height: 20),
                AuthTextField(
                  icon: Icons.email,
                  type: TextInputType.emailAddress,
                  hintText: "Enter your email",
                  label: "Email",
                ),
                const SizedBox(height: 20),
                AuthTextField(
                  icon: Icons.lock,
                  type: TextInputType.visiblePassword,
                  hintText: "Enter your password",
                  label: "Password",
                  trailing: Icons.visibility,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      padding: EdgeInsets.symmetric(vertical: 15),
                      side: BorderSide.none,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    child: Text(
                      "Sign Up",
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
