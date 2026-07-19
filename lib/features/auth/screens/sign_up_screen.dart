import 'package:academic_planner_fe/features/auth/widgets/auth_text_field.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:academic_planner_fe/features/auth/providers/auth_provider.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final passwordController = TextEditingController();
  final emailController = TextEditingController();
  final nameController = TextEditingController();

  void _showSnackBar(String message) {
    if (!mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }

  String? nameValidator(String? value) {
    if (value == null || value.isEmpty) {
      return "Name cannot be empty";
    }
    return null;
  }

  String? emailValidator(String? value) {
    if (value == null || value.isEmpty) {
      return "Email cannot be empty";
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return "Password cannot be empty";
    }

    if (value.length < 8 || value.length > 32) {
      return "Password must be between 8 and 32 characters long";
    }
    return null;
  }

  @override
  void dispose() {
    passwordController.dispose();
    emailController.dispose();
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 10,
              left: 10,
              child: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  GoRouter.of(context).pop();
                },
              ),
            ),
            Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: _formKey,
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
                          controller: nameController,
                          validator: nameValidator,
                        ),
                        const SizedBox(height: 20),
                        AuthTextField(
                          icon: Icons.email,
                          type: TextInputType.emailAddress,
                          hintText: "Enter your email",
                          label: "Email",
                          controller: emailController,
                          validator: emailValidator,
                        ),
                        const SizedBox(height: 20),
                        AuthTextField(
                          icon: Icons.lock,
                          type: TextInputType.visiblePassword,
                          hintText: "Enter your password",
                          label: "Password",
                          controller: passwordController,
                          validator: passwordValidator,
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: authState.isLoading
                                ? null
                                : () async {
                                    if (ref.read(authProvider).isLoading) {
                                      return;
                                    }

                                    if (_formKey.currentState!.validate()) {
                                      try {
                                        await ref
                                            .read(authProvider.notifier)
                                            .signUp(
                                              nameController.text,
                                              emailController.text,
                                              passwordController.text,
                                            );

                                        final state = ref.read(authProvider);
                                        if (state.error != "") {
                                          _showSnackBar(
                                            "Signup failed${state.error}",
                                          );
                                          return;
                                        }

                                        _showSnackBar(
                                          "Account created successfully!",
                                        );

                                        if (!mounted) return;
                                        GoRouter.of(context).goNamed("home");
                                      } catch (e) {
                                        _showSnackBar(
                                          "Signup failed: ${e.toString()}",
                                        );
                                      }
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.primary,
                              padding: EdgeInsets.symmetric(vertical: 15),
                              side: BorderSide.none,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                            child: Text(
                              "Sign Up",
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Already have an account? ",
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            GestureDetector(
                              onTap: () {
                                GoRouter.of(context).pushNamed("sign-in");
                              },
                              child: Text(
                                "Sign In",
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
