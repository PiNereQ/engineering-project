import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:proj_inz/bloc/listed_coupon/listed_coupon_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:proj_inz/core/theme.dart';
import 'package:proj_inz/core/utils/utils.dart';
import 'package:proj_inz/data/models/coupon_model.dart';
import 'package:proj_inz/data/repositories/coupon_repository.dart';
import 'package:proj_inz/presentation/widgets/custom_snack_bar.dart';
import 'package:proj_inz/presentation/widgets/dashed_separator.dart';
import 'package:proj_inz/presentation/widgets/error_card.dart';
import 'package:proj_inz/presentation/widgets/input/buttons/custom_icon_button.dart';
import 'package:proj_inz/presentation/widgets/input/buttons/custom_text_button.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ListedCouponDetailsScreen extends StatelessWidget {
  final String couponId;
  
  const ListedCouponDetailsScreen({super.key, required this.couponId});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    return BlocProvider(
      create: (context) => ListedCouponBloc(context.read<CouponRepository>(), couponId)
        ..add(FetchCouponDetails(userId: userId)),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              Divider(height: 0, color: AppColors.textSecondary,),
              Expanded(
                child: SingleChildScrollView(
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
                            ],
                          ),
                        ),
                        const SizedBox(height: 16,),
                        BlocBuilder<ListedCouponBloc, ListedCouponState>(
                          builder: (context, state) {
                            if (state is ListedCouponLoadInProgress) {
                              return const Center(child: CircularProgressIndicator());
                            } else if (state is ListedCouponLoadSuccess) {
                              return Column(
                                children: [
                                  _CouponDetails(coupon: state.coupon),
                                ],
                              );
                            }
                            else if (state is ListedCouponLoadFailure) {
                              if (kDebugMode) debugPrint(state.message);
                              return Center(
                                child: ErrorCard(
                                  text: "Przykro nam, wystąpił błąd w trakcie ładowania tego kuponu.",
                                  errorString: state.message,
                                  icon: const Icon(Icons.sentiment_dissatisfied),
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

  final Coupon coupon;

  @override
  Widget build(BuildContext context) {
    final Color shopBgColor = coupon.shopBgColor;
    final String shopName = coupon.shopName;
    final Color shopNameColor = coupon.shopNameColor;
    final num reduction = coupon.reduction;
    final bool reductionIsPercentage = coupon.reductionIsPercentage;
    final int price = coupon.price;
    final bool hasLimits = coupon.hasLimits;
    final bool worksOnline = coupon.worksOnline;
    final bool worksInStore = coupon.worksInStore;
    final DateTime? expiryDate = coupon.expiryDate;
    final String? description = coupon.description;

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
      color: AppColors.textPrimary,
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
            color: AppColors.textSecondary,
            fontSize: 24,
            fontFamily: 'Itim',
            fontWeight: FontWeight.w400,
            height: 1
          ),
        ),
        TextSpan(
          text: "${formatPrice(price)} zł",
          style: const TextStyle(
            color: AppColors.textPrimary,
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
              : 'w sklepach stacjonarnych',
      textAlign: TextAlign.right,
      style: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 18,
        fontFamily: 'Itim',
        fontWeight: FontWeight.w400,
        height: 0.83,
      ),
    );

    final expiryDateText = Text(
      expiryDate == null ? 'brak' : formatDate(expiryDate),
      style: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 18,
        fontFamily: 'Itim',
        fontWeight: FontWeight.w400,
        height: 0.83,
      ),
    );

    return Container(
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
          )
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  height: 90.0,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: ShapeDecoration(
                    color: coupon.isSold ? AppColors.primaryButtonPressed : shopBgColor,
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
                        color: coupon.isSold ? AppColors.textSecondary : shopNameColor,
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
                  color: AppColors.textPrimary,
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
                          color: AppColors.textPrimary,
                          fontSize: 20,
                          fontFamily: 'Itim',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
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
                              const SizedBox(width: 8),
                              Expanded(
                                child: locationText,
                              ),
                            ],
                          ),
                      ),
                      const Divider(
                        height: 8,
                        color: AppColors.textPrimary,
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
                                color: AppColors.textPrimary,
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
                        color: AppColors.textPrimary,
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
                              color: AppColors.textPrimary,
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
                        color: AppColors.textPrimary,
                        thickness: 1,
                      ),
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
                    ]
                  ),
                ),
              ],
            ),
          ),
          DashedSeparator(),
                Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: 12,
                      children: [
                        CustomTextButton(
                          label: 'Wyświetl kod kuponu',
                          onTap: () {
                            _showCodeDialog(context, coupon.code!);
                          },
                        ),

                        if (!coupon.isSold)
                          CustomTextButton(
                            label: 'Usuń kupon',
                            icon: const Icon(Icons.delete_outline),
                            onTap: () => _showDeleteConfirmation(context),
                          ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteConfirmation(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(width: 2, color: AppColors.textPrimary),
        ),
        title: const Text(
          'Potwierdzenie',
          style: TextStyle(
            fontFamily: 'Itim',
            fontSize: 22,
            fontWeight: FontWeight.w400,
            color: AppColors.textPrimary,
          ),
        ),
        content: const Text(
          'Czy na pewno chcesz usunąć ten kupon?\nKupon zniknie z listy dostępnych i z Twoich wystawionych.',
          style: TextStyle(
            fontFamily: 'Itim',
            fontSize: 16,
            color: AppColors.textSecondary,
          ),
        ),
        actionsPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        actions: [
          CustomTextButton.small(
            label: 'Anuluj',
            width: 100,
            onTap: () => Navigator.of(context).pop(),
          ),
          CustomTextButton.primarySmall(
            label: 'Usuń',
            width: 100,
            onTap: () async {
              Navigator.of(context).pop();

              try {
                await context
                    .read<CouponRepository>()
                    .deactivateListedCoupon(coupon.id);

                if (context.mounted) {
                  showCustomSnackBar(
                    context,
                    'Kupon został usunięty',
                  );
                  Navigator.of(context).pop(true);
                }
              } catch (e) {
                if (context.mounted) {
                  showCustomSnackBar(
                    context,
                    'Nie udało się usunąć kuponu',
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }


  Future _showCodeDialog(BuildContext context, String code) {
    return showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Container(
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
                      showCustomSnackBar(context, 'Skopiowano kod do schowka');
                    }
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: 260,
                        ),
                        child: SelectableText(
                          code,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 20,
                            fontFamily: 'Roboto Mono',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Icon(
                        Icons.copy_rounded,
                        size: 28,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }
    );
  }
}