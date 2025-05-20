import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:proj_inz/bloc/coupon/coupon_bloc.dart';
import 'package:proj_inz/core/utils.dart';
import 'package:proj_inz/data/repositories/coupon_repository.dart';

class CouponDetailsScreen extends StatelessWidget {
  final String couponId;
  
  const CouponDetailsScreen({super.key, required this.couponId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CouponBloc(context.read<CouponRepository>(), couponId)
        ..add(FetchCouponDetails()),
      child: Scaffold(
        body: BlocBuilder<CouponBloc, CouponState>(
          builder: (context, state) {
            


            if (state is CouponLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is CouponLoaded) {
              return Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          TextButton(
                            onPressed: () {
                            Navigator.of(context).pop();
                            },
                            child: const Text('back'),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: const Text('share'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16,),
                    Text('id: $couponId'),
                    CouponDetails(
                      couponId: state.coupon.id,
                      shopName: state.coupon.shopName,
                      shopNameColor: state.coupon.shopNameColor,
                      shopBgColor: state.coupon.shopBgColor,
                      reduction: state.coupon.reduction,
                      reductionIsPercentage: state.coupon.reductionIsPercentage,
                      price: state.coupon.price,
                      hasLimits: state.coupon.hasLimits,
                      isOnline: state.coupon.isOnline,
                      expiryDate: state.coupon.expiryDate,
                      description: state.coupon.description,
                    ),
                    const SizedBox(height: 24),
                    SellerDetails(),
                  ],
                ));
            }
            else if (state is CouponError) {
              return Center(child: Text('Error: ${state.message}'));
            }
            return const Center(child: Text('Oops'));
          }
        ),
      ),
    );
  }
}


class CouponDetails extends StatelessWidget {
  const CouponDetails({
    super.key,
    required this.couponId,
    required this.shopBgColor,
    required this.shopName,
    required this.shopNameColor,
    required this.reduction,
    required this.reductionIsPercentage,
    required this.price,
    required this.hasLimits,
    required this.isOnline,
    required this.expiryDate,
    this.description,
  });

  final String couponId;
  final Color shopBgColor;
  final String shopName;
  final Color shopNameColor;
  final num reduction;
  final bool reductionIsPercentage;
  final num price;
  final bool hasLimits;
  final bool isOnline;
  final DateTime expiryDate;
  final String? description;

  @override
  Widget build(BuildContext context) {
    final reductionText = isInteger(reduction)
    ? reduction.toString()
    : reductionIsPercentage
      ? reduction.toString().replaceAll('.', ',')
      : reduction.toStringAsFixed(2).replaceAll('.', ',');

    final titleText = TextSpan(
      text: reductionIsPercentage 
      ? 'Kupon -$reductionText%'
      : 'Kupon na $reductionText zł',
      style: const TextStyle(
      color: Colors.black,
      fontSize: 30,
      fontFamily: 'Itim',
      fontWeight: FontWeight.w400,
      height: 1
      ),
    );

    final priceText = TextSpan(
      children: [
        const TextSpan(
          text: "Cena: ",
          style: TextStyle(
            color: Color(0xFF646464),
            fontSize: 24,
            fontFamily: 'Itim',
            fontWeight: FontWeight.w400,
            height: 1
          ),
        ),
        TextSpan(
          text: "$price zł",
          style: const TextStyle(
            color: Colors.black,
            fontSize: 28,
            fontFamily: 'Itim',
            fontWeight: FontWeight.w400,
            height: 1
          ),
        )
      ],
    );

    final limitsText = Text(
      hasLimits ? 'tak (w opisie)' : 'nie',
      style: const TextStyle(
        color: Color(0xFF646464),
        fontSize: 18,
        fontFamily: 'Itim',
        fontWeight: FontWeight.w400,
        height: 0.83,
      ),
    );

    final locationText = Text(
      isOnline ? 'sklepy intenetowe' : 'sklepy stacjonarne',
      style: const TextStyle(
        color: Color(0xFF646464),
        fontSize: 18,
        fontFamily: 'Itim',
        fontWeight: FontWeight.w400,
        height: 0.83,
      ),
    );

    final expiryDateText = Text(
      '${expiryDate.day}.${expiryDate.month}.${expiryDate.year} r.',
      style: const TextStyle(
        color: Color(0xFF646464),
        fontSize: 18,
        fontFamily: 'Itim',
        fontWeight: FontWeight.w400,
        height: 0.83,
      ),
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 2),
          borderRadius: BorderRadius.circular(24),
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
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 90.0,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: ShapeDecoration(
              color: shopBgColor,
              shape: RoundedRectangleBorder(
                side: const BorderSide(width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 10.0, 0.0, 10.0),
              child: Text(
                shopName,
                style: TextStyle(
                  color: shopNameColor,
                  fontSize: 30,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w700,
                )
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text.rich(titleText),
                ),
                const SizedBox(height: 8,),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text.rich(priceText),
                ),
              ],
            ),
          ),
          const Divider(
            color: Colors.black,
            thickness: 2,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children:[
                const Text(
                  'Szczegóły',
                  style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontFamily: 'Itim',
                  fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Gdzie działa:',
                        style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontFamily: 'Itim',
                        fontWeight: FontWeight.w400,
                        height: 0.83,
                        ),
                      ),
                      locationText
                    ],
                  ),
                ),
                const Divider(
                  color: Colors.black,
                  thickness: 1,
                ),
                SizedBox(
                  width: double.infinity,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Ograniczenia:',
                        style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontFamily: 'Itim',
                        fontWeight: FontWeight.w400,
                        height: 0.83,
                        ),
                      ),
                      limitsText
                    ],
                  ),
                ),
                const Divider(
                  color: Colors.black,
                  thickness: 1,
                ),
                SizedBox(
                  width: double.infinity,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Ważny do:',
                        style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontFamily: 'Itim',
                        fontWeight: FontWeight.w400,
                        height: 0.83,
                        ),
                      ),
                      expiryDateText
                    ],
                  ),
                ),
                const Divider(
                  color: Colors.black,
                  thickness: 1,
                ),
                const Text(
                  'Opis:',
                  style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontFamily: 'Itim',
                  fontWeight: FontWeight.w400,
                  height: 0.83,
                  ),
                ),
                Text(
                  description.toString(),
                  style: const TextStyle(
                    color: Color(0xFF646464),
                    fontSize: 18,
                    fontFamily: 'Itim',
                    fontWeight: FontWeight.w400,
                    height: 0.83,
                  ),
                ),
              ]
            ),
          ),
        ],
      ),
    );
  }
}

class SellerDetails extends StatelessWidget {
  const SellerDetails({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 2),
          borderRadius: BorderRadius.circular(24),
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
      child: Column(
        children: [
          const Text('Seller:'),
        ],
      ),
    );
  }
}
