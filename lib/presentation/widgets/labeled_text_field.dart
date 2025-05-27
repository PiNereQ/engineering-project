import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum LabeledTextFieldWidth { full, half }

class LabeledTextField extends StatelessWidget {
  final String label;
  final String placeholder;
  final double iconRotationRadians;
  final bool iconOnLeft;
  final LabeledTextFieldWidth width;

  const LabeledTextField({
    super.key,
    required this.label,
    required this.placeholder,
    this.iconRotationRadians = 0.0,
    this.iconOnLeft = true,
    this.width = LabeledTextFieldWidth.full,
  });

  @override
  Widget build(BuildContext context) {
    final labelRow = Row(
      mainAxisSize: MainAxisSize.min,
      children: iconOnLeft
          ? [
              Transform.rotate(
                angle: iconRotationRadians,
                child: SvgPicture.asset(
                  'icons/switch-access-shortcut-rounded.svg',
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
              Transform.rotate(
                angle: iconRotationRadians,
                child: SvgPicture.asset(
                  'icons/switch-access-shortcut-rounded.svg',
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
            : (constraints.maxWidth - 16) / 2; // odstęp 16 między 2 polami

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
                child: Text(
                  placeholder,
                  style: const TextStyle(
                    color: Color(0xFF646464),
                    fontSize: 18,
                    fontFamily: 'Itim',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
