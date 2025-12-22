import 'package:flutter/material.dart';
import 'package:proj_inz/core/theme.dart';

class CustomTextButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final Widget? icon;
  final int? badgeNumber;
  final double? height;
  final double? width;
  final Color backgroundColor;
  final bool isLoading;

  final Color textColor;
  final Color? pressedTextColor;

  final double _fontSize;
  final double _iconSize;
  final double _minWidth;
  final EdgeInsetsGeometry _padding;
  final double _spacing;

  const CustomTextButton._({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.badgeNumber,
    this.height,
    this.width,
    required this.backgroundColor,
    required this.textColor,
    this.pressedTextColor,
    this.isLoading = false,
    required double fontSize,
    required double iconSize,
    required double minWidth,
    required EdgeInsetsGeometry padding,
    required double spacing,
  })  : _fontSize = fontSize,
        _iconSize = iconSize,
        _minWidth = minWidth,
        _padding = padding,
        _spacing = spacing;

  // Default white/surface button
  factory CustomTextButton({
    Key? key,
    required String label,
    required VoidCallback onTap,
    Widget? icon,
    int? badgeNumber,
    double? height,
    double? width,
    Color backgroundColor = AppColors.surface,
    bool isLoading = false,
  }) {
    return CustomTextButton._(
      key: key,
      label: label,
      onTap: onTap,
      icon: icon,
      badgeNumber: badgeNumber,
      height: height,
      width: width,
      backgroundColor: backgroundColor,
      textColor: AppColors.textPrimary,
      pressedTextColor: null,
      isLoading: isLoading,
      fontSize: 18,
      iconSize: 24,
      minWidth: 132,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      spacing: 10,
    );
  }

  factory CustomTextButton.small({
    Key? key,
    required String label,
    required VoidCallback onTap,
    Widget? icon,
    int? badgeNumber,
    double? height,
    double? width,
    Color backgroundColor = AppColors.surface,
    bool isLoading = false,
  }) {
    return CustomTextButton._(
      key: key,
      label: label,
      onTap: onTap,
      icon: icon,
      badgeNumber: badgeNumber,
      height: height,
      width: width,
      backgroundColor: backgroundColor,
      textColor: AppColors.textPrimary,
      pressedTextColor: null,
      isLoading: isLoading,
      fontSize: 14,
      iconSize: 16,
      minWidth: 75,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      spacing: 6,
    );
  }

  // primary button
  factory CustomTextButton.primary({
    Key? key,
    required String label,
    required VoidCallback onTap,
    Widget? icon,
    int? badgeNumber,
    double? height,
    double? width,
    bool isLoading = false,
  }) {
    return CustomTextButton._(
      key: key,
      label: label,
      onTap: onTap,
      icon: icon,
      badgeNumber: badgeNumber,
      height: height,
      width: width,
      backgroundColor: AppColors.primaryButton,
      textColor: AppColors.textPrimary,
      pressedTextColor: AppColors.primaryButtonDark,
      isLoading: isLoading,
      fontSize: 18,
      iconSize: 24,
      minWidth: 132,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      spacing: 10,
    );
  }

  factory CustomTextButton.primarySmall({
    Key? key,
    required String label,
    required VoidCallback onTap,
    Widget? icon,
    int? badgeNumber,
    double? height,
    double? width,
    bool isLoading = false,
  }) {
    return CustomTextButton._(
      key: key,
      label: label,
      onTap: onTap,
      icon: icon,
      badgeNumber: badgeNumber,
      height: height,
      width: width,
      backgroundColor: AppColors.primaryButton,
      textColor: AppColors.textPrimary,
      pressedTextColor: AppColors.primaryButtonDark,
      isLoading: isLoading,
      fontSize: 14,
      iconSize: 16,
      minWidth: 75,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      spacing: 6,
    );
  }

  @override
  State<CustomTextButton> createState() => _CustomTextButtonState();
}

class _CustomTextButtonState extends State<CustomTextButton> {
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
            height: widget.height,
            width: widget.width,
            constraints: BoxConstraints(minWidth: widget._minWidth),
            padding: widget._padding,
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
                      ),
                    ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: widget._spacing,
              children: [
                Text(
                  widget.label,
                  style: TextStyle(
                    color: _isPressed
                        ? (widget.pressedTextColor ?? AppColors.textSecondary)
                        : widget.textColor,
                    fontSize: widget._fontSize,
                    fontFamily: 'Itim',
                    fontWeight: FontWeight.w400,
                  ),
                ),

                if (widget.isLoading)
                  SizedBox(
                    width: widget._iconSize,
                    height: widget._iconSize,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      strokeCap: StrokeCap.round,
                      color: _isPressed
                          ? (widget.pressedTextColor ?? AppColors.textSecondary)
                          : widget.textColor,
                    ),
                  )
                else if (widget.icon != null)
                  SizedBox(
                    width: widget._iconSize,
                    height: widget._iconSize,
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: widget.icon,
                    ),
                  ),

              if (widget.badgeNumber != null)
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.notificationDot,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
