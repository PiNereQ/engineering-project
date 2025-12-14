import 'package:flutter/material.dart';
import 'package:proj_inz/core/theme.dart';

class ReputationBar extends StatelessWidget {
  final int value; // 0-100
  final double maxWidth;
  final double height;
  final bool showValue;

  const ReputationBar({
    super.key,
    required this.value,
    this.maxWidth = double.infinity,
    this.height = 18,
    this.showValue = false,
  });

  Color _getBarColor(int value) {
    if (value <= 33) {
      return Colors.redAccent;
    } else if (value <= 66) {
      return Colors.amber;
    } else {
      return Colors.lightGreenAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final clamped = value.clamp(0, 100);
    final factor = clamped / 100;
    final barColor = _getBarColor(clamped);

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = maxWidth == double.infinity
            ? constraints.maxWidth
            : maxWidth;

        final barWidth = availableWidth * factor;

        final barWidget = SizedBox(
          width: barWidth + 4,
          height: height + 4,
          child: Stack(
            children: [
              // shadow
              Positioned(
                top: 4,
                left: 0,
                child: Container(
                  width: barWidth,
                  height: height,
                  decoration: BoxDecoration(
                    color: AppColors.textPrimary,
                    borderRadius: BorderRadius.circular(height),
                  ),
                ),
              ),

              // bar
              Container(
                width: barWidth,
                height: height,
                decoration: BoxDecoration(
                  color: barColor,
                  borderRadius: BorderRadius.circular(height),
                  border: Border.all(width: 2),
                ),
              ),
            ],
          ),
        );

        if (!showValue) {
          return barWidget;
        }

        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            barWidget,
            const SizedBox(width: 6),
            Text(
              clamped.toString(),
              style: const TextStyle(
                fontFamily: 'Itim',
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        );
      },
    );
  }
}