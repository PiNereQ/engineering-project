import 'package:flutter/material.dart';
import 'package:proj_inz/presentation/widgets/dashed_separator.dart';
import 'package:proj_inz/core/theme.dart';

class TicketButton extends StatefulWidget {
  final String label;
  final String value;
  final Widget icon;
  final VoidCallback onTap;
  final Color backgroundColor;

  const TicketButton._({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
    this.backgroundColor = AppColors.surface,
  });

  factory TicketButton({
    Key? key,
    required String label,
    required String value,
    required Widget icon,
    required VoidCallback onTap,
    Color backgroundColor = AppColors.surface,
  }) {
    return TicketButton._(
      key: key,
      label: label,
      value: value,
      icon: icon,
      onTap: onTap,
      backgroundColor: backgroundColor,
    );
  }

  @override
  State<TicketButton> createState() => _TicketButtonState();
}

class _TicketButtonState extends State<TicketButton> {
  bool _isPressed = false;

  Color _getPressedColor(Color color) {
    final hslColor = HSLColor.fromColor(color);
    return hslColor
        .withSaturation((hslColor.saturation - 0.2).clamp(0.0, 1.0))
        .withLightness((hslColor.lightness - 0.1).clamp(0.0, 1.0))
        .toColor();
  }
    
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        onTap: widget.onTap,
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapCancel: () => setState(() => _isPressed = false),
          onTapUp: (_) async {
            await Future.delayed(const Duration(milliseconds: 80));
            if (mounted) setState(() => _isPressed = false);
          },
        child: Container(
          padding: _isPressed
                  ? const EdgeInsets.only(top: 4, left: 4)
                  : const EdgeInsets.only(right: 4, bottom: 4),
          child: Container(
            width: double.infinity,
            decoration: ShapeDecoration(
              color: _isPressed
                  ? _getPressedColor(widget.backgroundColor)
                  : widget.backgroundColor,
              shape: RoundedRectangleBorder(
                side: const BorderSide(width: 2),
                borderRadius: BorderRadius.circular(1000),
              ),
              shadows: _isPressed
                  ? []
                  : [
                      const BoxShadow(
                        color: AppColors.textPrimary,
                        blurRadius: 0,
                        offset: Offset(4, 4),
                        spreadRadius: 0,
                      )
                    ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 0, 12),
                  child: Text(
                    widget.label,
                    style: const TextStyle(
                      fontSize: 18,
                      fontFamily: 'Itim',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 32,
                  children: [
                    DashedSeparator.vertical(length: 48),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 12, 24, 12),
                      child: Row(
                        spacing: 8,
                        children: [
                          Text(
                            widget.value,
                            style: TextStyle(
                              color: _isPressed
                                  ? AppColors.textSecondary
                                  : AppColors.textPrimary,
                              fontSize: 18,
                              fontFamily: 'Itim',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          widget.icon,
                        ],
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
 }
}