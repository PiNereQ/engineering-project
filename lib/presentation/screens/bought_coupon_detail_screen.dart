import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:proj_inz/bloc/owned_coupon/owned_coupon_bloc.dart';
import 'package:proj_inz/core/theme.dart';
import 'package:proj_inz/core/utils/utils.dart';
import 'package:proj_inz/data/models/coupon_model.dart';
import 'package:proj_inz/data/repositories/chat_repository.dart';
import 'package:proj_inz/data/repositories/coupon_repository.dart';
import 'package:proj_inz/data/repositories/user_repository.dart';
import 'package:proj_inz/presentation/screens/chat_detail_screen.dart';
import 'package:proj_inz/presentation/widgets/custom_snack_bar.dart';
import 'package:proj_inz/presentation/widgets/dashed_separator.dart';
import 'package:proj_inz/presentation/widgets/error_card.dart';
import 'package:proj_inz/presentation/widgets/input/buttons/custom_icon_button.dart';
import 'package:proj_inz/presentation/widgets/input/buttons/custom_text_button.dart';
import 'package:proj_inz/presentation/widgets/reputation_bar.dart';
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
                        BlocListener<OwnedCouponBloc, OwnedCouponState>(
                          listener: (context, state) {
                            if (state is OwnedCouponMarkAsUsedFailure) {
                              showCustomSnackBar(context, 'Podczas oznaczania kuponu jako wykorzystanego wystąpił błąd.');
                            }
                          },
                          child: BlocBuilder<OwnedCouponBloc, OwnedCouponState>(
                          builder: (context, state) {
                            if (state is OwnedCouponLoadInProgress) {
                              return const Center(child: CircularProgressIndicator());
                            } else if (state is OwnedCouponLoadSuccess) {
                              return Column(
                                children: [
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
                                          Icons.redeem_outlined,
                                          color: AppColors.textPrimary,
                                          size: 32,
                                          ),
                                        SizedBox(width: 16,),
                                        Text(
                                          "Ten kupon należy do Ciebie!",
                                          style: TextStyle(
                                          color: AppColors.textPrimary,
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
                                    sellerId: state.coupon.sellerId!,
                                    sellerUsername: state.coupon.sellerUsername.toString(),
                                    sellerReputation: state.coupon.sellerReputation,
                                    sellerJoinDate: state.coupon.sellerJoinDate ?? DateTime(1970, 1, 1),
                                    couponId: state.coupon.id,
                                  ),
                                ],
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
                            else if (state is OwnedCouponMarkAsUsedInProgress) {
                              // Show loading while marking as used
                              return const Center(child: CircularProgressIndicator());
                            }
                            return const SizedBox();
                          }
                        ),
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
    final String description = coupon.description;
    final String code = coupon.code!; 
    final bool isUsed = coupon.isUsed!;

    final now = DateTime.now();
    final bool isExpired = expiryDate != null &&
        now.isAfter(
          DateTime(expiryDate.year, expiryDate.month, expiryDate.day, 23, 59, 59),
        );
        
    final reductionText =
        formatReduction(reduction.toDouble(), reductionIsPercentage);

    final titleText = TextSpan(
      text: reductionIsPercentage
        ? 'Kupon -$reductionText'
        : 'Kupon na $reductionText',
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
                    color: (isUsed || isExpired) ? AppColors.primaryButtonPressed : shopBgColor,
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
                        color: (isUsed || isExpired) ? AppColors.textSecondary : shopNameColor,
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
                        (description == '') ? 'brak' : description,
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
                  icon: Icon(Icons.qr_code_rounded),
                  onTap: () => _showCodeDialog(context, code),
                ),
                isUsed
                ? Text(
                    'Ten kupon został już wykorzystany.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                      fontFamily: 'Itim',
                      fontWeight: FontWeight.w400,
                    ),
                  )
                : CustomTextButton(
                  label: "Oznacz jako wykorzystany",
                  icon: Icon(Icons.check_circle_outline_rounded),
                  onTap: () => _showMarkAsUsedDialog(context),
                ),
              ],
            ),
          )
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

  Future _showMarkAsUsedDialog(BuildContext context) {
    final bloc = context.read<OwnedCouponBloc>();

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
              children: [
                const Text(
                  'Ta akcja jest nieodwracalna. Gdy oznaczysz kupon jako wykorzystany poprosimy Cię o ocenę sprzedającego.',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontFamily: 'Itim',
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CustomTextButton(
                      label: 'Anuluj',
                      onTap: () => Navigator.of(context).pop(),
                    ),
                    CustomTextButton(
                      label: 'OK',
                      icon:
                          bloc.state is OwnedCouponMarkAsUsedInProgress
                              ? const CircularProgressIndicator(
                                color: AppColors.textPrimary,
                              )
                              : null,
                      onTap: () {
                        if (bloc.state is! OwnedCouponMarkAsUsedInProgress) {
                          bloc.add(MarkCouponAsUsed());
                          Navigator.of(context).pop();
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}



class _SellerDetails extends StatelessWidget {
  const _SellerDetails({
    required this.sellerId,
    required this.sellerUsername,
    required this.sellerReputation,
    required this.sellerJoinDate,
    required this.couponId,
  });

  final String sellerId;
  final String sellerUsername;
  final int? sellerReputation;
  final DateTime sellerJoinDate;
  final String couponId;

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
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontFamily: 'Itim',
                        fontWeight: FontWeight.w400,
                        height: 0.75,
                      ),
                    ),
                    sellerReputation == null
                      ? Text(
                        'Brak ocen',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 16,
                          fontFamily: 'Itim',
                          fontWeight: FontWeight.w400,
                          height: 0.75,
                        ),
                      )
                      : ReputationBar(
                        value: sellerReputation!,
                        maxWidth: 120,
                        height: 8,
                        showValue: true,
                      ),
                    Text(
                      'Na Coupidynie od ${formatDate(sellerJoinDate.toLocal())}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 16,
                        fontFamily: 'Itim',
                        fontWeight: FontWeight.w400,
                        height: 0.75,
                      ),
                    ),
                    SizedBox(height: 16),
                    Center(
                      child: CustomTextButton.primary(
                        label: "Zapytaj o ten kupon",
                        onTap: () async {
                          final buyerId = await context.read<UserRepository>().getCurrentUserId();

                          final sellerId = this.sellerId;
                          final couponId = this.couponId;

                          final chatRepo = context.read<ChatRepository>();

                          // check for existing conversation
                          final existing = await chatRepo.findExistingConversation(
                            couponId: couponId,
                            buyerId: buyerId,
                            sellerId: sellerId,
                          );

                          if (!context.mounted) return;

                          if (existing != null) {
                            // open existing conversation
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChatDetailScreen.fromConversation(existing),
                              ),
                            );
                          } else {
                            // create new conversation
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChatDetailScreen(
                                  initialConversation: null,
                                  buyerId: buyerId,
                                  sellerId: sellerId,
                                  couponId: couponId,
                                ),
                              ),
                            );
                          }
                        },
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