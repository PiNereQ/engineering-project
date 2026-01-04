import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:proj_inz/bloc/saved_coupon_list/saved_coupon_list_bloc.dart';
import 'package:proj_inz/core/app_flags.dart';
import 'package:proj_inz/core/errors/error_messages.dart';
import 'package:proj_inz/core/theme.dart';
import 'package:proj_inz/core/utils/error_mapper.dart';
import 'package:proj_inz/main.dart';
import 'package:proj_inz/presentation/widgets/coupon_card.dart';
import 'package:proj_inz/presentation/widgets/error_card.dart';
import 'package:proj_inz/presentation/widgets/input/buttons/checkbox.dart';
import 'package:proj_inz/presentation/widgets/input/buttons/custom_icon_button.dart';
import 'package:proj_inz/presentation/widgets/input/buttons/custom_text_button.dart';
import 'package:proj_inz/presentation/widgets/input/buttons/radio_button.dart';
import 'package:proj_inz/presentation/widgets/input/text_fields/labeled_text_field.dart';
import 'package:proj_inz/core/utils/text_formatters.dart';

class SavedCouponListScreen extends StatefulWidget {
  const SavedCouponListScreen({super.key});

  @override
  State<SavedCouponListScreen> createState() => _SavedCouponListScreenState();
}

class _SavedCouponListScreenState extends State<SavedCouponListScreen> with RouteAware {
  final ScrollController _scrollController = ScrollController();
  bool _listenerAdded = false;
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)! as PageRoute);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _scrollController.dispose();
    super.dispose();
  }
  
  @override
  void didPopNext() {
    if (!AppFlags.couponBought) return;

    AppFlags.couponBought = false;

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    context
        .read<SavedCouponListBloc>()
        .add(RefreshSavedCoupons(userId: userId));
  }

  void _setupListener(BuildContext context) {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 150) {
        context.read<SavedCouponListBloc>().add(FetchMoreSavedCoupons());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return BlocBuilder<SavedCouponListBloc, SavedCouponListState>(
      builder: (context, state) {
        if (!_listenerAdded) {
          _setupListener(context);
          _listenerAdded = true;
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: () async {
                context
                    .read<SavedCouponListBloc>()
                    .add(RefreshSavedCoupons(userId: userId));
              },
              child: CustomScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: const [
                  _Toolbar(),
                  _SavedCouponsContent(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SavedCouponsContent extends StatelessWidget {
  const _SavedCouponsContent();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SavedCouponListBloc, SavedCouponListState>(
      builder: (context, state) {
        if (state is SavedCouponListLoadInProgress && (state.coupons == null || state.coupons!.isEmpty)) {
          return const SliverFillRemaining(
            child: Center(
              child: CircularProgressIndicator(color: AppColors.textPrimary),
            ),
          );
        }

        if (state is SavedCouponListLoadEmpty) {
          return const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Nie masz jeszcze zapisanych kuponów.\n"
                      "Aby zapisać kupon na później, "
                      "przejdź do zakładki \"Kupony\" "
                      "i kliknij ikonę zapisu przy ofercie.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontFamily: 'Itim',
                        fontWeight: FontWeight.w400,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (state is SavedCouponListLoadFailure) {
          if (kDebugMode) debugPrint(state.message);
          final type = mapErrorToType(state.message);
          final userMessage = couponListErrorMessage(type);

          return SliverFillRemaining(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ErrorCard(
                  icon: const Icon(Icons.sentiment_dissatisfied_rounded),
                  text: userMessage,
                  errorString: state.message,
                ),
              ),
            ),  
          );
        }

        if (state is SavedCouponListLoadSuccess || (state is SavedCouponListLoadInProgress && state.coupons != null)) {
          final coupons = state is SavedCouponListLoadSuccess ? state.coupons : (state as SavedCouponListLoadInProgress).coupons!;
          
          return SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final coupon = coupons[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: CouponCardHorizontal(coupon: coupon),
                  );
                },
                childCount: coupons.length,
              ),
            ),
          );
        }

        return const SliverFillRemaining();
      },
    );
  }
}

class _Toolbar extends StatelessWidget {
  const _Toolbar();

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      floating: true,
      snap: true,
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
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
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomIconButton(
                icon: SvgPicture.asset('assets/icons/back.svg'),
                onTap: () => Navigator.of(context).pop(),
              ),
              Row(
                children: [
                  CustomTextButton.small(
                    label: 'Filtruj',
                    icon: const Icon(Icons.filter_alt),
                    onTap: () => showDialog(
                      context: context,
                      barrierColor: AppColors.popupOverlay,
                      builder: (_) => BlocProvider.value(
                        value: context.read<SavedCouponListBloc>(),
                        child: const _SavedCouponFilterDialog(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  CustomTextButton.small(
                    label: 'Sortuj',
                    icon: const Icon(Icons.sort),
                    onTap: () => showDialog(
                      context: context,
                      barrierColor: AppColors.popupOverlay,
                      builder: (_) => BlocProvider.value(
                        value: context.read<SavedCouponListBloc>(),
                        child: const _SavedCouponSortDialog(),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      toolbarHeight: 126,
    );
  }
}

class _SavedCouponFilterDialog extends StatefulWidget {
  const _SavedCouponFilterDialog();

  @override
  State<_SavedCouponFilterDialog> createState() => _SavedCouponFilterDialogState();
}

class _SavedCouponFilterDialogState extends State<_SavedCouponFilterDialog> {
  TextEditingController minPriceController = TextEditingController();
  TextEditingController maxPriceController = TextEditingController();

  bool reductionIsPercentage = true;
  bool reductionIsFixed = true;
  String? shopId;
  double minReputation = 0;

  @override
  void initState() {
    super.initState();
    // Read current filter state
    context.read<SavedCouponListBloc>().add(ReadSavedCouponFilters());
  }

  @override
  void dispose() {
    minPriceController.dispose();
    maxPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SavedCouponListBloc, SavedCouponListState>(
      listener: (context, state) {
        if (state is SavedCouponFilterRead) {
          setState(() {
            reductionIsPercentage = state.reductionIsPercentage ?? true;
            reductionIsFixed = state.reductionIsFixed ?? true;
            shopId = state.shopId;
            minReputation = state.minReputation ?? 0;
          });
          // Set price controller values
          if (state.minPrice != null) {
            minPriceController.text = state.minPrice!.toStringAsFixed(2);
          } else {
            minPriceController.clear();
          }
          if (state.maxPrice != null) {
            maxPriceController.text = state.maxPrice!.toStringAsFixed(2);
          } else {
            maxPriceController.clear();
          }
        }
      },
      child: Material(
        color: Colors.transparent,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
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
                        }
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16,),
                Container(
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
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 18,
                    children: [
                        const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Filtry',
                          style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 24,
                          fontFamily: 'Itim',
                          fontWeight: FontWeight.w400,
                          ),
                        ),
                        ),
                        const Divider(
                        color: AppColors.textPrimary,
                        thickness: 2,
                        height: 2,
                        ),
                
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          spacing: 8,
                          children: [
                            Column( // Typy
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                      'Typ kuponu',
                                      style: TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 20,
                                          fontFamily: 'Itim',
                                          fontWeight: FontWeight.w400,
                                      ),
                                  )
                                ),
                                CustomCheckbox(
                                  selected: reductionIsPercentage,
                                  onTap:
                                      () => setState(
                                        () => reductionIsPercentage = !reductionIsPercentage,
                                      ),
                                  label: 'rabat -%',
                                ),
                                CustomCheckbox(
                                  selected: reductionIsFixed,
                                  onTap: () => setState(() => reductionIsFixed = !reductionIsFixed),
                                  label: 'rabat -zł',
                                ),
                              ],
                            ),

                            const SizedBox(height: 10),

                            Column( // Cena
                              children: [
                                const Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                      'Cena',
                                      style: TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 20,
                                          fontFamily: 'Itim',
                                          fontWeight: FontWeight.w400,
                                      ),
                                  )
                                ),
                                Wrap(
                                  spacing: 16,
                                  runSpacing: 16,
                                  children: [
                                    LabeledTextField(
                                      label: 'od',
                                      placeholder: '0',
                                      width: LabeledTextFieldWidth.half,
                                      controller: minPriceController,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [PriceFormatter()],
                                      suffix: const Text('zł'),
                                    ),
                                    LabeledTextField(
                                      label: 'do',
                                      placeholder: 'bez limitu',
                                      width: LabeledTextFieldWidth.half,
                                      controller: maxPriceController,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [PriceFormatter()],
                                      suffix: const Text('zł'),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),

                            Column( // Reputacja
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Min. reputacja sprzedającego',
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 20,
                                    fontFamily: 'Itim',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Slider(
                                        value: minReputation,
                                        min: 0,
                                        max: 100,
                                        divisions: 20,
                                        activeColor: AppColors.primaryButton,
                                        inactiveColor: AppColors.secondaryButton,
                                        label: minReputation.round().toString(),
                                        onChanged: (v) {
                                          setState(() {
                                            minReputation = v;
                                          });
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Container(
                                      width: 44,
                                      alignment: Alignment.center,
                                      padding: const EdgeInsets.symmetric(vertical: 6),
                                      decoration: ShapeDecoration(
                                        color: AppColors.surface,
                                        shape: RoundedRectangleBorder(
                                          side: const BorderSide(width: 2),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        shadows: const [
                                          BoxShadow(
                                            color: AppColors.textPrimary,
                                            blurRadius: 0,
                                            offset: Offset(2, 2),
                                          ),
                                        ],
                                      ),
                                      child: Text(
                                        minReputation.round().toString(),
                                        style: const TextStyle(
                                          fontFamily: 'Itim',
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            CustomTextButton(
                              label: 'Wyczyść',
                              icon: const Icon(Icons.delete_outline),
                              onTap: () {
                                Navigator.of(context).pop();
                                context.read<SavedCouponListBloc>().add(ClearSavedCouponFilters());
                              },
                            ),
                            CustomTextButton.primary(
                              label: 'Zastosuj',
                              icon: const Icon(Icons.check),
                              onTap: () {
                                Navigator.of(context).pop();
                                context.read<SavedCouponListBloc>().add(
                                  ApplySavedCouponFilters(
                                    reductionIsFixed: reductionIsFixed,
                                    reductionIsPercentage: reductionIsPercentage,
                                    shopId: shopId,
                                    minPrice: minPriceController.text.isEmpty ? null : double.tryParse(minPriceController.text.replaceAll(',', '.')),
                                    maxPrice: maxPriceController.text.isEmpty ? null : double.tryParse(maxPriceController.text.replaceAll(',', '.')),
                                    minReputation: minReputation.round().toDouble(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
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

class _SavedCouponSortDialog extends StatefulWidget {
  const _SavedCouponSortDialog();

  @override
  State<_SavedCouponSortDialog> createState() => _SavedCouponSortDialogState();
}

class _SavedCouponSortDialogState extends State<_SavedCouponSortDialog> {

  SavedCouponsOrdering ordering = SavedCouponsOrdering.saveDateDesc;

  @override
  void initState() {
    super.initState();
    // Read current ordering state
    context.read<SavedCouponListBloc>().add(ReadSavedCouponOrdering());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SavedCouponListBloc, SavedCouponListState>(
      listener: (context, state) {
        if (state is SavedCouponOrderingRead) {
          setState(() {
            ordering = state.ordering;
          });
        }
      },
      child: Material(
        color: Colors.transparent,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
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
                        }
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16,),
                Container(
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
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 18,
                    children: [
                        const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Sortowanie',
                          style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 24,
                          fontFamily: 'Itim',
                          fontWeight: FontWeight.w400,
                          ),
                        ),
                        ),
                        const Divider(
                        color: AppColors.textPrimary,
                        thickness: 2,
                        height: 2,
                        ),
                
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          spacing: 8,
                          children: [
                            Column( // Data zapisania
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                      'Data zapisania',
                                      style: TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 20,
                                          fontFamily: 'Itim',
                                          fontWeight: FontWeight.w400,
                                      ),
                                  )
                                ),
                                CustomRadioButton(
                                  label: 'od najnowszych',
                                  selected: (ordering == SavedCouponsOrdering.saveDateDesc),
                                  onTap: () => setState(() {ordering = SavedCouponsOrdering.saveDateDesc;}),
                                ),
                                CustomRadioButton(
                                  label: 'od najstarszych',
                                  selected: (ordering == SavedCouponsOrdering.saveDateAsc),
                                  onTap: () => setState(() {ordering = SavedCouponsOrdering.saveDateAsc;}),
                                )
                              ],
                            ),

                            const SizedBox(height: 10),

                            Column( // Data dodania
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                      'Data dodania',
                                      style: TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 20,
                                          fontFamily: 'Itim',
                                          fontWeight: FontWeight.w400,
                                      ),
                                  )
                                ),
                                CustomRadioButton(
                                  label: 'od najnowszych',
                                  selected: (ordering == SavedCouponsOrdering.creationDateDesc),
                                  onTap: () => setState(() {ordering = SavedCouponsOrdering.creationDateDesc;}),
                                ),
                                CustomRadioButton(
                                  label: 'od najstarszych',
                                  selected: (ordering == SavedCouponsOrdering.creationDateAsc),
                                  onTap: () => setState(() {ordering = SavedCouponsOrdering.creationDateAsc;}),
                                )
                              ],
                            ),
                            Column( // Cena
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                      'Cena',
                                      style: TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 20,
                                          fontFamily: 'Itim',
                                          fontWeight: FontWeight.w400,
                                      ),
                                  )
                                ),
                                CustomRadioButton(
                                  label: 'od najniższej',
                                  selected: (ordering == SavedCouponsOrdering.priceAsc),
                                  onTap: () => setState(() {ordering = SavedCouponsOrdering.priceAsc;}),
                                ),
                                CustomRadioButton(
                                  label: 'od najwyższej',
                                  selected: (ordering == SavedCouponsOrdering.priceDesc),
                                  onTap: () => setState(() {ordering = SavedCouponsOrdering.priceDesc;}),
                                )
                              ],
                            ),
                            Column( // Reputacja
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                      'Reputacja sprzedającego',
                                      style: TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 20,
                                          fontFamily: 'Itim',
                                          fontWeight: FontWeight.w400,
                                      ),
                                  )
                                ),
                                CustomRadioButton(
                                  label: 'od najniższej',
                                  selected: (ordering == SavedCouponsOrdering.reputationAsc),
                                  onTap: () => setState(() {ordering = SavedCouponsOrdering.reputationAsc;}),
                                ),
                                CustomRadioButton(
                                  label: 'od najwyższej',
                                  selected: (ordering == SavedCouponsOrdering.reputationDesc),
                                  onTap: () => setState(() {ordering = SavedCouponsOrdering.reputationDesc;}),
                                )
                              ],
                            ),
                            Column( // Data ważności
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                      'Data ważności',
                                      style: TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 20,
                                          fontFamily: 'Itim',
                                          fontWeight: FontWeight.w400,
                                      ),
                                  )
                                ),
                                CustomRadioButton(
                                  label: 'od najbliższej',
                                  selected: (ordering == SavedCouponsOrdering.expiryDateAsc),
                                  onTap: () => setState(() {ordering = SavedCouponsOrdering.expiryDateAsc;}),
                                ),
                                CustomRadioButton(
                                  label: 'od najdalszej',
                                  selected: (ordering == SavedCouponsOrdering.expiryDateDesc),
                                  onTap: () => setState(() {ordering = SavedCouponsOrdering.expiryDateDesc;}),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            CustomTextButton.primary(
                              label: 'Zastosuj',
                              icon: const Icon(Icons.check),
                              onTap: () {                    
                                Navigator.of(context).pop();
                                context.read<SavedCouponListBloc>().add(ApplySavedCouponOrdering(ordering));
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
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