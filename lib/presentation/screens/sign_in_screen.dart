import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proj_inz/bloc/auth/auth_bloc.dart';
import 'package:proj_inz/core/utils/validators.dart';
import 'package:proj_inz/presentation/screens/main_screen.dart';
import 'package:proj_inz/presentation/screens/sign_up_screen.dart';
import 'package:proj_inz/presentation/widgets/custom_snack_bar.dart';
import 'package:proj_inz/presentation/widgets/dashed_separator.dart';
import 'package:proj_inz/presentation/widgets/input/buttons/custom_text_button.dart';
import 'package:proj_inz/presentation/widgets/input/buttons/google_sign_in_button.dart';
import 'package:proj_inz/presentation/widgets/input/text_fields/labeled_text_field.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFEC9C),
      resizeToAvoidBottomInset: true,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSignInSuccess) {
            showCustomSnackBar(context, "Zalogowano pomyślnie!");
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const MainScreen()),
              (route) => false,
            );
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 72, 16, 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: 36,
                children: [
                  const SizedBox(width: 176, height: 158, child: Placeholder()),
                  _LoginCard(isLoading: state is AuthSignInInProgress),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _LoginCard extends StatefulWidget {
  final bool isLoading;

  const _LoginCard({
    required this.isLoading,
  });

  @override
  State<_LoginCard> createState() => _LoginCardState();
}

class _LoginCardState extends State<_LoginCard> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _errorMessage;

  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _errorMessage = null;
      });
      context.read<AuthBloc>().add(
        SignInRequested(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        ),
      );
    }
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
                      'Witaj!',
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
                        controller: _emailController,
                        iconOnLeft: false,
                        validator: emailValidator,
                      ),
                      LabeledTextField(
                        label: "Hasło",
                        controller: _passwordController,
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
            DashedSeparator(),
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
                    onTap:
                        () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const SignUpScreen(),
                          ),
                        ),
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
    if (authState is AuthSignInFailure) {
      setState(() {
        _errorMessage = authState.errorMessage;
      });
    }
  }
}
