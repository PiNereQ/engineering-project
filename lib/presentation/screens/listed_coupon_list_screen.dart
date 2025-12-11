import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:proj_inz/core/theme.dart';
import 'package:proj_inz/data/repositories/coupon_repository.dart';

import 'package:proj_inz/bloc/listed_coupon_list/listed_coupon_list_bloc.dart';
import 'package:proj_inz/bloc/listed_coupon_list/listed_coupon_list_event.dart';
import 'package:proj_inz/bloc/listed_coupon_list/listed_coupon_list_state.dart';

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

class _ListedCouponListScreenState extends State<ListedCouponListScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _listenerAdded = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
    return BlocProvider(
      create: (context) => ListedCouponListBloc(context.read<CouponRepository>())
        ..add(FetchListedCoupons()),
      child: BlocBuilder<ListedCouponListBloc, ListedCouponListState>(
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
      ),
    );
  }

  Widget _listContent(ListedCouponListState state) {
    if (state is ListedCouponListLoadInProgress) {
      return const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      );
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
      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final coupon = state.coupons[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: ListedCouponCardHorizontal(coupon: coupon),
              );
            },
            childCount: state.coupons.length,
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
      flexibleSpace: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
        child: Container(
          decoration: ShapeDecoration(
            color: AppColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: const BorderSide(width: 2),
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
                spacing: 12,
                children: [
                  CustomTextButton.small(
                    label: "Filtruj",
                    icon: const Icon(Icons.filter_alt),
                    onTap: () => showDialog(
                      context: context,
                      barrierColor: AppColors.popupOverlay,
                      builder: (_) => BlocProvider.value(
                        value: context.read<ListedCouponListBloc>(),
                        child: const _ListedFilterDialog(),
                      ),
                    ),
                  ),
                  CustomTextButton.small(
                    label: "Sortuj",
                    icon: const Icon(Icons.sort),
                    onTap: () => showDialog(
                      context: context,
                      barrierColor: AppColors.popupOverlay,
                      builder: (_) => BlocProvider.value(
                        value: context.read<ListedCouponListBloc>(),
                        child: const _ListedSortDialog(),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
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
                    )
                  ],
                ),
                const SizedBox(height: 16),

                _filterBox(context, shops),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _filterBox(BuildContext context, List<Map<String, String>> shops) {
    return Container(
      decoration: ShapeDecoration(
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 2),
          borderRadius: BorderRadius.circular(24),
        ),
        shadows: const [
          BoxShadow(
            color: AppColors.textPrimary,
            offset: Offset(4, 4),
          )
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 18,
        children: [
          const Text("Filtry",
              style: TextStyle(fontSize: 24, fontFamily: "Itim")),
          const Divider(thickness: 2),

          const Text("Typ kuponu",
              style: TextStyle(fontSize: 20, fontFamily: "Itim")),
          CustomCheckbox(
            label: "rabat -%",
            selected: reductionIsPercentage,
            onTap: () => setState(() => reductionIsPercentage = !reductionIsPercentage),
          ),
          CustomCheckbox(
            label: "rabat -zł",
            selected: reductionIsFixed,
            onTap: () => setState(() => reductionIsFixed = !reductionIsFixed),
          ),

          const Divider(),

          const Text("Status kuponu",
              style: TextStyle(fontSize: 20, fontFamily: "Itim")),
          CustomCheckbox(
            label: "aktywny",
            selected: showActive,
            onTap: () => setState(() => showActive = !showActive),
          ),
          CustomCheckbox(
            label: "sprzedany",
            selected: showSold,
            onTap: () => setState(() => showSold = !showSold),
          ),

          const Divider(),

          const Text("Sklep",
              style: TextStyle(fontSize: 20, fontFamily: "Itim")),
          Container(
            decoration: ShapeDecoration(
              color: AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(width: 2),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: DropdownButton<String>(
              isExpanded: true,
              underline: const SizedBox(),
              value: selectedShopId,
              items: shops.map((shop) {
                return DropdownMenuItem(
                  value: shop["id"],
                  child: Text(
                    shop["name"]!,
                    style: const TextStyle(fontFamily: "Itim"),
                  ),
                );
              }).toList(),
              onChanged: (v) => setState(() => selectedShopId = v),
            ),
          ),

          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CustomTextButton(
                label: "Wyczyść",
                icon: const Icon(Icons.delete_outline),
                onTap: () {
                  Navigator.pop(context);
                  context
                      .read<ListedCouponListBloc>()
                      .add(ClearListedCouponFilters());
                },
              ),
              CustomTextButton.primary(
                label: "Zastosuj",
                icon: const Icon(Icons.check),
                onTap: () {
                  Navigator.pop(context);
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
          )
        ],
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
      listenWhen: (_, s) => s is ListedCouponOrderingRead,
      listener: (_, state) {
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
                  )
                ],
              ),
              const SizedBox(height: 16),

              _sortBox(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sortBox(BuildContext context) {
    return Container(
      decoration: ShapeDecoration(
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 2),
          borderRadius: BorderRadius.circular(24),
        ),
        shadows: const [
          BoxShadow(
            color: AppColors.textPrimary,
            offset: Offset(4, 4),
          )
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 18,
        children: [
          const Text(
            "Sortowanie",
            style: TextStyle(fontSize: 24, fontFamily: "Itim"),
          ),
          const Divider(thickness: 2),

          const Text(
            "Data wystawienia",
            style: TextStyle(fontSize: 20, fontFamily: "Itim"),
          ),
          CustomRadioButton(
            label: "od najnowszych",
            selected: ordering == ListedCouponsOrdering.listingDateDesc,
            onTap: () =>
                setState(() => ordering = ListedCouponsOrdering.listingDateDesc),
          ),
          CustomRadioButton(
            label: "od najstarszych",
            selected: ordering == ListedCouponsOrdering.listingDateAsc,
            onTap: () =>
                setState(() => ordering = ListedCouponsOrdering.listingDateAsc),
          ),

          const Text(
            "Data ważności",
            style: TextStyle(fontSize: 20, fontFamily: "Itim"),
          ),
          CustomRadioButton(
            label: "od najbliższej",
            selected: ordering == ListedCouponsOrdering.expiryDateAsc,
            onTap: () =>
                setState(() => ordering = ListedCouponsOrdering.expiryDateAsc),
          ),
          CustomRadioButton(
            label: "od najdalszej",
            selected: ordering == ListedCouponsOrdering.expiryDateDesc,
            onTap: () =>
                setState(() => ordering = ListedCouponsOrdering.expiryDateDesc),
          ),

          const Text(
            "Cena",
            style: TextStyle(fontSize: 20, fontFamily: "Itim"),
          ),
          CustomRadioButton(
            label: "od najniższej",
            selected: ordering == ListedCouponsOrdering.priceAsc,
            onTap: () =>
                setState(() => ordering = ListedCouponsOrdering.priceAsc),
          ),
          CustomRadioButton(
            label: "od najwyższej",
            selected: ordering == ListedCouponsOrdering.priceDesc,
            onTap: () =>
                setState(() => ordering = ListedCouponsOrdering.priceDesc),
          ),

          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomTextButton.primary(
                label: "Zastosuj",
                icon: const Icon(Icons.check),
                onTap: () {
                  Navigator.pop(context);
                  context
                      .read<ListedCouponListBloc>()
                      .add(ApplyListedCouponOrdering(ordering));
                },
              ),
            ],
          )
        ],
      ),
    );
  }
}