import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proj_inz/bloc/auth/auth_bloc.dart';
import 'package:proj_inz/presentation/screens/main_screen.dart';
import 'package:proj_inz/presentation/widgets/input/text_fields/custom_text_field.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool isLogin = true; // Toggle between login/register

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFFFFEC9C),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: BlocConsumer<AuthBloc, AuthState>(
                listener: (context, state) {
                  if (state is AuthSignedIn) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Authentication Successful!")),
                    );
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const MainScreen()),
                      (route) => false,
                    );
                  } else if (state is UnAuthenticated) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.errorMessage)),
                    );
                  }
                },
                builder: (context, state) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 64),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      spacing: 36,
                      children: [
                        const SizedBox(
                          width: 176,
                          height: 158,
                          child: Placeholder(),
                        ),
                        isLogin
                          ? _LoginCard(
                              emailController: _emailController,
                              passwordController: _passwordController,
                              onToggle: () => setState(() => isLogin = false),
                              onSubmit: () {
                                context.read<AuthBloc>().add(SignInRequested(
                                      email: _emailController.text.trim(),
                                      password: _passwordController.text.trim(),
                                    ));
                              },
                              isLoading: state is AuthLoading,
                            )
                          : _RegistrationCard(
                              emailController: _emailController,
                              passwordController: _passwordController,
                              confirmPasswordController: _confirmPasswordController,
                              onToggle: () => setState(() => isLogin = true),
                              onSubmit: () {
                                context.read<AuthBloc>().add(SignUpRequested(
                                      email: _emailController.text.trim(),
                                      password: _passwordController.text.trim(),
                                      confirmPassword: _confirmPasswordController.text.trim(),
                                    ));
                              },
                              isLoading: state is AuthLoading,
                            ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginCard extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final VoidCallback onToggle;
  final VoidCallback onSubmit;
  final bool isLoading;

  const _LoginCard({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.onToggle,
    required this.onSubmit,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 2),
          borderRadius: BorderRadius.circular(24),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0xFF000000),
            blurRadius: 0,
            offset: Offset(4, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Sign In",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            CustomTextField(
              label: "Email",
              controller: emailController,
            ),
            const SizedBox(height: 10),
            CustomTextField(
              label: "Password",
              controller: passwordController,
              isPassword: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isLoading ? null : onSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 12,
                ),
              ),
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Sign In"),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: onToggle,
              child: const Text(
                "Don't have an account? Sign Up",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RegistrationCard extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final VoidCallback onToggle;
  final VoidCallback onSubmit;
  final bool isLoading;

  const _RegistrationCard({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.onToggle,
    required this.onSubmit,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 2),
          borderRadius: BorderRadius.circular(24),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0xFF000000),
            blurRadius: 0,
            offset: Offset(4, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Sign Up",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            CustomTextField(
              label: "Email",
              controller: emailController,
            ),
            const SizedBox(height: 10),
            CustomTextField(
              label: "Password",
              controller: passwordController,
              isPassword: true,
            ),
            const SizedBox(height: 10),
            CustomTextField(
              label: "Confirm Password",
              controller: confirmPasswordController,
              isPassword: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isLoading ? null : onSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 12,
                ),
              ),
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Sign Up"),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: onToggle,
              child: const Text(
                "Already have an account? Sign In",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


