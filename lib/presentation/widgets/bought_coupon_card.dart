import 'package:flutter/material.dart';

import 'package:proj_inz/core/utils/utils.dart';
import 'package:proj_inz/data/models/coupon_model.dart';
import 'package:proj_inz/presentation/screens/bought_coupon_detail_screen.dart';
import 'package:proj_inz/presentation/widgets/dashed_separator.dart';
import 'package:proj_inz/core/theme.dart';

class OwnedCouponCardHorizontal extends StatelessWidget {
  final Coupon coupon;

  const OwnedCouponCardHorizontal({
    super.key, 
    required this.coupon,
  });

  @override
  Widget build(BuildContext context) {
    final String couponId = coupon.id;
    final num reduction = coupon.reduction;
    final bool reductionIsPercentage = coupon.reductionIsPercentage;
    final int price = coupon.price;
    final String shopName = coupon.shopName;
    final Color shopNameColor = coupon.shopNameColor;
    final Color shopBgColor = coupon.shopBgColor;
    final bool hasLimits = coupon.hasLimits;
    final bool worksOnline = coupon.worksOnline;
    final bool worksInStore = coupon.worksInStore;
    final DateTime? expiryDate = coupon.expiryDate;
    final bool isUsed = coupon.isUsed!;

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

    final locationText = Text(
      worksInStore && worksOnline
          ? 'Stacjonarnie i online'
          : worksOnline
          ? 'Online'
          : 'Stacjonarnie',
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 13,
        fontFamily: 'Itim',
        fontWeight: FontWeight.w400,
        height: 1.0,
      ),
    );

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BoughtCouponDetailsScreen(couponId: couponId),
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
                              color: isUsed ? AppColors.primaryButtonPressed : shopBgColor,
                            shape: RoundedRectangleBorder(
                              side: const BorderSide(width: 2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            shopName,
                            style: TextStyle(
                              color: isUsed ? AppColors.textSecondary : shopNameColor,
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
                                  spacing: 4,
                                  children: [
                                    Icon(Icons.location_on_outlined, size: 14),
                                    Expanded(child: locationText),
                                  ],
                                ),
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
                  child: Center(child: Icon(isUsed ? Icons.done_all_rounded : Icons.check_rounded, size: 36)),
                ),
              ],
            ),
          ),
          if (expiryDate != null &&
              DateTime.now().isAfter(
                DateTime(
                  expiryDate.year,
                  expiryDate.month,
                  expiryDate.day,
                  23,
                  59,
                  59,
                ),
              ) &&
              !isUsed
              )
          Positioned(
            bottom: 22,
            left: 138,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(width: 3, color: AppColors.alertText),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Text(
                'Przeterminowany',
                style: TextStyle(
                  color: AppColors.alertText,
                  fontSize: 16,
                  fontFamily: 'Itim',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          if (isUsed)
          Positioned(
            bottom: 22,
            left: 138,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(width: 3, color: AppColors.notificationDot),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Text(
                'Wykorzystany',
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