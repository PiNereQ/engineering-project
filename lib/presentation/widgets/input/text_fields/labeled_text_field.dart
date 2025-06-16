import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum LabeledTextFieldWidth { full, half }

class LabeledTextField extends StatelessWidget {
  final String label;
  final String placeholder;
  final double iconRotationRadians;
  final bool iconOnLeft;
  final LabeledTextFieldWidth width;
  final TextAlign textAlign;
  final int maxLines;

  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final FormFieldValidator<String?>? validator;

  const LabeledTextField({
    super.key,
    required this.label,
    required this.placeholder,
    this.iconRotationRadians = 0.0,
    this.iconOnLeft = true,
    this.width = LabeledTextFieldWidth.full,
    this.textAlign = TextAlign.left,
    this.maxLines = 1,
    this.controller,
    this.keyboardType,
    this.validator,
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
                  color: Color(0xFF646464),
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
                  color: Color(0xFF646464),
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

        return Container(
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
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(width: 2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  shadows: const [
                    BoxShadow(
                      color: Color(0xFF000000),
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
                  ),
                  style: const TextStyle(
                    color: Color(0xFF000000),
                    fontSize: 18,
                    fontFamily: 'Itim',
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: textAlign,
                  controller: controller,
                  keyboardType: keyboardType,
                  validator: validator
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
