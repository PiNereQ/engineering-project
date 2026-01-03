import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:proj_inz/bloc/coupon_list/coupon_list_bloc.dart';
import 'package:proj_inz/bloc/search_shops_categories/search_shops_categories_bloc.dart';
import 'package:proj_inz/bloc/search_shops_categories/search_shops_categories_event.dart';
import 'package:proj_inz/core/app_flags.dart';
import 'package:proj_inz/core/theme.dart';
import 'package:proj_inz/core/utils/text_formatters.dart';
import 'package:proj_inz/main.dart';
import 'package:proj_inz/presentation/screens/map_screen.dart';
import 'package:proj_inz/presentation/screens/search_results_screen.dart';
import 'package:proj_inz/data/repositories/shop_repository.dart';
import 'package:proj_inz/data/repositories/category_repository.dart';
import 'package:proj_inz/presentation/widgets/coupon_card.dart';
import 'package:proj_inz/presentation/widgets/error_card.dart';
import 'package:proj_inz/presentation/widgets/input/buttons/checkbox.dart';
import 'package:proj_inz/presentation/widgets/input/buttons/custom_icon_button.dart';
import 'package:proj_inz/presentation/widgets/input/buttons/custom_text_button.dart';
import 'package:proj_inz/presentation/widgets/input/buttons/radio_button.dart';
import 'package:proj_inz/presentation/widgets/input/text_fields/labeled_text_field.dart';
import 'package:proj_inz/presentation/widgets/input/text_fields/search_bar.dart';

// Local debugging flags
bool stopCouponLoading = false; // Default to false

class CouponListScreen extends StatelessWidget {
  final String? selectedShopId;
  final String? searchShopName;
  final String? selectedCategoryId;
  final String? searchCategoryName;
  const CouponListScreen({super.key, this.selectedShopId, this.searchShopName, this.selectedCategoryId, this.searchCategoryName});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(
          value: context.read<CouponListBloc>(),
        ),
        BlocProvider(
          create: (_) => SearchBloc(
            shopRepository: context.read<ShopRepository>(),
            categoryRepository: context.read<CategoryRepository>()
            )
        ),
      ],
      child: _CouponListScreenContent(
        selectedShopId: selectedShopId,
        searchShopName: searchShopName,
        selectedCategoryId: selectedCategoryId,
        searchCategoryName: searchCategoryName,
      ),
    );
  }
}


class _CouponListScreenContent extends StatefulWidget {
  final String? selectedShopId;
  final String? searchShopName;
  final String? selectedCategoryId;
  final String? searchCategoryName;
  const _CouponListScreenContent({this.selectedShopId, this.searchShopName, this.selectedCategoryId, this.searchCategoryName});

  @override
  State<_CouponListScreenContent> createState() =>
      _CouponListScreenContentState();
}

class _CouponListScreenContentState extends State<_CouponListScreenContent> with RouteAware {
  
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 150
          && context.read<CouponListBloc>().state is! CouponListLoadInProgress) {
        debugPrint('Ładuj wincyj!');
        if (mounted) {
          context.read<CouponListBloc>().add(FetchMoreCoupons());
        }
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    routeObserver.subscribe(this, ModalRoute.of(context)! as PageRoute);
    
    if (stopCouponLoading) return;

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    context.read<CouponListBloc>().add(
      FetchCoupons(
        shopId: widget.selectedShopId,
        categoryId: widget.selectedCategoryId,
        userId: userId,
      ),
    );
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

    context.read<CouponListBloc>().add(RefreshCoupons());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<CouponListBloc>().add(RefreshCoupons());
        },
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverSafeArea(
              top: true,
              bottom: false,
              sliver: _Toolbar(
                searchShopName: widget.searchShopName,
                searchCategoryName: widget.searchCategoryName,
              ),
            ),

            BlocBuilder<CouponListBloc, CouponListState>(
              builder: (context, state) {
                if (state is CouponListLoadInProgress) {
                  if (state.coupons.isEmpty) {
                    return const SliverFillRemaining(
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.textPrimary,
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
                            return const Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            );
                          }

                          final coupon = state.coupons[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: CouponCardHorizontal(coupon: coupon),
                          );
                        },
                        childCount: state.coupons.length + 1,
                      ),
                    ),
                  );
                }

                if (state is CouponListLoadSuccess) {
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
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: CouponCardHorizontal(coupon: coupon),
                          );
                        },
                        childCount: state.coupons.length + 1,
                      ),
                    ),
                  );
                } else if (state is CouponListLoadEmpty) {
                  return const SliverFillRemaining(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          "Nie znaleźliśmy kuponów pasujących do wybranych filtrów...",
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
                } else if (state is CouponListLoadFailure) {
                  if (kDebugMode) debugPrint(state.message);
                  return SliverFillRemaining(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: ErrorCard(
                          text: "Przykro nam, wystąpił błąd w trakcie ładowania kuponów.",
                          errorString: state.message,
                          icon: const Icon(Icons.sentiment_dissatisfied),
                        ),
                      ),
                    ),
                  );
                }
                return const SliverFillRemaining();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _Toolbar extends StatelessWidget {
  final String? searchShopName;
  final String? searchCategoryName;

  const _Toolbar({this.searchShopName, this.searchCategoryName});

@override
Widget build(BuildContext context) {

  final bool hasSearchHeader =
    searchShopName != null || searchCategoryName != null;

  return SliverAppBar(
    automaticallyImplyLeading: false, // automatyczna strzalka wstecz dla ekranow z navigator.push
    floating: true,
    snap: true,
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
          child: Container(color: Colors.transparent),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
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
            child: Column(
              spacing: 16,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (searchShopName != null || searchCategoryName != null)
                  Row(
                    children: [
                      // przycisk wstecz
                      InkWell(
                        borderRadius: BorderRadius.circular(1000),
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          clipBehavior: Clip.antiAlias,
                          decoration: ShapeDecoration(
                            color: AppColors.surface,
                            shape: RoundedRectangleBorder(
                              side: const BorderSide(width: 2),
                              borderRadius: BorderRadius.circular(1000),
                            ),
                            shadows: const [
                              BoxShadow(
                                color: AppColors.textPrimary,
                                blurRadius: 0,
                                offset: Offset(3, 3),
                                spreadRadius: 0,
                              )
                            ],
                          ),
                          child: SvgPicture.asset(
                            'assets/icons/back.svg',
                            width: 18,
                            height: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // "wyszukiwanie dla sklepu: <nazwa>" lub "wyszukiwanie dla kategorii: <nazwa>"
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                          decoration: ShapeDecoration(
                            color: AppColors.surface,
                            shape: RoundedRectangleBorder(
                              side: const BorderSide(width: 2),
                              borderRadius: BorderRadius.circular(16),
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
                          child: (searchShopName != null)
                            ? Text(
                                'Wyniki dla sklepu: $searchShopName',
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 16,
                                  fontFamily: 'Itim',
                                  fontWeight: FontWeight.w400,
                                ),
                              )
                            : Text(
                                'Wyniki dla kategorii: $searchCategoryName',
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 16,
                                  fontFamily: 'Itim',
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                        ),
                      ),
                    ],
                  )
                else
                  SearchBarWide(
                    hintText: 'Wyszukaj sklep lub kategorię',
                    onSubmitted: (query) {
                      final searchBloc = context.read<SearchBloc>();
                      searchBloc.add(SearchQuerySubmitted(query));
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => BlocProvider.value(
                            value: searchBloc,
                            child: SearchResultsScreen(query: query),
                          ),
                        ),
                      );
                    },
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Expanded(
                          child: BlocBuilder<CouponListBloc, CouponListState>(
                              builder: (context, state) {
                              final bloc = context.read<CouponListBloc>();

                              final hasFilters = bloc.hasActiveFilters;
                              final hasOrdering = bloc.hasActiveOrdering;

                              return Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CustomTextButton.small(
                                    label: 'Filtruj',
                                    badgeNumber: hasFilters ? 1 : null,
                                    icon: hasFilters ? null : const Icon(Icons.filter_alt),
                                    onTap: () => showDialog(
                                      context: context,
                                      barrierColor: AppColors.popupOverlay,
                                      builder: (dialogContext) => BlocProvider.value(
                                        value: context.read<CouponListBloc>(),
                                        child: const _CouponFilterDialog(),
                                      ),
                                    ).then((_) {
                                      if (context.mounted) {
                                        context.read<CouponListBloc>().add(
                                          LeaveCouponFilterPopUp(),
                                        );
                                      }
                                    }),
                                  ),
                                  const SizedBox(width: 6),
                                  CustomTextButton.small(
                                    label: 'Sortuj',
                                    badgeNumber: hasOrdering ? 1 : null,
                                    icon: hasOrdering ? null : const Icon(Icons.sort),
                                    onTap: () => showDialog(
                                      context: context,
                                      barrierColor: AppColors.popupOverlay,
                                      builder: (dialogContext) => BlocProvider.value(
                                        value: context.read<CouponListBloc>(),
                                        child: const _CouponSortDialog(),
                                      ),
                                    ).then((_) {
                                      if (context.mounted) {
                                        context.read<CouponListBloc>().add(
                                          LeaveCouponSortPopUp(),
                                        );
                                      }
                                    }),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                      CustomTextButton.small(
                        label: 'Pokaż mapę',
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const MapScreen(),
                          ),
                        ),
                        icon: const Icon(Icons.map_outlined),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
    ),

    toolbarHeight: hasSearchHeader ? 200 : 174,

  );
}
}


class _CouponFilterDialog extends StatefulWidget {
  const _CouponFilterDialog();

  @override
  State<_CouponFilterDialog> createState() => _CouponFilterDialogState();
}

class _CouponFilterDialogState extends State<_CouponFilterDialog> {
  TextEditingController minPriceController = TextEditingController();
  TextEditingController maxPriceController = TextEditingController();

  bool reductionIsPercentage = true;
  bool reductionIsFixed = true;
  double minReputation = 0;

  @override
  void initState() {
    super.initState();
    context.read<CouponListBloc>().add(ReadCouponFilters());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CouponListBloc, CouponListState>(
      listenWhen: (previous, current) => current is CouponListFilterRead,
      listener: (context, state) {
        if (state is CouponListFilterRead) {
          setState(() {
            reductionIsPercentage = state.reductionIsPercentage ?? true;
            reductionIsFixed = state.reductionIsFixed ?? true;
            minReputation = (state.minReputation ?? 0).toDouble();
            minPriceController.text =
                state.minPrice != null ? state.minPrice.toString() : '';
            maxPriceController.text =
                state.maxPrice != null ? state.maxPrice.toString() : '';
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
                            )
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
                                context.read<CouponListBloc>().add(ClearCouponFilters());
                              },
                            ),
                            CustomTextButton.primary(
                              label: 'Zastosuj',
                              icon: const Icon(Icons.check),
                              onTap: () {
                                Navigator.of(context).pop();
                                context.read<CouponListBloc>().add(
                                  ApplyCouponFilters(
                                    reductionIsFixed: reductionIsFixed,
                                    reductionIsPercentage: reductionIsPercentage,
                                    minPrice: minPriceController.text.isEmpty ? null : double.tryParse(minPriceController.text.replaceAll(',', '.'),),
                                    maxPrice: maxPriceController.text.isEmpty ? null : double.tryParse(maxPriceController.text.replaceAll(',', '.')),
                                    minReputation: minReputation.toInt(),
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

class _CouponSortDialog extends StatefulWidget {
  const _CouponSortDialog();

  @override
  State<_CouponSortDialog> createState() => _CouponSortDialogState();
}

class _CouponSortDialogState extends State<_CouponSortDialog> {

  Ordering ordering = Ordering.creationDateDesc;

  @override
  void initState() {
    super.initState();
    context.read<CouponListBloc>().add(ReadCouponOrdering());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CouponListBloc, CouponListState>(
      listenWhen: (previous, current) => current is CouponListOrderingRead,
      listener: (context, state) {
        if (state is CouponListOrderingRead) {
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
                                  selected: (ordering == Ordering.creationDateDesc),
                                  onTap: () => setState(() {ordering = Ordering.creationDateDesc;}),
                                ),
                                CustomRadioButton(
                                  label: 'od najstarszych',
                                  selected: (ordering == Ordering.creationDateAsc),
                                  onTap: () => setState(() {ordering = Ordering.creationDateAsc;}),
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
                                  selected: (ordering == Ordering.priceAsc),
                                  onTap: () => setState(() {ordering = Ordering.priceAsc;}),
                                ),
                                CustomRadioButton(
                                  label: 'od najwyższej',
                                  selected: (ordering == Ordering.priceDesc),
                                  onTap: () => setState(() {ordering = Ordering.priceDesc;}),
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
                                  selected: (ordering == Ordering.reputationAsc),
                                  onTap: () => setState(() {ordering = Ordering.reputationAsc;}),
                                ),
                                CustomRadioButton(
                                  label: 'od najwyższej',
                                  selected: (ordering == Ordering.reputationDesc),
                                  onTap: () => setState(() {ordering = Ordering.reputationDesc;}),
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
                                  selected: (ordering == Ordering.expiryDateAsc),
                                  onTap: () => setState(() {ordering = Ordering.expiryDateAsc;}),
                                ),
                                CustomRadioButton(
                                  label: 'od najdalszej',
                                  selected: (ordering == Ordering.expiryDateDesc),
                                  onTap: () => setState(() {ordering = Ordering.expiryDateDesc;}),
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
                                context.read<CouponListBloc>().add(
                                  ApplyCouponOrdering(ordering),
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
