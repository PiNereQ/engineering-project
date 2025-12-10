import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:proj_inz/bloc/owned_coupon_list/owned_coupon_list_bloc.dart';
import 'package:proj_inz/core/theme.dart';
import 'package:proj_inz/data/models/owned_coupon_model.dart';
import 'package:proj_inz/data/repositories/coupon_repository.dart';
import 'package:proj_inz/presentation/widgets/bought_coupon_card.dart';
import 'package:proj_inz/presentation/widgets/error_card.dart';
import 'package:proj_inz/presentation/widgets/input/buttons/checkbox.dart';
import 'package:proj_inz/presentation/widgets/input/buttons/custom_icon_button.dart';
import 'package:proj_inz/presentation/widgets/input/buttons/custom_text_button.dart';
import 'package:proj_inz/presentation/widgets/input/buttons/radio_button.dart';

class BoughtCouponListScreen extends StatefulWidget {
  const BoughtCouponListScreen({super.key});

  @override
  State<BoughtCouponListScreen> createState() => _BoughtCouponListScreenState();
}

class _BoughtCouponListScreenState extends State<BoughtCouponListScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _scrollListenerAdded = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _setupScrollListener(BuildContext context) {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 150) {
        if (mounted) {
          context.read<OwnedCouponListBloc>().add(FetchMoreCoupons());
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OwnedCouponListBloc(context.read<CouponRepository>())
        ..add(FetchCoupons()),
      child: BlocBuilder<OwnedCouponListBloc, OwnedCouponListState>(
        builder: (context, state) {
          if (!_scrollListenerAdded) {
            _setupScrollListener(context);
            _scrollListenerAdded = true;
          }

          return Scaffold(
            body: SafeArea(
              child: RefreshIndicator(
                onRefresh: () async {
                  context.read<OwnedCouponListBloc>().add(RefreshCoupons());
                },
                child: CustomScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    const _Toolbar(),
                    _listContent(state),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _listContent(OwnedCouponListState state) {
    if (state is OwnedCouponListLoadInProgress) {
      return const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      );
    } else if (state is OwnedCouponListLoadSuccess) {
      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            OwnedCoupon coupon = state.coupons[index];
            if (index == 1) coupon = coupon.copyWith(isUsed: true); // for demo purposes
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: OwnedCouponCardHorizontal(coupon: coupon),
            );
          }, childCount: state.coupons.length),
        ),
      );
    } else if (state is OwnedCouponListLoadEmpty) {
      return const SliverFillRemaining(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              "Nie posiadasz jeszcze żadnych kuponów.",
              textAlign: TextAlign.left,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontFamily: 'Itim',
                fontWeight: FontWeight.w400,
              ),
              softWrap: true,
            ),
          ),
        ),
      );
    } else if (state is OwnedCouponListLoadFailure) {
      if (kDebugMode) debugPrint(state.message);
      return SliverFillRemaining(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ErrorCard(
              text: "Przykro nam, wystąpił błąd w trakcie ładowania Twoich kuponów.",
              errorString: state.message,
              icon: const Icon(Icons.sentiment_dissatisfied),
            ),
          ),
        ),
      );
    }
    return const SliverFillRemaining();
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
      flexibleSpace: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            height: 60,
            child: Container(color: AppColors.surface),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
            child: Container(
              width: double.infinity,
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                spacing: 12,
                children: [
                  CustomIconButton(
                    icon: SvgPicture.asset('assets/icons/back.svg'),
                    onTap: () => Navigator.of(context).pop(),
                  ),

                  Row(
                    spacing: 12,
                    children: [
                      CustomTextButton.small(
                        label: 'Filtruj',
                        icon: const Icon(Icons.filter_alt),
                        onTap: () => showDialog(
                          context: context,
                          barrierColor: AppColors.popupOverlay,
                          builder: (_) => BlocProvider.value(
                            value: context.read<OwnedCouponListBloc>(),
                            child: const _OwnedCouponFilterDialog(),
                          ),
                        ).then((_) {
                          if (context.mounted) {
                            context.read<OwnedCouponListBloc>()
                                .add(LeaveOwnedCouponFilterPopUp());
                          }
                        }),
                      ),
                      CustomTextButton.small(
                        label: 'Sortuj',
                        icon: const Icon(Icons.sort),
                        onTap: () => showDialog(
                          context: context,
                          barrierColor: AppColors.popupOverlay,
                          builder: (_) => BlocProvider.value(
                            value: context.read<OwnedCouponListBloc>(),
                            child: const _OwnedCouponSortDialog(),
                          ),
                        ).then((_) {
                          if (context.mounted) {
                            context.read<OwnedCouponListBloc>()
                                .add(LeaveOwnedCouponSortPopUp());
                          }
                        }),
                      ),
                    ],
                  ),

                ],
              ),
            ),
          ),
        ],
      ),
      toolbarHeight: 126,
    );
  }
}

class _OwnedCouponFilterDialog extends StatefulWidget {
  const _OwnedCouponFilterDialog();

  @override
  State<_OwnedCouponFilterDialog> createState() => _OwnedCouponFilterDialogState();
}

class _OwnedCouponFilterDialogState extends State<_OwnedCouponFilterDialog> {
  bool reductionIsPercentage = true;
  bool reductionIsFixed = true;
  double? minPrice;
  double? maxPrice;
  bool showUsed = true;
  bool showUnused = true;
  String? selectedShopId;

  final minPriceController = TextEditingController();
  final maxPriceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<OwnedCouponListBloc>().add(ReadOwnedCouponFilters());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OwnedCouponListBloc, OwnedCouponListState>(
      listenWhen: (_, state) => state is OwnedCouponFilterRead,
      listener: (context, state) {
        if (state is OwnedCouponFilterRead) {
          reductionIsPercentage = state.reductionIsPercentage ?? true;
          reductionIsFixed = state.reductionIsFixed ?? true;
          minPrice = state.minPrice;
          maxPrice = state.maxPrice;
          showUsed = state.showUsed ?? true;
          showUnused = state.showUnused ?? true;
          selectedShopId = state.shopId;

          setState(() {});
        }
      },
      child: Material(
        color: Colors.transparent,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  CustomIconButton(
                    icon: SvgPicture.asset('assets/icons/back.svg'),
                    onTap: () => Navigator.of(context).pop(),
                  )
                ],
              ),
              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(20),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 18,
                  children: [
                    const Text(
                      'Filtry',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 24,
                        fontFamily: 'Itim',
                      ),
                    ),
                    const Divider(color: AppColors.textPrimary, thickness: 2),

                    const Text(
                      'Typ kuponu',
                      style: TextStyle(fontSize: 20, color: AppColors.textPrimary),
                    ),
                    CustomCheckbox(
                      selected: reductionIsPercentage,
                      onTap: () {
                        setState(() => reductionIsPercentage = !reductionIsPercentage);
                      },
                      label: 'rabat -%',
                    ),
                    CustomCheckbox(
                      selected: reductionIsFixed,
                      onTap: () {
                        setState(() => reductionIsFixed = !reductionIsFixed);
                      },
                      label: 'rabat -zł',
                    ),

                    const Divider(color: AppColors.textPrimary),

                    const Text(
                      'Status kuponu',
                      style: TextStyle(fontSize: 20, color: AppColors.textPrimary),
                    ),
                    CustomCheckbox(
                      selected: showUsed,
                      onTap: () {
                        setState(() => showUsed = !showUsed);
                      },
                      label: 'wykorzystany',
                    ),
                    CustomCheckbox(
                      selected: showUnused,
                      onTap: () {
                        setState(() => showUnused = !showUnused);
                      },
                      label: 'niewykorzystany',
                    ),

                    const Divider(color: AppColors.textPrimary),

                    const Text(
                      'Sklep',
                      style: TextStyle(fontSize: 20, color: AppColors.textPrimary),
                    ),

                    DropdownButton<String>(
                      value: selectedShopId,
                      hint: const Text("Wybierz sklep"),
                      items: context.read<OwnedCouponListBloc>().allCoupons
                          .map((c) => DropdownMenuItem(
                                value: c.shopId,
                                child: Text(c.shopName),
                              ))
                          .toSet()
                          .toList(),
                      onChanged: (v) {
                        setState(() => selectedShopId = v);
                      },
                    ),

                    const SizedBox(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomTextButton(
                          label: "Wyczyść",
                          icon: const Icon(Icons.delete_outline),
                          onTap: () {
                            Navigator.of(context).pop();
                            context
                                .read<OwnedCouponListBloc>()
                                .add(ClearOwnedCouponFilters());
                          },
                        ),
                        CustomTextButton.primary(
                          label: "Zastosuj",
                          icon: const Icon(Icons.check),
                          onTap: () {
                            Navigator.of(context).pop();
                            context.read<OwnedCouponListBloc>().add(
                                  ApplyOwnedCouponFilters(
                                    reductionIsPercentage: reductionIsPercentage,
                                    reductionIsFixed: reductionIsFixed,
                                    showUsed: showUsed,
                                    showUnused: showUnused,
                                    shopId: selectedShopId,
                                  ),
                                );
                          },
                        ),
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _OwnedCouponSortDialog extends StatefulWidget {
  const _OwnedCouponSortDialog();

  @override
  State<_OwnedCouponSortDialog> createState() => _OwnedCouponSortDialogState();
}

class _OwnedCouponSortDialogState extends State<_OwnedCouponSortDialog> {
  OwnedCouponsOrdering ordering = OwnedCouponsOrdering.purchaseDateDesc;

  @override
  void initState() {
    super.initState();
    context.read<OwnedCouponListBloc>().add(ReadOwnedCouponOrdering());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OwnedCouponListBloc, OwnedCouponListState>(
      listenWhen: (_, state) => state is OwnedCouponOrderingRead,
      listener: (context, state) {
        if (state is OwnedCouponOrderingRead) {
          setState(() => ordering = state.ordering);
        }
      },
      child: Material(
        color: Colors.transparent,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  CustomIconButton(
                    icon: SvgPicture.asset('assets/icons/back.svg'),
                    onTap: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(20),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 18,
                  children: [
                    const Text(
                      'Sortowanie',
                      style: TextStyle(
                        fontSize: 24,
                        fontFamily: 'Itim',
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Divider(color: AppColors.textPrimary, thickness: 2),

                    const Text(
                      'Data zakupu',
                      style: TextStyle(fontSize: 20, color: AppColors.textPrimary),
                    ),
                    CustomRadioButton(
                      label: "od najnowszych",
                      selected: ordering == OwnedCouponsOrdering.purchaseDateDesc,
                      onTap: () => setState(
                          () => ordering = OwnedCouponsOrdering.purchaseDateDesc),
                    ),
                    CustomRadioButton(
                      label: "od najstarszych",
                      selected: ordering == OwnedCouponsOrdering.purchaseDateAsc,
                      onTap: () => setState(
                          () => ordering = OwnedCouponsOrdering.purchaseDateAsc),
                    ),

                    const Divider(color: AppColors.textPrimary),

                    const Text(
                      'Data ważności',
                      style: TextStyle(fontSize: 20, color: AppColors.textPrimary),
                    ),
                    CustomRadioButton(
                      label: "od najbliższej",
                      selected: ordering == OwnedCouponsOrdering.expiryDateAsc,
                      onTap: () => setState(
                          () => ordering = OwnedCouponsOrdering.expiryDateAsc),
                    ),
                    CustomRadioButton(
                      label: "od najdalszej",
                      selected: ordering == OwnedCouponsOrdering.expiryDateDesc,
                      onTap: () => setState(
                          () => ordering = OwnedCouponsOrdering.expiryDateDesc),
                    ),

                    const Divider(color: AppColors.textPrimary),

                    const Text(
                      'Cena',
                      style: TextStyle(fontSize: 20, color: AppColors.textPrimary),
                    ),
                    CustomRadioButton(
                      label: "od najniższej",
                      selected: ordering == OwnedCouponsOrdering.priceAsc,
                      onTap: () =>
                          setState(() => ordering = OwnedCouponsOrdering.priceAsc),
                    ),
                    CustomRadioButton(
                      label: "od najwyższej",
                      selected: ordering == OwnedCouponsOrdering.priceDesc,
                      onTap: () =>
                          setState(() => ordering = OwnedCouponsOrdering.priceDesc),
                    ),

                    const SizedBox(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomTextButton.primary(
                          label: "Zastosuj",
                          icon: const Icon(Icons.check),
                          onTap: () {
                            Navigator.of(context).pop();
                            context
                                .read<OwnedCouponListBloc>()
                                .add(ApplyOwnedCouponOrdering(ordering));
                          },
                        ),
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}