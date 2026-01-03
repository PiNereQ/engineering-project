import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:proj_inz/core/app_flags.dart';
import 'package:proj_inz/core/theme.dart';
import 'package:proj_inz/data/repositories/coupon_repository.dart';

import 'package:proj_inz/bloc/listed_coupon_list/listed_coupon_list_bloc.dart';
import 'package:proj_inz/bloc/listed_coupon_list/listed_coupon_list_event.dart';
import 'package:proj_inz/bloc/listed_coupon_list/listed_coupon_list_state.dart';
import 'package:proj_inz/main.dart';

import 'package:proj_inz/presentation/widgets/error_card.dart';
import 'package:proj_inz/presentation/widgets/listed_coupon_card.dart';
import 'package:proj_inz/presentation/widgets/input/buttons/custom_icon_button.dart';
import 'package:proj_inz/presentation/widgets/input/buttons/custom_text_button.dart';
import 'package:proj_inz/presentation/widgets/input/buttons/checkbox.dart';
import 'package:proj_inz/presentation/widgets/input/buttons/radio_button.dart';


class ListedCouponListScreen extends StatefulWidget {
  const ListedCouponListScreen({super.key});

  @override
  State<ListedCouponListScreen> createState() => _ListedCouponListScreenState();
}

class _ListedCouponListScreenState extends State<ListedCouponListScreen> with RouteAware {
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
    if (!AppFlags.listedCouponDeleted) return;

    AppFlags.listedCouponDeleted = false;

    context.read<ListedCouponListBloc>().add(RefreshListedCoupons());
  }

  void _setupListener(BuildContext context) {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 150) {
        context.read<ListedCouponListBloc>().add(FetchMoreListedCoupons());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    return BlocBuilder<ListedCouponListBloc, ListedCouponListState>(
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
                  context.read<ListedCouponListBloc>().add(RefreshListedCoupons());
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
      );
  }

  Widget _listContent(ListedCouponListState state) {
    if (state is ListedCouponListLoadInProgress) {
      if (state.coupons.isEmpty) {
        return const SliverFillRemaining(
          child: Center(child: CircularProgressIndicator(color: AppColors.textPrimary,)),
        );
      } else {
        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index == state.coupons.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator(color: AppColors.textPrimary,)),
                  );
                }
                final coupon = state.coupons[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: ListedCouponCardHorizontal(coupon: coupon),
                );
              },
              childCount: state.coupons.length + 1,
            ),
          ),
        );
      }
    }

    if (state is ListedCouponListLoadEmpty) {
      return const SliverFillRemaining(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              "Nie masz żadnych wystawionych kuponów.",
              style: TextStyle(
                fontSize: 18,
                fontFamily: 'Itim',
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
      );
    }

    if (state is ListedCouponListLoadFailure) {
      if (kDebugMode) debugPrint(state.message);
      return SliverFillRemaining(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ErrorCard(
            text: "Przykro nam, wystąpił błąd w trakcie ładowania kuponów.",
            errorString: state.message,
            icon: const Icon(Icons.error),
          ),
        ),
      );
    }

    if (state is ListedCouponListLoadSuccess) {
      if (state.coupons.isEmpty) {
        return const SliverFillRemaining(
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                "Nie masz żadnych wystawionych kuponów.",
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: 'Itim',
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
        );
      }

      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              if (index == state.coupons.length) {
                return const SizedBox(height: 86); // padding for navbar
              }
              final coupon = state.coupons[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: ListedCouponCardHorizontal(coupon: coupon),
              );
            },
            childCount: state.coupons.length + 1,
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
            child: Container(color: AppColors.background),
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
                            value: context.read<ListedCouponListBloc>(),
                            child: const _ListedFilterDialog(),
                          ),
                        ).then((_) {
                          if (context.mounted) {
                            final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
                            context.read<ListedCouponListBloc>()
                              .add(FetchListedCoupons(userId: userId));
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
                            value: context.read<ListedCouponListBloc>(),
                            child: const _ListedSortDialog(),
                          ),
                        ).then((_) {
                          if (context.mounted) {
                            final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
                            context.read<ListedCouponListBloc>()
                              .add(FetchListedCoupons(userId: userId));
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

// filtering
class _ListedFilterDialog extends StatefulWidget {
  const _ListedFilterDialog();

  @override
  State<_ListedFilterDialog> createState() => _ListedFilterDialogState();
}

class _ListedFilterDialogState extends State<_ListedFilterDialog> {
  bool reductionIsPercentage = true;
  bool reductionIsFixed = true;
  bool showActive = true;
  bool showSold = true;
  String? selectedShopId;

  @override
  void initState() {
    super.initState();
    context.read<ListedCouponListBloc>().add(ReadListedCouponFilters());
  }

  @override
  Widget build(BuildContext context) {
    final shops = context.read<ListedCouponListBloc>().uniqueShops;

    return BlocListener<ListedCouponListBloc, ListedCouponListState>(
      listenWhen: (_, s) => s is ListedCouponFilterRead,
      listener: (_, state) {
        if (state is ListedCouponFilterRead) {
          setState(() {
            reductionIsPercentage = state.reductionIsPercentage ?? true;
            reductionIsFixed = state.reductionIsFixed ?? true;
            showActive = state.showActive ?? true;
            showSold = state.showSold ?? true;
            selectedShopId = state.shopId;
          });
        }
      },
      child: Material(
        color: Colors.transparent,
        child: SingleChildScrollView(
          child: Padding(
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
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                          ),
                        ),
                      ),
                      const Divider(color: AppColors.textPrimary, thickness: 2),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 8,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Typ kuponu',
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 20,
                                    fontFamily: 'Itim',
                                  ),
                                ),
                                CustomCheckbox(
                                  selected: reductionIsPercentage,
                                  onTap: () => setState(() =>
                                      reductionIsPercentage = !reductionIsPercentage),
                                  label: 'rabat -%',
                                ),
                                CustomCheckbox(
                                  selected: reductionIsFixed,
                                  onTap: () => setState(() =>
                                      reductionIsFixed = !reductionIsFixed),
                                  label: 'rabat -zł',
                                ),
                              ],
                            ),

                            const Divider(color: AppColors.textPrimary),

                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Status kuponu',
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 20,
                                    fontFamily: 'Itim',
                                  ),
                                ),
                                CustomCheckbox(
                                  selected: showActive,
                                  onTap: () => setState(() => showActive = !showActive),
                                  label: 'aktywny',
                                ),
                                CustomCheckbox(
                                  selected: showSold,
                                  onTap: () => setState(() => showSold = !showSold),
                                  label: 'sprzedany/przeterminowany',
                                ),
                              ],
                            ),

                            const Divider(color: AppColors.textPrimary),

                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Sklep',
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 20,
                                    fontFamily: 'Itim',
                                  ),
                                ),
                                Container(
                                  decoration: ShapeDecoration(
                                    color: AppColors.surface,
                                    shape: RoundedRectangleBorder(
                                      side: const BorderSide(width: 2, color: AppColors.textPrimary),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  child: DropdownButton<String>(
                                    value: selectedShopId,
                                    isExpanded: true,
                                    underline: const SizedBox(),
                                    dropdownColor: AppColors.surface,
                                    style: const TextStyle(
                                      fontFamily: "Itim",
                                      fontSize: 18,
                                      color: AppColors.textPrimary,
                                    ),
                                    hint: const Text(
                                      "Wybierz sklep",
                                      style: TextStyle(
                                        fontFamily: "Itim",
                                        fontSize: 18,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    items: shops
                                        .map(
                                          (shop) => DropdownMenuItem<String>(
                                            value: shop.id,
                                            child: Text(
                                              shop.name,
                                              style: const TextStyle(
                                                fontFamily: "Itim",
                                                fontSize: 18,
                                                color: AppColors.textPrimary,
                                              ),
                                            ),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (value) => setState(() => selectedShopId = value),
                                  ),
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
                            CustomTextButton(
                              label: 'Wyczyść',
                              icon: const Icon(Icons.delete_outline),
                              onTap: () {
                                Navigator.of(context).pop();
                                context
                                    .read<ListedCouponListBloc>()
                                    .add(ClearListedCouponFilters());
                              },
                            ),
                            CustomTextButton.primary(
                              label: 'Zastosuj',
                              icon: const Icon(Icons.check),
                              onTap: () {
                                Navigator.of(context).pop();
                                context.read<ListedCouponListBloc>().add(
                                      ApplyListedCouponFilters(
                                        reductionIsPercentage: reductionIsPercentage,
                                        reductionIsFixed: reductionIsFixed,
                                        showActive: showActive,
                                        showSold: showSold,
                                        shopId: selectedShopId,
                                      ),
                                    );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// sorting
class _ListedSortDialog extends StatefulWidget {
  const _ListedSortDialog();

  @override
  State<_ListedSortDialog> createState() => _ListedSortDialogState();
}

class _ListedSortDialogState extends State<_ListedSortDialog> {
  ListedCouponsOrdering ordering = ListedCouponsOrdering.listingDateDesc;

  @override
  void initState() {
    super.initState();
    context.read<ListedCouponListBloc>().add(ReadListedCouponOrdering());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ListedCouponListBloc, ListedCouponListState>(
      listenWhen: (_, state) => state is ListedCouponOrderingRead,
      listener: (context, state) {
        if (state is ListedCouponOrderingRead) {
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
                  spacing: 18,
                  crossAxisAlignment: CrossAxisAlignment.start,
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

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 8,
                        children: [

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Data wystawienia',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontFamily: 'Itim',
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              CustomRadioButton(
                                label: "od najnowszych",
                                selected: ordering ==
                                    ListedCouponsOrdering.listingDateDesc,
                                onTap: () => setState(() =>
                                    ordering =
                                        ListedCouponsOrdering.listingDateDesc),
                              ),
                              CustomRadioButton(
                                label: "od najstarszych",
                                selected: ordering ==
                                    ListedCouponsOrdering.listingDateAsc,
                                onTap: () => setState(() =>
                                    ordering =
                                        ListedCouponsOrdering.listingDateAsc),
                              ),
                            ],
                          ),

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Data ważności',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontFamily: 'Itim',
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              CustomRadioButton(
                                label: "od najbliższej",
                                selected:
                                    ordering == ListedCouponsOrdering.expiryDateAsc,
                                onTap: () => setState(() =>
                                    ordering =
                                        ListedCouponsOrdering.expiryDateAsc),
                              ),
                              CustomRadioButton(
                                label: "od najdalszej",
                                selected:
                                    ordering == ListedCouponsOrdering.expiryDateDesc,
                                onTap: () => setState(() =>
                                    ordering =
                                        ListedCouponsOrdering.expiryDateDesc),
                              ),
                            ],
                          ),

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Cena',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontFamily: 'Itim',
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              CustomRadioButton(
                                label: "od najniższej",
                                selected:
                                    ordering == ListedCouponsOrdering.priceAsc,
                                onTap: () => setState(() =>
                                    ordering = ListedCouponsOrdering.priceAsc),
                              ),
                              CustomRadioButton(
                                label: "od najwyższej",
                                selected:
                                    ordering == ListedCouponsOrdering.priceDesc,
                                onTap: () => setState(() =>
                                    ordering = ListedCouponsOrdering.priceDesc),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomTextButton.primary(
                          label: "Zastosuj",
                          icon: const Icon(Icons.check),
                          onTap: () {
                            Navigator.of(context).pop();
                            context.read<ListedCouponListBloc>().add(
                                  ApplyListedCouponOrdering(ordering),
                                );
                          },
                        ),
                      ],
                    ),
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