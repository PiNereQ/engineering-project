import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:proj_inz/bloc/owned_coupon/owned_coupon_bloc.dart';
import 'package:proj_inz/core/utils/utils.dart';
import 'package:proj_inz/data/models/owned_coupon_model.dart';
import 'package:proj_inz/data/repositories/coupon_repository.dart';
import 'package:proj_inz/presentation/widgets/error_card.dart';
import 'package:proj_inz/presentation/widgets/input/buttons/custom_icon_button.dart';
import 'package:proj_inz/presentation/widgets/input/buttons/custom_text_button.dart';
import 'package:qr_flutter/qr_flutter.dart';

class BoughtCouponDetailsScreen extends StatelessWidget {
  final String couponId;
  
  const BoughtCouponDetailsScreen({super.key, required this.couponId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OwnedCouponBloc(context.read<CouponRepository>(), couponId)
        ..add(FetchCouponDetails()),
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CustomIconButton(
                      icon: SvgPicture.asset('assets/icons/back.svg'),
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    CustomIconButton(
                      icon: SvgPicture.asset('assets/icons/share.svg'),
                      onTap: () {},
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16,),
              BlocBuilder<OwnedCouponBloc, OwnedCouponState>(
                builder: (context, state) {
                  if (state is OwnedCouponLoadInProgress) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is OwnedCouponLoadSuccess) {
                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          Container(
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
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.redeem_outlined,
                                  color: Colors.black,
                                  size: 32,
                                  ),
                                SizedBox(width: 16,),
                                Text(
                                  "Ten kupon należy do Ciebie!",
                                  style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                  fontFamily: 'Itim',
                                  fontWeight: FontWeight.w400,
                                  height: 1.2,
                                  ),
                                ),
                              ],
                            )
                          ),
                          const SizedBox(height: 24,),
                          _CouponDetails(coupon: state.coupon,),
                          const SizedBox(height: 24),
                          _SellerDetails(
                            sellerId: state.coupon.sellerId,
                            sellerUsername: state.coupon.sellerUsername.toString(),
                            sellerReputation: state.coupon.sellerReputation,
                            sellerJoinDate: state.coupon.sellerJoinDate ?? DateTime(1970, 1, 1),
                          ),
                        ],
                      ),
                    );
                  }
                  else if (state is OwnedCouponLoadFailure) {
                    if (kDebugMode) debugPrint(state.message);
                    return Expanded(
                      child: Center(
                        child: ErrorCard(
                          text: "Przykro nam, wystąpił błąd w trakcie ładowania tego kuponu.",
                          errorString: state.message,
                          icon: const Icon(Icons.sentiment_dissatisfied),
                        ),
                      ),
                    );
                  }
                  return const SizedBox();
                }
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class _CouponDetails extends StatelessWidget {
  const _CouponDetails({
    required this.coupon,
  });

  final OwnedCoupon coupon;

  @override
  Widget build(BuildContext context) {
    final Color shopBgColor = coupon.shopBgColor;
    final String shopName = coupon.shopName;
    final Color shopNameColor = coupon.shopNameColor;
    final num reduction = coupon.reduction;
    final bool reductionIsPercentage = coupon.reductionIsPercentage;
    final num price = coupon.price;
    final bool hasLimits = coupon.hasLimits;
    final bool worksOnline = coupon.worksOnline;
    final bool worksInStore = coupon.worksInStore;
    final DateTime expiryDate = coupon.expiryDate;
    final String? description = coupon.description;
    final String code = coupon.code; 
    
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
      worksInStore && worksOnline
        ? 'stacjonarnie i online'  
        : worksOnline
          ? 'w sklepach internetowych'
          : 'w sklepach online',
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
              spacing: 4,
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
                  height: 8,
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
                  height: 8,
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
                  height: 8,
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
                  description ?? 'brak',
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
          const Divider(
            height: 32,
            color: Colors.black,
            thickness: 2,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: 18,
            children: [
              const Text(
                'Gotowy do wykorzystania!',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontFamily: 'Itim',
                    fontWeight: FontWeight.w400,
                    height: 0.75,
                ),
              ),
              CustomTextButton(
                label: 'Wyświetl kod',
                onTap: () => _showCodeDialog(context, code),
              )
            ],
          )
        ],
      ),
    );
  }

  _showCodeDialog(BuildContext context, String code) {
    return showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Container(
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
                ),
              ],
            ),
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: 18,
              children: [
                SizedBox(
                  height: 200,
                  width: 200,
                  child: QrImageView(
                    data: code,
                    version: QrVersions.auto,
                    size: 200.0,
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    await Clipboard.setData(ClipboardData(text: code));
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Skopiowano kod do schowka')),
                      );
                    }
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    spacing: 8,
                    children: [
                      Text(
                        code,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontFamily: 'Roboto Mono',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Icon(
                        Icons.copy_rounded,
                        size: 32,
                      )
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomTextButton(
                      label: 'Wróć',
                      onTap: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }
    );
  }
}



class _SellerDetails extends StatelessWidget {
  const _SellerDetails({
    required this.sellerId,
    required this.sellerUsername,
    required this.sellerReputation,
    required this.sellerJoinDate,
  });

  final String sellerId;
  final String sellerUsername;
  final num sellerReputation;
  final DateTime sellerJoinDate;

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
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'O sprzedającym',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontFamily: 'Itim',
                fontWeight: FontWeight.w400,
                height: 0.75,
              ),
            ),
          ),
          Row(
            spacing: 16,
            children: [
              const CircleAvatar(
                radius: 35,
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 8,
                  children: [
                    Text(
                      sellerUsername,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontFamily: 'Itim',
                        fontWeight: FontWeight.w400,
                        height: 0.75,
                      ),
                    ),
                    Text(
                      sellerReputation.toString(),
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontFamily: 'Itim',
                        fontWeight: FontWeight.w400,
                        height: 0.75,
                      ),
                    ),
                    Text(
                      'Na Coupidynie od ${sellerJoinDate.day}.${sellerJoinDate.month}.${sellerJoinDate.year} r.',
                      style: const TextStyle(
                        color: Color(0xFF646464),
                        fontSize: 16,
                        fontFamily: 'Itim',
                        fontWeight: FontWeight.w400,
                        height: 0.75,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}