import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proj_inz/bloc/auth/auth_bloc.dart';
import 'package:proj_inz/presentation/widgets/custom_snack_bar.dart';
import 'package:proj_inz/presentation/widgets/dashed_separator.dart';
import 'package:proj_inz/presentation/widgets/input/buttons/custom_text_button.dart';
import 'package:proj_inz/presentation/widgets/input/buttons/google_sign_in_button.dart';
import 'package:proj_inz/presentation/widgets/input/text_fields/custom_text_field.dart';
import 'package:proj_inz/presentation/widgets/input/text_fields/labeled_text_field.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool isLogin = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // Background
          Container(decoration: const BoxDecoration(color: Color(0xFFFFEC9C))),
          BlocConsumer<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AuthSignedIn) {
                showCustomSnackBar(context, "Zalogowano pomyślnie!");
                // Navigator.of(context).pushAndRemoveUntil(
                //   MaterialPageRoute(builder: (context) => const MainScreen()),
                //   (route) => false,
                // );
              }
            },
            builder: (context, state) {
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 72, 16, 0),
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
                              context.read<AuthBloc>().add(
                                SignInRequested(
                                  email: _emailController.text.trim(),
                                  password: _passwordController.text.trim(),
                                ),
                              );
                            },
                            isLoading: state is AuthLoading,
                          )
                          : _RegistrationCard(
                            emailController: _emailController,
                            passwordController: _passwordController,
                            confirmPasswordController: _confirmPasswordController,
                            onToggle: () => setState(() => isLogin = true),
                            onSubmit: () {
                              context.read<AuthBloc>().add(
                                SignUpRequested(
                                  email: _emailController.text.trim(),
                                  password: _passwordController.text.trim(),
                                  confirmPassword:
                                      _confirmPasswordController.text.trim(),
                                ),
                              );
                            },
                            isLoading: state is AuthLoading,
                          ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _LoginCard extends StatefulWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final VoidCallback onToggle;
  final VoidCallback onSubmit;
  final bool isLoading;

  const _LoginCard({
    required this.emailController,
    required this.passwordController,
    required this.onToggle,
    required this.onSubmit,
    required this.isLoading,
  });

  @override
  State<_LoginCard> createState() => _LoginCardState();
}

class _LoginCardState extends State<_LoginCard> {
  final _formKey = GlobalKey<FormState>();
  String? _errorMessage;

  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _errorMessage = null;
      });
      widget.onSubmit();
    }
  }

  String? _emailValidator(String? value) {
    if (value == null || value.isEmpty) {
      return "E-mail jest wymagany";
    }
    final emailRegex = RegExp(r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$');
    if (!emailRegex.hasMatch(value)) {
      return "Podaj poprawny adres e-mail";
    }
    return null;
  }

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
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 18,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                spacing: 20,
                children: [
                  const Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'Witaj',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 24,
                        fontFamily: 'Itim',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  Column(
                    spacing: 8,
                    children: [
                      LabeledTextField(
                        label: "E-mail",
                        controller: widget.emailController,
                        iconOnLeft: false,
                        validator: _emailValidator,
                      ),
                      LabeledTextField(
                        label: "Hasło",
                        controller: widget.passwordController,
                        isPassword: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Hasło jest wymagane";
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                  if (_errorMessage != null)
                    Text(
                      _errorMessage!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 14,
                        fontFamily: 'Itim',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  CustomTextButton(
                    label: "Zaloguj się",
                    onTap: widget.isLoading ? () {} : _handleSubmit,
                    backgroundColor: const Color(0xFFFFC6FF),
                    isLoading: widget.isLoading,
                  ),
                  const Text(
                    'lub',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontFamily: 'Itim',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  GoogleSignInButton(onTap: () {}),
                ],
              ),
            ),
            const DashedSeparator(),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 10,
                children: [
                  const Text(
                    'Nie masz jeszcze konta?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontFamily: 'Itim',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  CustomTextButton.small(
                    label: "Zarejestruj się",
                    onTap: widget.onToggle,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void didUpdateWidget(covariant _LoginCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    final authState = context.read<AuthBloc>().state;
    if (authState is UnAuthenticated) {
      setState(() {
        _errorMessage = authState.errorMessage;
      });
    }
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
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            CustomTextField(label: "Email", controller: emailController),
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
              child:
                  isLoading
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
