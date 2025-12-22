import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:proj_inz/core/theme.dart';

enum LabeledTextFieldWidth { full, half }

class LabeledTextField extends StatefulWidget {
  final String label;
  final String? placeholder;
  final double iconRotationRadians;
  final bool iconOnLeft;
  final LabeledTextFieldWidth width;
  final TextAlign textAlign;
  final int maxLines;
  final int? maxLength;
  final bool isPassword;
  final bool enabled;

  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final FormFieldValidator<String?>? validator;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final Widget? suffix;

  const LabeledTextField({
    super.key,
    required this.label,
    this.placeholder,
    this.iconRotationRadians = 0.0,
    this.iconOnLeft = true,
    this.width = LabeledTextFieldWidth.full,
    this.textAlign = TextAlign.left,
    this.maxLines = 1,
    this.maxLength,
    this.isPassword = false,
    this.controller,
    this.keyboardType,
    this.validator,
    this.onChanged,
    this.inputFormatters,
    this.suffix,
    this.enabled = true,
  });

  @override
  State<LabeledTextField> createState() => _LabeledTextFieldState();
}

class _LabeledTextFieldState extends State<LabeledTextField> {

  late bool _isObscured;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    final labelRow = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: widget.iconOnLeft ? MainAxisAlignment.start : MainAxisAlignment.end,
      children: widget.iconOnLeft
          ? [
              Transform.rotate(
                angle: widget.iconRotationRadians,
                child: SvgPicture.asset(
                  'assets/icons/switch-access-shortcut-rounded.svg',
                  width: 18,
                  height: 18,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  fontFamily: 'Itim',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ]
          : [
              Text(
                widget.label,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  fontFamily: 'Itim',
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(width: 8),
              Transform(
                alignment: Alignment.center,
                transform: Matrix4.rotationZ(widget.iconRotationRadians)..scale(-1.0, 1.0),
                child: SvgPicture.asset(
                  'assets/icons/switch-access-shortcut-rounded.svg',
                  width: 18,
                  height: 18,
                ),
              ),
            ],
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final double calculatedWidth = widget.width == LabeledTextFieldWidth.full
            ? constraints.maxWidth
            : (constraints.maxWidth - 16) / 2;

        return SizedBox(
          width: calculatedWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(
                  left: widget.iconOnLeft ? 4 : 24,
                  bottom: 4,
                ),
                child: labelRow,
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: ShapeDecoration(
                  color: widget.enabled
                      ? AppColors.surface
                      : AppColors.secondaryButton,
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(width: 2),
                    borderRadius: BorderRadius.circular(16),
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
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      child: TextFormField(
                        enabled: widget.enabled,
                        inputFormatters: widget.inputFormatters,
                        maxLines: widget.maxLines,
                        decoration: InputDecoration(
                          isCollapsed: true,
                          border: InputBorder.none,
                          hintText: widget.placeholder,
                          suffix: widget.suffix,
                          errorStyle: const TextStyle(
                            color: AppColors.alertText,
                            fontSize: 12,
                            fontFamily: 'Itim',
                          ),
                          hintStyle: TextStyle(
                            color: widget.enabled
                              ? AppColors.textSecondary
                              : AppColors.textSecondary.withOpacity(0.6),
                          ),
                        ),
                        style: TextStyle(
                          color: widget.enabled
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                          fontSize: 18,
                          fontFamily: 'Itim',
                          fontWeight: FontWeight.w400,
                        ),
                        textAlign: widget.textAlign,
                        obscureText: widget.isPassword && _isObscured,
                        obscuringCharacter: '♡',
                        controller: widget.controller,
                        keyboardType: widget.keyboardType,
                        validator: widget.validator,
                        onChanged: widget.onChanged,
                      ),
                    ),
                    if (widget.isPassword)
                    GestureDetector(
                      child: Icon(
                        _isObscured ? Icons.visibility : Icons.visibility_off,
                        color: AppColors.textPrimary,
                      ),
                      onTap: () {
                        setState(() {
                          _isObscured = !_isObscured;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
