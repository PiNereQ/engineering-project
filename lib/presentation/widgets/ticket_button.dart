import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TicketButton extends StatelessWidget {
  final double height;
  final double width;
  final String leftText;
  final String rightText;
  final double fontSize;

  const TicketButton({
    super.key,
    required this.height,
    required this.width,
    required this.leftText,
    required this.rightText,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        width: width,
        height: height,
        padding: const EdgeInsets.only(right: 4, bottom: 4),
        child: Column(
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 132),
              child: Container(
                width: double.infinity,
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: ShapeDecoration(
                  color:  Colors.white,
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(width: 2),
                    borderRadius: BorderRadius.circular(1000),
                  ),
                  shadows: const [
                          BoxShadow(
                            color: Color(0xFF000000),
                            blurRadius: 0,
                            offset: Offset(4, 4),
                            spreadRadius: 0,
                          )
                        ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      leftText,
                      style: TextStyle(
                        fontSize: fontSize,
                        fontFamily: 'Itim',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(width: 8),
                    SvgPicture.asset(
                      "assets/icons/ticketbutton_separator.svg",
                      width: 48,
                      height: 2,
                    ),
                    const Spacer(),
                    Text(
                      rightText,
                      style: TextStyle(
                        fontSize: fontSize,
                        fontFamily: 'Itim',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(width: 8),
                    SvgPicture.asset(
                      "assets/icons/heart.svg",
                      width: 20,
                      height: 18.35,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
 }
}