import 'package:flutter/material.dart';
import 'package:proj_inz/core/theme.dart';

class ReputationBar extends StatelessWidget {
  final int value; // 0-100
  final double maxWidth;
  final double height;

  const ReputationBar({
    super.key,
    required this.value,
    this.maxWidth = double.infinity,
    this.height = 18,
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

        return SizedBox(
          width: barWidth + 4,
          height: height + 4,
          child: Stack(
            children: [

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
      },
    );
  }
}