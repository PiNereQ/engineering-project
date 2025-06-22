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

    final double maxDimension = isVertical ? size.height : size.width;

    while (start < maxDimension) {
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
  final double length;
  final Color color;
  final bool _isVertical;

  const DashedSeparator._({
    required this.length,
    this.color = Colors.black,
    required bool isVertical
  }) : _isVertical = isVertical;

  factory DashedSeparator({
    double length = double.infinity,
    Color color = Colors.black,
  }) {
    return DashedSeparator._(
      length: length,
      color: color,
      isVertical: false,
    );
  }

  factory DashedSeparator.vertical({
    required double length,
    Color color = Colors.black,
  }) {
    return DashedSeparator._(
      length: length,
      color: color,
      isVertical: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: _isVertical
          ? Size(1, length)
          : Size(length, 1),
      painter: DashedLinePainter(
        dashWidth: 4.0,
        dashSpace: 10.0,
        dashHeight: 5.0,
        color: color,
        isVertical: _isVertical,
      ),
    );
  }
}