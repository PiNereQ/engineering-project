import 'package:flutter/material.dart';

import 'package:proj_inz/presentation/widgets/coupon_card.dart';
import 'package:proj_inz/data/models/coupon_model.dart';

class CouponsScreen extends StatelessWidget {
  const CouponsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Coupons'),
      ),
      body: Center(
        child: ListView.separated(
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) => CouponHorizontalCard(
            coupon: Coupon(
              id: '0',
              reduction: 50.5, 
              reductionIsPercentage: false, 
              price: 30, 
              shopName: 'MediaMarkt', 
              shopNameColor: Colors.white, 
              shopBgColor: Colors.red, 
              hasLimits: false,
              sellerId: '0',
              sellerReputation: 90,
              sellerUsername: 'Jan Kowalski', 
              isOnline: true, 
              expiryDate: DateTime(2025, 12, 31)
            )
          ),
          itemCount: 10,
        )
      ),
    );
  }
}