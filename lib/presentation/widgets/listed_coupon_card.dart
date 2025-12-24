import 'package:flutter/material.dart';
import 'package:proj_inz/core/theme.dart';
import 'package:proj_inz/core/utils/utils.dart';
import 'package:proj_inz/data/models/coupon_model.dart';
import 'package:proj_inz/presentation/screens/listed_coupon_detail_screen.dart';
import 'package:proj_inz/presentation/widgets/dashed_separator.dart';

class ListedCouponCardHorizontal extends StatelessWidget {
  final Coupon coupon;

  const ListedCouponCardHorizontal({
    super.key,
    required this.coupon,
  });

  @override
  Widget build(BuildContext context) {
    final String couponId = coupon.id;
    final reduction = coupon.reduction;
    final reductionIsPercentage = coupon.reductionIsPercentage;
    final price = coupon.price;
    final shopName = coupon.shopName;
    final shopNameColor = coupon.shopNameColor;
    final shopBgColor = coupon.shopBgColor;
    final hasLimits = coupon.hasLimits;
    final expiryDate = coupon.expiryDate;
    final listingDate = coupon.listingDate;
    final isSold = coupon.isSold;

    final reductionText =
        formatReduction(reduction.toDouble(), reductionIsPercentage);

    final titleText = Text(
        reductionIsPercentage
            ? '-$reductionText'
            : reductionText,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 22,
        fontFamily: 'Itim',
        fontWeight: FontWeight.w400,
      ),
      strutStyle: const StrutStyle(
        height: 1.0,
        forceStrutHeight: true,
      ),
    );

    final limitsText = Text(
      hasLimits ? 'z ograniczeniami' : 'na wszystko',
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 14,
        fontFamily: 'Itim',
        fontWeight: FontWeight.w400,
      ),
      strutStyle: const StrutStyle(
        height: 0.7,
        forceStrutHeight: true,
      ),
    );

    final priceText = TextSpan(
      children: [
        const TextSpan(
          text: "Cena: ",
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            fontFamily: 'Itim',
            fontWeight: FontWeight.w400,
          ),
        ),
        TextSpan(
          text: "${formatPrice(price)} zł",
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 24,
            fontFamily: 'Itim',
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );

    final listingDateText = Text(
      "Dodano ${formatDate(listingDate)}",
      style: TextStyle(
        color: AppColors.textSecondary,
        fontSize: 13,
        fontFamily: 'Itim',
        height: 1.0,
      ),
    );

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ListedCouponDetailsScreen(couponId: couponId),
          ),
        );
      },
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(width: 2, color: AppColors.textPrimary),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.textPrimary,
                  blurRadius: 0,
                  offset: Offset(4, 4),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: 12,
              children: [
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    spacing: 12,
                    children: [
                      // Shop
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16.0, 10.0, 0.0, 10.0),
                        child: Container(
                          width: 110.0,
                          height: 80.0,
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: ShapeDecoration(
                              color: isSold ? AppColors.primaryButtonPressed : shopBgColor,
                            shape: RoundedRectangleBorder(
                              side: const BorderSide(width: 2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            shopName,
                            style: TextStyle(
                              color: isSold ? AppColors.textSecondary : shopNameColor,
                              fontSize: 15,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      // Details
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: SizedBox(
                            width: 150,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  spacing: 4,
                                  children: [
                                    Icon(Icons.local_offer_outlined, size: 20),
                                    titleText,
                                  ],
                                ),
                                const SizedBox(height: 1.0),
                                limitsText,
                                const SizedBox(height: 2.0),
                                Text.rich(priceText),
                                const SizedBox(height: 2.0),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  spacing: 4,
                                  children: [
                                    Icon(Icons.calendar_today, size: 14),
                                    Expanded(
                                      child: LayoutBuilder(
                                        builder: (context, constraints) {
                                          final bool isTight = constraints.maxWidth < 110;

                                          final String text = expiryDate != null
                                              ? 'Do ${formatDate(expiryDate)}'
                                              : isTight
                                                  ? 'Bez daty ważn.'
                                                  : 'Bez daty ważności';

                                          return Text(
                                            text,
                                            maxLines: 1,
                                            overflow: expiryDate != null
                                                ? TextOverflow.ellipsis
                                                : TextOverflow.visible,
                                            style: const TextStyle(
                                              color: AppColors.textPrimary,
                                              fontSize: 13,
                                              fontFamily: 'Itim',
                                              fontWeight: FontWeight.w400,
                                              height: 1.0,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2.0),
                                Row(
                                  spacing: 4,
                                  children: [
                                    Icon(Icons.volunteer_activism_outlined, size: 14),
                                    Expanded(child: listingDateText),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                DashedSeparator.vertical(length: 146),
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 10, 16, 10),
                  child: Center(child: Icon(isSold ? Icons.done_all_rounded : Icons.store_rounded, size: 36)),
                ),
              ],
            ),
          ),
          if (isSold)
          Positioned(
            bottom: 20,
            left: 138,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(width: 3, color: AppColors.notificationDot),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Text(
                'Sprzedany',
                style: TextStyle(
                  color: AppColors.notificationDot,
                  fontSize: 16,
                  fontFamily: 'Itim',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}