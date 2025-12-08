import 'package:flutter/material.dart';
import 'package:proj_inz/presentation/widgets/coupon_details_card.dart';
import 'package:proj_inz/data/models/coupon_model.dart';

class CouponPreviewPopup extends StatelessWidget {
  final Coupon coupon;
  final VoidCallback onClose;

  const CouponPreviewPopup({
    super.key,
    required this.coupon,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.black.withOpacity(0.25),
        child: Center(
          child: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: Stack(
              children: [
                SingleChildScrollView(
                  child: CouponDetailsCard(
                    coupon: coupon,
                    showCloseButton: true,
                    onClose: onClose,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}