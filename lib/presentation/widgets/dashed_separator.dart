import 'package:flutter/material.dart';

class DashedLinePainter extends CustomPainter {
  final double dashWidth;
  final double dashSpace;
  final double dashHeight;
  final Color color;
  final bool isVertical;

  DashedLinePainter({
    this.dashWidth = 5.0,
    this.dashSpace = 3.0,
    this.dashHeight = 1.0,
    this.color = Colors.black,
    this.isVertical = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = dashHeight
      ..strokeCap = StrokeCap.round;
    double start = 0;
    while (start < (isVertical ? size.height : size.width)) {
      if (isVertical) {
        canvas.drawLine(
          Offset(0, start),
          Offset(0, start + dashWidth),
          paint,
        );
      } else {
        canvas.drawLine(
          Offset(start, 0),
          Offset(start + dashWidth, 0),
          paint,
        );
      }
      start += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class DashedSeparator extends StatelessWidget {
  final double dashWidth;
  final double dashSpace;
  final double dashHeight;
  final Color color;
  final bool isVertical;

  const DashedSeparator({
    super.key,
    this.dashWidth = 4.0,
    this.dashSpace = 10.0,
    this.dashHeight = 5.0,
    this.color = Colors.black,
    this.isVertical = false,
  });

  factory DashedSeparator.vertical({
    double dashWidth = 4.0,
    double dashSpace = 10.0,
    double dashHeight = 5.0,
    Color color = Colors.black,
  }) {
    return DashedSeparator(
      dashWidth: dashWidth,
      dashSpace: dashSpace,
      dashHeight: dashHeight,
      color: color,
      isVertical: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: isVertical
          ? const Size(1, double.infinity)
          : const Size(double.infinity, 1),
      painter: DashedLinePainter(
        dashWidth: dashWidth,
        dashSpace: dashSpace,
        dashHeight: dashHeight,
        color: color,
        isVertical: isVertical,
      ),
    );
  }
}