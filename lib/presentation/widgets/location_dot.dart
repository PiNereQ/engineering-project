import 'package:flutter/material.dart';

class LocationDot extends StatefulWidget {
  const LocationDot({super.key});

  @override
  State<LocationDot> createState() => _LocationDotState();
}

class _LocationDotState extends State<LocationDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _dotAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _dotAnimation = Tween<double>(
      begin: 0.0,
      end: 3.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _dotAnimation,
      builder: (context, child) {
        return Container(
          padding: EdgeInsets.fromLTRB(3-_dotAnimation.value, 3-_dotAnimation.value, _dotAnimation.value, _dotAnimation.value),
          child: Container(
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 89, 180, 255),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF000000),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF000000).withValues(alpha: 0.5),
                  blurRadius: 0,
                  offset: Offset(_dotAnimation.value, _dotAnimation.value),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Container(
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 89, 180, 255),
                shape: BoxShape.circle,
                border: Border.all(
                    color: const Color.fromARGB(255, 255, 255, 255), width: 3),
              ),
            ),
          ),
        );
      },
    );
  }
}