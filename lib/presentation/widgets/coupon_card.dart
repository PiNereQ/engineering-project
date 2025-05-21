import 'package:flutter/material.dart';

import 'package:proj_inz/core/utils.dart';
import 'package:proj_inz/data/models/coupon_model.dart';
import 'package:proj_inz/presentation/screens/coupon_detail_screen.dart';

class CouponHorizontalCard extends StatelessWidget {
  final Coupon coupon;

  const CouponHorizontalCard({
    super.key,
    required this.coupon
  });

  @override
  Widget build(BuildContext context) {
    final String couponId = coupon.id;
    final num reduction = coupon.reduction;
    final bool reductionIsPercentage = coupon.reductionIsPercentage;
    final num price = coupon.price;
    final String shopName = coupon.shopName;
    final Color shopNameColor = coupon.shopNameColor;
    final Color shopBgColor = coupon.shopBgColor;
    final bool hasLimits = coupon.hasLimits;
    final int sellerReputation = coupon.sellerReputation;
    final bool worksOnline = coupon.worksOnline;
    final bool worksInStore = coupon.worksInStore;
    final DateTime expiryDate = coupon.expiryDate;


    final reductionText = isInteger(reduction)
      ? reduction.toString()
      : reductionIsPercentage
        ? reduction.toString().replaceAll('.', ',')
        : reduction.toStringAsFixed(2).replaceAll('.', ',');

    final titleText = TextSpan(
      text: reductionIsPercentage 
      ? 'Kupon -$reductionText%\n'
      : 'Kupon na $reductionText zł\n',
      style: const TextStyle(
      color: Colors.black,
      fontSize: 20,
      fontFamily: 'Itim',
      fontWeight: FontWeight.w400,
      height: 1.0,
      ),
    );

    final limitsText = TextSpan(
      text: hasLimits
        ? 'z ograniczeniami'
        : 'na wszystko',
      style: const TextStyle(
        color: Colors.black,
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
            color: Color(0xFF646464),
            fontSize: 14,
            fontFamily: 'Itim',
            fontWeight: FontWeight.w400,
          ),
        ),
        TextSpan(
          text: "$price zł",
          style: const TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontFamily: 'Itim',
            fontWeight: FontWeight.w400,
          ),
        )
      ],
    );

    final reputationText = TextSpan(
      text: 'Reputacja: $sellerReputation',
      style: const TextStyle(
        color: Colors.black,
        fontSize: 12,
        fontFamily: 'Itim',
        fontWeight: FontWeight.w400,
        height: 1.0,
      ),
    );

    final locationText = TextSpan(
      text: 'Do wykorzystania ${
        worksInStore && worksOnline
        ? 'stacjonarnie i online'  
        : worksOnline
          ? 'w sklepach internetowych'
          : 'w sklepach stacjonarnie'
      }',
      style: const TextStyle(
        color: Colors.black,
        fontSize: 12,
        fontFamily: 'Itim',
        fontWeight: FontWeight.w400,
        height: 1.0,
      ),
    );

    final expiryDateText = TextSpan(
      text: '${expiryDate.day}.${expiryDate.month}.${expiryDate.year} r.',
      style: const TextStyle(
        color: Colors.black,
        fontSize: 12,
        fontFamily: 'Itim',
        fontWeight: FontWeight.w400,
        height: 1.0,
      ),
    );

    return Center(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CouponDetailsScreen(couponId: couponId),
            ),
          );
        },
        child: Container(
          width: 364.0,
          decoration: ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              side: const BorderSide(width: 2),
              borderRadius: BorderRadius.circular(16),
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(padding: const EdgeInsets.fromLTRB(16.0, 10.0, 0.0, 10.0),
                child: Container(
                  width: 110.0,
                  height: 80.0,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: ShapeDecoration(
                    color: shopBgColor,
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ), 
                  child: Text(
                    shopName,
                    style: TextStyle(
                      color: shopNameColor,
                      fontSize: 15,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w700,
                    )
                  ),
                ),
              ),
               Flexible(
                 fit: FlexFit.loose,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12.0, 10.0, 0.0, 10.0),
                  child: SizedBox(
                    width: 150,
                      child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text.rich(
                          TextSpan(
                            children: [
                              titleText,
                              limitsText
                            ],
                          ),
                        ),
                        const SizedBox(height: 2.0,),
                        Text.rich(priceText),
                        const SizedBox(height: 2.0,),
                        Text.rich(reputationText),
                        Text.rich(locationText),
                        Text.rich(expiryDateText),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          )
        ),
      ),
    );
  }
}