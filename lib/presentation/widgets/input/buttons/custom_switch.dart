import 'package:flutter/material.dart';
import 'package:proj_inz/core/theme.dart';

class CustomSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final double width;
  final double height;
  final Color activeColor;
  final Color inactiveColor;
  final Color thumbColor;
  final Duration duration;

  const CustomSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.width = 52,
    this.height = 32,
    this.activeColor = AppColors.primaryButton,
    this.inactiveColor = AppColors.secondaryButton,
    this.thumbColor = AppColors.surface,
    this.duration = const Duration(milliseconds: 200),
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: duration,
        width: width,
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.textPrimary, width: 2),
          borderRadius: BorderRadius.circular(100),
          color: value ? activeColor : inactiveColor,
          boxShadow: [
            BoxShadow(
              color: AppColors.textPrimary,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedAlign(
              alignment: value ? Alignment.centerRight : Alignment.centerLeft,
              duration: duration,
              curve: Curves.easeInOut,
              child: Container(
                width: height - 8,
                height: height - 8,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.textPrimary, width: 2),
                  color: thumbColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.textPrimary,
                      offset: const Offset(1, 1),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
