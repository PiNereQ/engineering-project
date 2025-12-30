import 'package:flutter/material.dart';
import 'package:icon_decoration/icon_decoration.dart';
import 'package:proj_inz/core/theme.dart';

class StarRating extends StatefulWidget {
  final int startRating;
  final ValueChanged<int> onRatingChanged;

  const StarRating({
    super.key,
    this.startRating = 0,
    required this.onRatingChanged,
  });

  @override
  State<StarRating> createState() => _StarRatingState();
}

class _StarRatingState extends State<StarRating> {
  late int rating;
  int hoverRating = 0;

  @override
  void initState() {
    super.initState();
    rating = widget.startRating;
  }

  int _calculateRating(double dx, double width) {
    if (dx < 0) return 0;
    if (dx > width) return 5;
    return (dx / (width / 5)).floor() + 1;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragStart: (details) {
        setState(() {
          hoverRating = _calculateRating(details.localPosition.dx, context.size!.width);
        });
      },
      onHorizontalDragUpdate: (details) {
        setState(() {
          hoverRating = _calculateRating(details.localPosition.dx, context.size!.width);
        });
      },
      onHorizontalDragEnd: (_) {
        setState(() {
          rating = hoverRating;
          widget.onRatingChanged(rating);
          hoverRating = 0;
        });
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(
          5,
          (index) {
            return GestureDetector(
              onTapDown: (_) => setState(() {
                hoverRating = index + 1;
              }),
              onTapCancel: () => setState(() {
                hoverRating = 0;
              }),
              child: GestureDetector(
                onTap: () => setState(() {
                  rating = index + 1;
                  widget.onRatingChanged(rating);
                }),
              child: DecoratedIcon(
                decoration: IconDecoration(
                  border: IconBorder(color: AppColors.textPrimary, width: 4),
                ),
                icon:
                    (index < (hoverRating > 0 ? hoverRating : rating))
                        ? Icon(
                          Icons.star_rate_rounded,
                          size: 38,
                          color:
                              hoverRating > 0
                                  ? Colors.amberAccent
                                  : Colors.amber,
                        )
                        : Icon(
                          Icons.star_rate_rounded,
                          size: 38,
                          color: AppColors.textSecondary,
                        ),
              ),
            ),
          );
        },
        ),
      ),
    );
  }
}