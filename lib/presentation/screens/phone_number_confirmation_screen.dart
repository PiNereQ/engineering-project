import 'dart:core';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proj_inz/bloc/number_verification/number_verification_bloc.dart';
import 'package:proj_inz/core/theme.dart';
import 'package:proj_inz/core/utils/validators.dart';
import 'package:proj_inz/presentation/widgets/custom_snack_bar.dart';
import 'package:proj_inz/presentation/widgets/dashed_separator.dart';
import 'package:proj_inz/presentation/widgets/input/buttons/custom_text_button.dart';
import 'package:proj_inz/presentation/widgets/input/text_fields/labeled_text_field.dart';

class PhoneNumberConfirmationScreen extends StatefulWidget {
  const PhoneNumberConfirmationScreen({
    super.key
  });

  @override
  State<PhoneNumberConfirmationScreen> createState() => _PhoneNumberConfirmationScreenState();
}

class _PhoneNumberConfirmationScreenState extends State<PhoneNumberConfirmationScreen> {
  bool _isDuringRegistration = false;

  @override
  Widget build(BuildContext context) {
    BlocListener<NumberVerificationBloc, NumberVerificationState>(
      listener: (context, state) {
        if (state is NumberVerificationDuringRegistrationInitial) {
          setState(() {
            _isDuringRegistration = true;
          });
        }
      }
    );

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Container(decoration: const BoxDecoration(color: AppColors.background)),
          BlocConsumer<NumberVerificationBloc, NumberVerificationState>(
            listener: (context, state) {
              
              if (state is NumberVerificationSuccess) {
                showCustomSnackBar(context, "Numer telefonu został przypisany do konta!");
                Navigator.of(context).pop();
              }

              if (state is NumberVerificationSkipped) {
                  Navigator.of(context).pop();
              }
            },
            builder: (context, state) {
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 72, 16, 24),
                  child: Center(
                    child: (state is NumberVerificationDuringRegistrationInitial ||
                            state is NumberVerificationAfterRegistrationInitial ||
                            state is NumberSubmitInProgress ||
                            state is NumberSubmitFailure)
                            ? _PhoneNumberStepCard(
                              isLoading: state is NumberSubmitInProgress,
                              isDuringRegistration: _isDuringRegistration,
                              initialPhoneNumber:
                                  (state
                                          is NumberVerificationDuringRegistrationInitial)
                                      ? state.phoneNumber
                                      : (state
                                          is NumberVerificationAfterRegistrationInitial)
                                      ? state.phoneNumber
                                      : null,
                              errorMessage: state is NumberSubmitFailure ? state.message : null,
                            )
                            : _ConfirmationCodeStep(
                              isLoading: state is NumberVerificationInProgress,
                              isDuringRegistration: _isDuringRegistration,
                            ),
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

class _PhoneNumberStepCard extends StatefulWidget {
  final bool isLoading;
  final bool isDuringRegistration;
  final String? initialPhoneNumber;
  final String? errorMessage;

  const _PhoneNumberStepCard({
    required this.isLoading,
    required this.isDuringRegistration,
    this.initialPhoneNumber,
    this.errorMessage,
  });

  @override
  State<_PhoneNumberStepCard> createState() => _PhoneNumberStepCardState();
}

class _PhoneNumberStepCardState extends State<_PhoneNumberStepCard> {

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _phoneNumberController;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _phoneNumberController = TextEditingController(text: widget.initialPhoneNumber ?? '');
    _errorMessage = widget.errorMessage;
  }

  @override
  void didUpdateWidget(covariant _PhoneNumberStepCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.errorMessage != oldWidget.errorMessage) {
      setState(() {
        _errorMessage = widget.errorMessage;
      });
    }
  }

  void _handleSkip() {
    if (kDebugMode) print('_handleSkip called');
    context.read<NumberVerificationBloc>().add(
      NumberVerificationSkipRequested(),
    );
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _errorMessage = null;
      });
      context.read<NumberVerificationBloc>().add(
        NumberVerificationRequested(
          number: _phoneNumberController.text.replaceAll(' ', '').trim(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textAfterRegistration = 'Abyś mogła/mógł kupować i sprzedawać kupony potrzebujemy od Ciebie numer telefonu w celach weryfikacji. \n\n Podaj go, a prześlemy Tobie SMSem kod. Numer telefonu zostanie przypisany do konta. ';
    final textDuringRegistration = 'Abyś mogła/mógł kupować i sprzedawać kupony potrzebujemy od Ciebie numer telefonu w celach weryfikacji. Możesz na razie pominąć ten krok.\n\n Podaj go, a prześlemy Tobie SMSem kod. Numer telefonu zostanie przypisany do konta. ';
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
                      'Potwierdź numer telefonu',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 24,
                        fontFamily: 'Itim',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  Text(
                    widget.isDuringRegistration
                        ? textDuringRegistration
                        : textAfterRegistration,
                    textAlign: TextAlign.justify,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontFamily: 'Itim',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  LabeledTextField(
                    label: "Numer telefonu",
                    controller: _phoneNumberController,
                    iconOnLeft: false,
                    keyboardType: TextInputType.phone,
                    validator: phoneNumberValidator,
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
                        label: widget.isDuringRegistration ? "Pomiń" : "Anuluj",
                        onTap: _handleSkip,
                        backgroundColor: AppColors.secondaryButton,
                      ),
                      CustomTextButton(
                        label: "Wyślij kod",
                        onTap: widget.isLoading ? () {} : _handleSubmit,
                        backgroundColor: AppColors.primaryButton,
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
  // Add timer logic for resend button
  final bool isLoading;
  final bool isDuringRegistration;

  const _ConfirmationCodeStep({
    required this.isLoading, required this.isDuringRegistration
  });

  @override
  State<_ConfirmationCodeStep> createState() => _ConfirmationCodeStepState();
}

class _ConfirmationCodeStepState extends State<_ConfirmationCodeStep> {
    int _secondsLeft = 0;
    Timer? _timer;

    @override
    void initState() {
      super.initState();
      _startResendTimer();
    }

    @override
    void dispose() {
      _timer?.cancel();
      super.dispose();
    }

    void _startResendTimer() {
      setState(() {
        _secondsLeft = 30;
      });
      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_secondsLeft > 0) {
          setState(() {
            _secondsLeft--;
          });
        } else {
          timer.cancel();
        }
      });
    }

    void _handleResend() {
      final state = context.read<NumberVerificationBloc>().state;
      if (state is NumberSubmitSuccess) {
        context.read<NumberVerificationBloc>().add(
          ResendCodeRequested(
            phoneNumber: state.phoneNumber,
            resendToken: state.resendToken,
          ),
        );
        _startResendTimer();
      }
    }
  final _formKey = GlobalKey<FormState>();
  final _verificationCodeController = TextEditingController();
  String? _errorMessage;

  void _handleBack() {
    if (widget.isDuringRegistration) {
      context.read<NumberVerificationBloc>().add(
        NumberVerificationFormShownDuringRegistration(phoneNumber: (context.read<NumberVerificationBloc>().state as NumberSubmitSuccess).phoneNumber),
      );
    } else {
      context.read<NumberVerificationBloc>().add(
        NumberVerificationFormShownAfterRegistration(phoneNumber: (context.read<NumberVerificationBloc>().state as NumberSubmitSuccess).phoneNumber),
      );
    }
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _errorMessage = null;
      });

      context.read<NumberVerificationBloc>().add(
        ConfirmationCodeSubmitted(
          verificationId: (context.read<NumberVerificationBloc>().state as NumberSubmitSuccess).verificationId,
          smsCode: _verificationCodeController.text.trim(),
        ),
      );
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
                      'Potwierdź numer telefonu',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 24,
                        fontFamily: 'Itim',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  LabeledTextField(
                    label: "Kod weryfikacyjny",
                    controller: _verificationCodeController,
                    iconOnLeft: false,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Proszę podać kod weryfikacyjny';
                      }
                      if (value.trim().length != 6) {
                        return 'Kod weryfikacyjny musi mieć 6 cyfr';
                      }
                      return null;
                    },
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
                        onTap: widget.isLoading
                            ? () {}
                            : _handleBack,
                        backgroundColor: AppColors.secondaryButton,
                      ),
                      CustomTextButton(
                        label: "Weryfikuj",
                        onTap: widget.isLoading
                            ? () {}
                            : _handleSubmit,
                        backgroundColor: AppColors.primaryButton,
                        isLoading: widget.isLoading,
                      ),
                    ],
                  ),
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
                    'Kod nie dotarł?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontFamily: 'Itim',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  CustomTextButton.small(
                    label: _secondsLeft > 0 ? 'Wyślij ponownie (za ${_secondsLeft}s)' : 'Wyślij ponownie',
                    onTap: _secondsLeft > 0 ? () {} : _handleResend,
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