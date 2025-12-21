import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proj_inz/bloc/auth/auth_bloc.dart';
import 'package:proj_inz/bloc/number_verification/number_verification_bloc.dart';
import 'package:proj_inz/core/theme.dart';
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSignUpSuccess) {
            showCustomSnackBar(context, "Zarejestrowano pomyślnie!");
            context.read<NumberVerificationBloc>().add(
              NumberVerificationFirstRequested(),
            );
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
                  Image.asset(
                    'assets/logo/coupidyn.png',
                    width: 200,
                    height: 200,
                    fit: BoxFit.contain,
                    ),
                  _RegistrationCard(
                    isLoading: state is AuthSignUpInProgress,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _RegistrationCard extends StatefulWidget {
  final bool isLoading;

  const _RegistrationCard({
    required this.isLoading,
  });

  @override
  State<_RegistrationCard> createState() => _RegistrationCardState();
}

class _RegistrationCardState extends State<_RegistrationCard> {
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

  void _handleSubmit() async {
    _emailController.text = _emailController.text.trim();
    _usernameController.text = _usernameController.text.trim();
    _passwordController.text = _passwordController.text.trim();
    _confirmPasswordController.text = _confirmPasswordController.text.trim();

    setState(() {
      _errorMessage = null;
    });

    if (_formKey.currentState?.validate() ?? false) {
      if (!_termsAccepted || !_privacyPolicyAccepted) {
        setState(() {
          _errorMessage =
              "Zaakceptuj regulamin aplikacji i politykę prywatności!";
        });
      }
      if (_errorMessage == null) {
        context.read<AuthBloc>().add(
          SignUpRequested(
            email: _emailController.text,
            username: _usernameController.text,
            password: _passwordController.text,
            confirmPassword: _confirmPasswordController.text,
          ),
        );
      }
    }
  }

  @override
  void didUpdateWidget(covariant _RegistrationCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthSignUpFailure) {
      setState(() {
        _errorMessage = authState.errorMessage;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: ShapeDecoration(
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 2),
          borderRadius: BorderRadius.circular(24),
        ),
        shadows: const [
          BoxShadow(
            color: AppColors.textPrimary,
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
                      'Zarejestruj się!',
                      style: TextStyle(
                        color: AppColors.textPrimary,
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
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) => emailValidator(value),
                      ),
                      LabeledTextField(
                        label: "Nazwa użytkownika",
                        controller: _usernameController,
                        validator: (value) => usernameValidator(value)
                      ),
                      LabeledTextField(
                        label: "Hasło",
                        controller: _passwordController,
                        iconOnLeft: false,
                        isPassword: true,
                        validator: (value) => signUpPasswordValidator(value),
                      ),
                      LabeledTextField(
                        label: "Powtórz hasło",
                        controller: _confirmPasswordController,
                        isPassword: true,
                        validator: (value) => signUpConfirmPasswordValidator(value, _passwordController.text.trim())
                      ),
                    ],
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
                  if (_errorMessage != null)
                    Text(
                      _errorMessage!,
                      style: const TextStyle(
                        color: AppColors.alertText,
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
                        label: "Wróć",
                        onTap: widget.isLoading ? () {} : _handleBack,
                        backgroundColor: AppColors.secondaryButton,
                      ),
                      CustomTextButton(
                        label: "Zarejestruj",
                        onTap: widget.isLoading ? () {} : _handleSubmit,
                        backgroundColor: widget.isLoading
                            ? AppColors.primaryButtonPressed
                            : AppColors.primaryButton,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            DashedSeparator(),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 4,
                children: [
                  _FooterLink(
                    label: "Regulamin aplikacji",
                    onTap: () {
                      // TODO: open regulamin
                    },
                  ),
                  const Text("•"),
                  _FooterLink(
                    label: "Polityka prywatności",
                    onTap: () {
                      // TODO: open polityka
                    },
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

class _FooterLink extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _FooterLink({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 14,
          fontFamily: 'Itim',
          fontWeight: FontWeight.w400,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}
