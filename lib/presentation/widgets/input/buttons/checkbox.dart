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
                    ? CustomPaint(
                        size: const Size(24, 24),
                        painter: CheckMarkPainter(
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

class CheckMarkPainter extends CustomPainter {
  final Color color;

  CheckMarkPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();

    path.moveTo(size.width * 0.18, size.height * 0.55);
    path.lineTo(size.width * 0.42, size.height * 0.75);
    path.lineTo(size.width * 0.82, size.height * 0.25);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}