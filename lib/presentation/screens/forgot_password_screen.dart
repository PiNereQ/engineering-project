import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:proj_inz/bloc/auth/auth_bloc.dart';
import 'package:proj_inz/core/theme.dart';
import 'package:proj_inz/core/utils/validators.dart';
import 'package:proj_inz/presentation/widgets/custom_snack_bar.dart';
import 'package:proj_inz/presentation/widgets/input/buttons/custom_icon_button.dart';
import 'package:proj_inz/presentation/widgets/input/buttons/custom_text_button.dart';
import 'package:proj_inz/presentation/widgets/input/text_fields/labeled_text_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() {
      _errorMessage = null;
    });

    context.read<AuthBloc>().add(
          PasswordResetRequested(email: _emailController.text.trim()),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthPasswordResetSuccess) {
            showCustomSnackBar(
              context,
              'Wysłano e-mail z linkiem do resetowania hasła.',
            );
            Navigator.of(context).pop();
          } else if (state is AuthPasswordResetFailure) {
            setState(() {
              _errorMessage = state.errorMessage;
            });
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthPasswordResetInProgress;

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Container(
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
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        spacing: 20,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CustomIconButton.small(
                                icon: SvgPicture.asset('assets/icons/back.svg'),
                                onTap: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                              Expanded(
                                child: const Text(
                                  'Odzyskaj dostęp',
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 24,
                                    fontFamily: 'Itim',
                                    fontWeight: FontWeight.w400,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                          const Text(
                            'Podaj adres e-mail powiązany z Twoim kontem. Jeśli podany adres będzie prawidłowy, wyślemy Ci wiadomość z linkiem do zresetowania hasła.',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontFamily: 'Itim',
                              fontWeight: FontWeight.w400,
                            ),
                            textAlign: TextAlign.justify,
                          ),
                          LabeledTextField(
                            label: 'E-mail',
                            controller: _emailController,
                            iconOnLeft: false,
                            validator: emailValidator,
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
                          CustomTextButton(
                            label: 'Wyślij link resetujący',
                            onTap: isLoading ? () {} : _handleSubmit,
                            backgroundColor: AppColors.primaryButton,
                            isLoading: isLoading,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
