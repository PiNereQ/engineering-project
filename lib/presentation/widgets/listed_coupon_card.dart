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
        isInteger(reduction)
            ? reduction.toString()
            : reductionIsPercentage
            ? reduction.toString().replaceAll('.', ',')
            : reduction.toStringAsFixed(2).replaceAll('.', ',');

    final titleText = TextSpan(
      text: reductionIsPercentage
          ? "Kupon -$reductionText%\n"
          : "Kupon na $reductionText zł\n",
      style: TextStyle(
        color: isSold ? AppColors.textSecondary : AppColors.textPrimary,
        fontSize: 20,
        fontFamily: 'Itim',
        fontWeight: FontWeight.w400,
        height: 1.0,
      ),
    );

    final limitsText = TextSpan(
      text: hasLimits ? 'z ograniczeniami' : 'na wszystko',
      style: TextStyle(
        color: isSold ? AppColors.textSecondary : AppColors.textPrimary,
        fontSize: 14,
        fontFamily: 'Itim',
        fontWeight: FontWeight.w400,
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
          style: TextStyle(
            color: isSold ? AppColors.textSecondary : AppColors.textPrimary,
            fontSize: 24,
            fontFamily: 'Itim',
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );

    final expiryDateText = TextSpan(
      text:
      expiryDate == null ? 'brak daty ważności' : "ważny do ${formatDate(expiryDate)}",
      style: TextStyle(
        color: isSold ? AppColors.textSecondary : AppColors.textPrimary,
        fontSize: 12,
        fontFamily: 'Itim',
        height: 1.0,
      ),
    );

    final listingDateText = TextSpan(
      text:
          "wystawiono ${listingDate.day}.${listingDate.month}.${listingDate.year}r.",
      style: TextStyle(
        color: AppColors.textSecondary,
        fontSize: 12,
        fontFamily: 'Itim',
        height: 1.0,
      ),
    );

    return Stack(
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
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => ListedCouponDetailsScreen(couponId: couponId)
                      ),
                    );
                  },
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
                                Text.rich(
                                  TextSpan(children: [titleText, limitsText]),
                                ),
                                const SizedBox(height: 2.0),
                                Text.rich(priceText),
                                const SizedBox(height: 2.0),
                                Text.rich(listingDateText),
                                Text.rich(expiryDateText),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
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
          bottom: 16,
          right: 128,
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
    );
  }
}