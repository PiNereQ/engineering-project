import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:proj_inz/core/theme.dart';

enum LabeledTextFieldWidth { full, half }

class LabeledTextField extends StatelessWidget {
  final String label;
  final String? placeholder;
  final double iconRotationRadians;
  final bool iconOnLeft;
  final LabeledTextFieldWidth width;
  final TextAlign textAlign;
  final int maxLines;
  final bool isPassword;

  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final FormFieldValidator<String?>? validator;
  final ValueChanged<String>? onChanged;

  const LabeledTextField({
    super.key,
    required this.label,
    this.placeholder,
    this.iconRotationRadians = 0.0,
    this.iconOnLeft = true,
    this.width = LabeledTextFieldWidth.full,
    this.textAlign = TextAlign.left,
    this.maxLines = 1,
    this.isPassword = false,
    this.controller,
    this.keyboardType,
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final labelRow = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: iconOnLeft ? MainAxisAlignment.start : MainAxisAlignment.end,
      children: iconOnLeft
          ? [
              Transform.rotate(
                angle: iconRotationRadians,
                child: SvgPicture.asset(
                  'assets/icons/switch-access-shortcut-rounded.svg',
                  width: 18,
                  height: 18,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                label,
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
                label,
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
                transform: Matrix4.rotationZ(iconRotationRadians)..scale(-1.0, 1.0),
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
        final double calculatedWidth = width == LabeledTextFieldWidth.full
            ? constraints.maxWidth
            : (constraints.maxWidth - 16) / 2;

        return SizedBox(
          width: calculatedWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(
                  left: iconOnLeft ? 4 : 24,
                  bottom: 4,
                ),
                child: labelRow,
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: ShapeDecoration(
                  color: AppColors.surface,
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
                    )
                  ],
                ),
                child: TextFormField(
                  maxLines: maxLines,
                  decoration: InputDecoration.collapsed(
                    hintText: placeholder,
                  ).copyWith(
                    errorStyle: const TextStyle(
                      color: AppColors.alertText,
                      fontSize: 12,
                      fontFamily: 'Itim',
                    ),
                  ),
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontFamily: 'Itim',
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: textAlign,
                  obscureText: isPassword,
                  obscuringCharacter: '♡',
                  controller: controller,
                  keyboardType: keyboardType,
                  validator: validator,
                  onChanged: onChanged,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
