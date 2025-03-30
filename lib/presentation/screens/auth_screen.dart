import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proj_inz/bloc/auth/auth_bloc.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
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
                    // Navigate to Home Screen (Replace with your home screen)
                  } else if (state is UnAuthenticated) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Authentication Failed")),
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
                                isLogin ? "Login" : "Register",
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 20),
                              _buildTextField("Email", _emailController),
                              const SizedBox(height: 10),
                              _buildTextField("Password", _passwordController, isPassword: true),
                              if (!isLogin) ...[
                                const SizedBox(height: 10),
                                _buildTextField("Confirm Password", TextEditingController(), isPassword: true),
                              ],
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: state is AuthLoading
                                    ? null
                                    : () {
                                        if (isLogin) {
                                          context.read<AuthBloc>().add(SingUpRequested(
                                            email: _emailController.text.trim(),
                                            password: _passwordController.text.trim(),
                                          ),
                                          );
                                        } else {
                                          context.read<AuthBloc>().add(
                                                SingUpRequested(
                                                  email: _emailController.text.trim(),
                                                  password: _passwordController.text.trim(),
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
                                    : Text(isLogin ? "Login" : "Register"),
                              ),
                              const SizedBox(height: 10),
                              TextButton(
                                onPressed: () => setState(() => isLogin = !isLogin),
                                child: Text(
                                  isLogin ? "Don't have an account? Register" : "Already have an account? Login",
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

  Widget _buildTextField(String label, TextEditingController controller, {bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}
