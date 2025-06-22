import 'dart:core';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proj_inz/bloc/number_verification/number_verification_bloc.dart';
import 'package:proj_inz/core/utils/validators.dart';
import 'package:proj_inz/presentation/screens/main_screen.dart';
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
  bool _isAfterRegistration = false;
  bool _numberSubmitted = false;

  void _previousStep() {
    setState(() {
      _numberSubmitted = false;
    });
  }

  void _nextStep() {
    setState(() {
      _numberSubmitted = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    BlocListener<NumberVerificationBloc, NumberVerificationState>(
      listener: (context, state) {
        if (state is NumberVerificationAfterRegistration) {
          setState(() {
            _isAfterRegistration = true;
          });
        }
      }
    );


    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Container(decoration: const BoxDecoration(color: Color(0xFFFFEC9C))),
          BlocConsumer<NumberVerificationBloc, NumberVerificationState>(
            listener: (context, state) {
              if (state is NumberVerificationSuccess) {
                showCustomSnackBar(context, "Numer telefonu został potwierdzony!");
              }

              if (state is NumberVerificationSkipRequested) {
                if (_isAfterRegistration) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const MainScreen()),
                  );
                } else {
                  Navigator.of(context).pop();
                }
              }
            },
            builder: (context, state) {
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 72, 16, 24),
                  child: Center(
                    child: !_numberSubmitted
                      ? _PhoneNumberStepCard(isLoading: state is NumberVerificationInProgress, onNext: _nextStep)
                      : _ConfirmationCodeStep(isLoading: state is NumberVerificationInProgress, onPrevious: _previousStep),
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
    context.read<NumberVerificationBloc>().add(
      NumberVerificationSkipRequested(),
    );
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _errorMessage = null;
      });
    widget.onNext;
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
                  const Text(
                    'Podaj swój numer telefonu, a prześlemy Tobie SMSem kod weryfikacyjny. Numer telefonu zostanie przypisany do konta. ',
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontFamily: 'Itim',
                      fontWeight: FontWeight.w400,
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
  final _formKey = GlobalKey<FormState>();
  final _verificationCodeController = TextEditingController();
  String? _errorMessage;

  void _handleBack() {
    widget.onPrevious;
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _errorMessage = null;
      });

      context.read<NumberVerificationBloc>().add(
        NumberVerificationRequested(
          number: _verificationCodeController.text.trim(),
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
                    label: "Kod weryfikacyjny",
                    controller: _verificationCodeController,
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
                        label: "Wróć",
                        onTap: widget.isLoading
                            ? () {}
                            : _handleBack,
                        backgroundColor: const Color(0xFFEBEBEB),
                      ),
                      CustomTextButton(
                        label: "Weryfikuj",
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
                      color: Colors.black,
                      fontSize: 14,
                      fontFamily: 'Itim',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  CustomTextButton.small(
                    label: "Wyślj ponownie",
                    onTap: () {}
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