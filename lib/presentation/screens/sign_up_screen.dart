import 'dart:core';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proj_inz/bloc/auth/auth_bloc.dart';
import 'package:proj_inz/core/utils/validators.dart';
import 'package:proj_inz/presentation/screens/main_screen.dart';
import 'package:proj_inz/presentation/widgets/custom_snack_bar.dart';
import 'package:proj_inz/presentation/widgets/dashed_separator.dart';
import 'package:proj_inz/presentation/widgets/input/buttons/checkbox.dart';
import 'package:proj_inz/presentation/widgets/input/buttons/custom_text_button.dart';
import 'package:proj_inz/presentation/widgets/input/text_fields/labeled_text_field.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  int _step = 1;

  void _previousStep() {
    setState(() {
      _step -= 1;
    });
  }

  void _nextStep() {
    setState(() {
      _step += 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Container(decoration: const BoxDecoration(color: Color(0xFFFFEC9C))),
          BlocConsumer<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AuthSignedIn) {
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
                      const SizedBox(
                        width: 176,
                        height: 158,
                        child: Placeholder(),
                      ),
                      switch (_step) {
                        1 => _RegistrationStepCard(isLoading: state is AuthLoading, onNext:_nextStep),
                        2 => _PhoneNumberStepCard(isLoading: state is AuthLoading, onNext: _nextStep),
                        3 => _ConfirmationCodeStep(isLoading: state is AuthLoading, onPrevious: _previousStep),
                        int() => const SizedBox.shrink(),
                      },
                      
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

class _RegistrationStepCard extends StatefulWidget {
  final bool isLoading;
  final VoidCallback onNext;

  const _RegistrationStepCard({
    required this.isLoading, required this.onNext,
  });

  @override
  State<_RegistrationStepCard> createState() => _RegistrationStepCardState();
}

class _RegistrationStepCardState extends State<_RegistrationStepCard> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _termsAccepted = false;
  bool _privacyPolicyAccepted = false;
  String? _errorMessage;

  void _handleBack() {
    Navigator.of(context).pop();
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _errorMessage = null;
      });
      context.read<AuthBloc>().add(
        SignUpRequested(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          confirmPassword: _confirmPasswordController.text.trim(),
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
                      'Zarejstruj się!',
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
                        label: "Nazwa użytkownika",
                        controller: _usernameController,
                        validator: usernameValidator,
                      ),
                      LabeledTextField(
                        label: "Hasło",
                        controller: _passwordController,
                        iconOnLeft: false,
                        isPassword: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Hasło jest wymagane";
                          }
                          return null;
                        },
                      ),
                      LabeledTextField(
                        label: "Powtórz hasło",
                        controller: _confirmPasswordController,
                        isPassword: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Powtórz hasło";
                          }
                          if (value != _confirmPasswordController.text) {
                            return "Hasła muszą być takie same!";
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      CustomCheckbox(
                        selected: _termsAccepted,
                        onTap: () {
                          setState(() {
                            _termsAccepted = !_termsAccepted;
                          });
                        },
                        label: "Regulamin",
                      ),
                      CustomCheckbox(
                        selected: _privacyPolicyAccepted,
                        onTap: () {
                          setState(() {
                            _privacyPolicyAccepted = !_privacyPolicyAccepted;
                          });
                        },
                        label: "Polityka prywatności",
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 18,
                    children: [
                      CustomTextButton(
                        label: "Wróć",
                        onTap: widget.isLoading ? () {} : _handleBack,
                        backgroundColor: const Color(0xFFEBEBEB),
                      ),
                      CustomTextButton(
                        label: "Dalej",
                        onTap:widget.isLoading
                            ? () {}
                            : _handleSubmit,
                        backgroundColor: const Color(0xFFFFC6FF),
                        isLoading: widget.isLoading,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const DashedSeparator(),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 12,
                children: [
                  CustomTextButton.small(
                    label: "Regulamin aplikacji",
                    onTap: () {},
                  ),
                  CustomTextButton.small(
                    label: "Polityka prywatności",
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhoneNumberStepCard extends StatefulWidget {
  final bool isLoading;
  final VoidCallback onNext;

  const _PhoneNumberStepCard({
    required this.isLoading, required this.onNext
  });

  @override
  State<_PhoneNumberStepCard> createState() => _PhoneNumberStepCardState();
}

class _PhoneNumberStepCardState extends State<_PhoneNumberStepCard> {
  final _formKey = GlobalKey<FormState>();
  final _phoneNumberController = TextEditingController();

  String? _errorMessage;

  void _handleSkip() {
    
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _errorMessage = null;
      });
      
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
                      'Potwierdź numer telefonu',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 24,
                        fontFamily: 'Itim',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  LabeledTextField(
                    label: "Numer telefonu",
                    controller: _phoneNumberController,
                    iconOnLeft: false,
                    validator: emailValidator,
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
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 18,
                    children: [
                      CustomTextButton(
                        label: "Pomiń",
                        onTap: widget.isLoading
                            ? () {}
                            : _handleSkip,
                        backgroundColor: const Color(0xFFEBEBEB),
                      ),
                      CustomTextButton(
                        label: "Wyślij kod",
                        onTap: widget.isLoading
                            ? () {}
                            : _handleSubmit,
                        backgroundColor: const Color(0xFFFFC6FF),
                        isLoading: widget.isLoading,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConfirmationCodeStep extends StatefulWidget {
  final bool isLoading;
  final VoidCallback onPrevious;

  const _ConfirmationCodeStep({
    required this.isLoading, required this.onPrevious
  });

  @override
  State<_ConfirmationCodeStep> createState() => _ConfirmationCodeStepState();
}

class _ConfirmationCodeStepState extends State<_ConfirmationCodeStep> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}