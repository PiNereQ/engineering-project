import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:proj_inz/data/models/coupon_model.dart';
import 'package:proj_inz/presentation/widgets/coupon_card.dart';
import 'package:proj_inz/presentation/widgets/dashed_separator.dart';
import 'package:proj_inz/presentation/widgets/input/buttons/custom_follow_button.dart';
import 'package:proj_inz/presentation/widgets/input/buttons/custom_icon_button.dart';
import 'package:proj_inz/presentation/widgets/input/buttons/custom_text_button.dart';
import 'package:proj_inz/presentation/widgets/input/buttons/ticket_button.dart';


class DebugScreen extends StatefulWidget {
  const DebugScreen({super.key});

  @override
  State<DebugScreen> createState() => _DebugScreenState();
}

class _DebugScreenState extends State<DebugScreen> {

  final coupon = Coupon(
    shopId: '1',
    sellerId: '1',
    isSold: false,
    id: 'debug_coupon',
    reduction: 20,
    reductionIsPercentage: true,
    price: 100,
    shopName: 'Debug Shop',
    shopNameColor: Colors.white,
    shopBgColor: Colors.blue,
    hasLimits: false,
    sellerReputation: 5,
    worksOnline: true,
    worksInStore: false,
    expiryDate: DateTime.now().add(const Duration(days: 30)),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Debug'),),
      body: SingleChildScrollView(
        child: Column(
          spacing: 8,
          children: [
            CustomTextButton(
              label: '_checkUser',
              onTap: _checkUser
            ),
            TicketButton(
              label: 'Twoje punkty',
              value: '999',
              icon: const Icon(Icons.favorite),
              onTap: () {}
            ),
            DashedSeparator(),
            CustomIconButton(icon: const Icon(Icons.texture_sharp), onTap: () {}),
            CustomIconButton.small(icon: const Icon(Icons.texture_sharp), onTap: () {}),
            CustomFollowButton(onTap: () {}),
            CustomFollowButton.small(onTap: () {}),
            CouponCardHorizontal(coupon: coupon),
            CouponCardVertical(coupon: coupon)
          ],
        ),
      )
    );
    
  }
}

void _checkUser() {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    debugPrint('Logged in user ID: ${user.uid}');
  } else {
    debugPrint('No user is currently logged in.');
  }
}