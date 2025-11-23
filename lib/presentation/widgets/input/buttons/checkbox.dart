import 'package:flutter/material.dart';
import 'package:proj_inz/core/theme.dart';

class CustomCheckbox extends StatelessWidget {
  final bool selected;
  final VoidCallback onTap;
  final String label;

  const CustomCheckbox({
    super.key,
    required this.selected,
    required this.onTap,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 36,
            height: 36,
            child: Center(
              child: Container(
                width: 24,
                height: 24,
                decoration: ShapeDecoration(
                  color: AppColors.surface,
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(width: 2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  shadows: const [
                    BoxShadow(
                      color: AppColors.textPrimary,
                      blurRadius: 0,
                      offset: Offset(2, 2),
                      spreadRadius: 0,
                    )
                  ],
                ),
                child: selected
                    ? const Center(
                        child: Icon(
                          Icons.check,
                          size: 16,
                          color: AppColors.checkIcon,
                        ),
                      )
                    : null,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontFamily: 'Itim',
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
