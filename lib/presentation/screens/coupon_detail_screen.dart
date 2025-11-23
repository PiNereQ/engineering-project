import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:proj_inz/bloc/coupon/coupon_bloc.dart';
import 'package:proj_inz/bloc/coupon_list/coupon_list_bloc.dart';
import 'package:proj_inz/bloc/payment/payment_bloc.dart';
import 'package:proj_inz/core/theme.dart';
import 'package:proj_inz/core/utils/utils.dart';
import 'package:proj_inz/data/models/coupon_model.dart';
import 'package:proj_inz/data/repositories/coupon_repository.dart';
import 'package:proj_inz/data/repositories/user_repository.dart';
import 'package:proj_inz/presentation/screens/bought_coupon_detail_screen.dart';
import 'package:proj_inz/presentation/widgets/custom_snack_bar.dart';
import 'package:proj_inz/presentation/widgets/dashed_separator.dart';
import 'package:proj_inz/presentation/widgets/error_card.dart';
import 'package:proj_inz/presentation/widgets/input/buttons/custom_follow_button.dart';
import 'package:proj_inz/presentation/widgets/input/buttons/custom_icon_button.dart';
import 'package:proj_inz/presentation/widgets/input/buttons/custom_text_button.dart';

class CouponDetailsScreen extends StatelessWidget {
  final String couponId;

  const CouponDetailsScreen({super.key, required this.couponId});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create:
              (context) =>
                  OwnedCouponBloc(context.read<CouponRepository>(), couponId)
                    ..add(FetchCouponDetails()),
        ),
        BlocProvider(create: (_) => PaymentBloc()),
        BlocProvider(
          create: (context) => CouponListBloc(context.read<CouponRepository>()),
        ),
      ],
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
                BlocBuilder<OwnedCouponBloc, CouponState>(
                  builder: (context, state) {
                    if (state is CouponLoadInProgress) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is CouponLoadSuccess) {
                      return SingleChildScrollView(
                        child: Column(
                          children: [
                            if (state.coupon.isSold == true) ...[
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                clipBehavior: Clip.antiAlias,
                                decoration: ShapeDecoration(
                                  color: AppColors.surface,
                                  shape: RoundedRectangleBorder(
                                    side: const BorderSide(width: 2),
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  shadows: const [
                                    BoxShadow(
                                      color: AppColors.textPrimary,
                                      blurRadius: 0,
                                      offset: Offset(4, 4),
                                      spreadRadius: 0,
                                    )
                                  ],
                                ),
                                child: const Row(
                                  children: [
                                    Icon(
                                      Icons.report_outlined,
                                      color: AppColors.alertText,
                                      size: 32,
                                      ),
                                    SizedBox(width: 16,),
                                    Text(
                                      "Oferta sprzedaży tego kuponu\nzostała zakończona.",
                                      style: TextStyle(
                                      color: AppColors.alertText,
                                      fontSize: 18,
                                      fontFamily: 'Itim',
                                      fontWeight: FontWeight.w400,
                                      height: 1.2,
                                      ),
                                    ),
                                  ],
                                )
                              ),
                              const SizedBox(height: 24,)
                            ],
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
                    else if (state is CouponLoadFailure) {
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
      ),
    );
  }
}

class _CouponDetails extends StatelessWidget {
  const _CouponDetails({required this.coupon});

  final Coupon coupon;

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
    final bool isSold = coupon.isSold;

    final reductionText =
        isInteger(reduction)
            ? reduction.toString()
            : reductionIsPercentage
            ? reduction.toString().replaceAll('.', ',')
            : reduction.toStringAsFixed(2).replaceAll('.', ',');

    final titleText = TextSpan(
      text:
          reductionIsPercentage
              ? 'Kupon -$reductionText%'
              : 'Kupon na $reductionText zł',
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 30,
        fontFamily: 'Itim',
        fontWeight: FontWeight.w400,
        height: 1,
      ),
    );

    final priceText = TextSpan(
      children: [
        const TextSpan(
          text: "Cena: ",
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 24,
            fontFamily: 'Itim',
            fontWeight: FontWeight.w400,
            height: 1,
          ),
        ),
        TextSpan(
          text: "$price zł",
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 28,
            fontFamily: 'Itim',
            fontWeight: FontWeight.w400,
            height: 1,
          ),
        ),
      ],
    );

    final limitsText = Text(
      hasLimits ? 'tak (w opisie)' : 'nie',
      style: const TextStyle(
        color: AppColors.textSecondary,
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
        color: AppColors.textSecondary,
        fontSize: 18,
        fontFamily: 'Itim',
        fontWeight: FontWeight.w400,
        height: 0.83,
      ),
    );

    final expiryDateText = Text(
      '${expiryDate.day}.${expiryDate.month}.${expiryDate.year} r.',
      style: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 18,
        fontFamily: 'Itim',
        fontWeight: FontWeight.w400,
        height: 0.83,
      ),
    );

    return BlocListener<PaymentBloc, PaymentState>(
      listener: (context, state) async {
        if (state is PaymentInProgress) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => const Center(child: CircularProgressIndicator(color: AppColors.surface,)),
          );
        } else if (state is PaymentSuccess) {
          Navigator.of(context, rootNavigator: true).pop();
          showCustomSnackBar(context, 'Płatność zakończona sukcesem!');
          final user = await getCurrentUser();
          if (context.mounted) {
            context.read<OwnedCouponBloc>().add(
              BuyCouponRequested(couponId: coupon.id, userId: user.uid),
            );
            
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
              builder: (_) => BoughtCouponDetailsScreen(couponId: coupon.id),
              ),
            );
            context.read<CouponListBloc>().add(RefreshCoupons()); // TODO: add listener for success state so the refresh is run after backend change
          }
          
        } else if (state is PaymentFailure) {
          Navigator.of(context, rootNavigator: true).pop();
          showCustomSnackBar(context, state.error);
        }
      },
      child: Container(
        width: double.infinity,
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(
          color: AppColors.surface,
          shape: RoundedRectangleBorder(
            side: const BorderSide(width: 2),
            borderRadius: BorderRadius.circular(24),
          ),
          shadows: const [
            BoxShadow(
              color: AppColors.textPrimary,
              blurRadius: 0,
              offset: Offset(4, 4),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          children: [
           
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                   // Sklep
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
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Tytuł, cena
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
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text.rich(priceText),
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: AppColors.textPrimary, thickness: 2),
                  // Szczegóły
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 4,
                      children: [
                        const Text(
                          'Szczegóły',
                          style: TextStyle(
                            color: AppColors.textPrimary,
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
                                  color: AppColors.textPrimary,
                                  fontSize: 18,
                                  fontFamily: 'Itim',
                                  fontWeight: FontWeight.w400,
                                  height: 0.83,
                                ),
                              ),
                              locationText,
                            ],
                          ),
                        ),
                        const Divider(height: 8, color: AppColors.textPrimary, thickness: 1),
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
                                  color: AppColors.textPrimary,
                                  fontSize: 18,
                                  fontFamily: 'Itim',
                                  fontWeight: FontWeight.w400,
                                  height: 0.83,
                                ),
                              ),
                              limitsText,
                            ],
                          ),
                        ),
                        const Divider(height: 8, color: AppColors.textPrimary, thickness: 1),
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
                                  color: AppColors.textPrimary,
                                  fontSize: 18,
                                  fontFamily: 'Itim',
                                  fontWeight: FontWeight.w400,
                                  height: 0.83,
                                ),
                              ),
                              expiryDateText,
                            ],
                          ),
                        ),
                        const Divider(height: 8, color: AppColors.textPrimary, thickness: 1),
                        const Text(
                          'Opis:',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 18,
                            fontFamily: 'Itim',
                            fontWeight: FontWeight.w400,
                            height: 0.83,
                          ),
                        ),
                        Text(
                          (description == null || description == '') ? 'brak' : description,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 18,
                            fontFamily: 'Itim',
                            fontWeight: FontWeight.w400,
                            height: 0.83,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (!isSold) ...[
              DashedSeparator(),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  spacing: 16,
                  children: [
                    CustomTextButton.primary(
                      label: 'Kup teraz',
                      onTap: () async {
                        context.read<PaymentBloc>().add(
                          StartPayment(
                            amount: (coupon.price * 100).toInt(),
                            ),
                        );
                      },
                    ),
                    CustomFollowButton(onTap: () {})
                  ],
                ),
              ),
            ],    
          ],
        ),
      ),
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
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 2),
          borderRadius: BorderRadius.circular(24),
        ),
        shadows: const [
          BoxShadow(
            color: AppColors.textPrimary,
            blurRadius: 0,
            offset: Offset(4, 4),
            spreadRadius: 0,
          ),
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
                color: AppColors.textPrimary,
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
              const CircleAvatar(radius: 35),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 8,
                  children: [
                    Text(
                      sellerUsername,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontFamily: 'Itim',
                        fontWeight: FontWeight.w400,
                        height: 0.75,
                      ),
                    ),
                    Text(
                      sellerReputation.toString(),
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontFamily: 'Itim',
                        fontWeight: FontWeight.w400,
                        height: 0.75,
                      ),
                    ),
                    Text(
                      'Na Coupidynie od ${sellerJoinDate.day}.${sellerJoinDate.month}.${sellerJoinDate.year} r.',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
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
          ),
        ],
      ),
    );
  }
}
