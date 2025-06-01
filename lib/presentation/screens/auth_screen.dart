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
              gradient: LinearGradient(
                colors: [Colors.blue, Colors.purple],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
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
                    // Navigate to Home Screen (Replace with your home screen)
                  } else if (state is UnAuthenticated) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.errorMessage)),
                    );
                  }
                },
                builder: (context, state) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Card UI
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 10,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                isLogin ? "Sign Up" : "Sign In",
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 20),
                              CustomTextField(
                                label: "Email",
                                controller: _emailController,
                              ),
                              const SizedBox(height: 10),
                              CustomTextField(
                                label: "Password",
                                controller: _passwordController,
                                isPassword: true,
                              ),
                              const SizedBox(height: 10),
                              if (!isLogin) ...[
                                CustomTextField(
                                  label: "Confirm Password",
                                  controller: _confirmPasswordController,
                                  isPassword: true,
                                ),
                              ],
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: state is AuthLoading
                                    ? null
                                    : () {
                                        if (isLogin) {
                                          context.read<AuthBloc>().add(SignInRequested(
                                            email: _emailController.text.trim(),
                                            password: _passwordController.text.trim(),
                                          ),
                                          );
                                        } else {
                                          context.read<AuthBloc>().add(
                                                SignUpRequested(
                                                  email: _emailController.text.trim(),
                                                  password: _passwordController.text.trim(),
                                                  confirmPassword: _confirmPasswordController.text.trim(),
                                                ),
                                              );
                                        }
                                      },
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
                                child: state is AuthLoading
                                    ? const CircularProgressIndicator(color: Colors.white)
                                    : Text(isLogin ? "Sign Up" : "Sign In"),
                              ),
                              const SizedBox(height: 10),
                              TextButton(
                                onPressed: () => setState(() => isLogin = !isLogin),  //todo in bloc
                                child: Text(
                                  isLogin ? "Don't have an account? Sign in" : "Already have an account? Sign Up",
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
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
