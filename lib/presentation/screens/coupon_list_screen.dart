import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

import 'package:proj_inz/bloc/coupon_list/coupon_list_bloc.dart';
import 'package:proj_inz/bloc/search_shops_categories/search_shops_categories_bloc.dart';
import 'package:proj_inz/bloc/search_shops_categories/search_shops_categories_event.dart';
import 'package:proj_inz/presentation/screens/search_results_screen.dart';
import 'package:proj_inz/data/repositories/shop_repository.dart';
import 'package:proj_inz/data/repositories/category_repository.dart';
import 'package:proj_inz/presentation/widgets/coupon_card.dart';
import 'package:proj_inz/presentation/widgets/error_card.dart';
import 'package:proj_inz/presentation/widgets/input/buttons/checkbox.dart';
import 'package:proj_inz/presentation/widgets/input/buttons/custom_icon_button.dart';
import 'package:proj_inz/presentation/widgets/input/buttons/custom_text_button.dart';
import 'package:proj_inz/presentation/widgets/input/buttons/radio_button.dart';
import 'package:proj_inz/presentation/widgets/input/text_fields/search_bar.dart';
import 'package:proj_inz/presentation/widgets/input/text_fields/custom_text_field.dart';

// Local debugging flags
bool stopCouponLoading = false; // Default to false

class CouponListScreen extends StatelessWidget {
  final String? selectedShopId;
  final String? searchShopName;
  const CouponListScreen({super.key, this.selectedShopId, this.searchShopName});

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
      ),
    );
  }
}


class _CouponListScreenContent extends StatefulWidget {
  final String? selectedShopId;
  final String? searchShopName;
  const _CouponListScreenContent({this.selectedShopId, this.searchShopName});

  @override
  State<_CouponListScreenContent> createState() =>
      _CouponListScreenContentState();
}

class _CouponListScreenContentState extends State<_CouponListScreenContent> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 150) {
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
    final bloc = context.read<CouponListBloc>();
    final state = bloc.state;
    // Only fetch if the state is initial (not loaded yet) and debug flag is off
    if (state is CouponListInitial && !stopCouponLoading) {
      bloc.add(FetchCoupons(shopId: widget.selectedShopId));
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<CouponListBloc>().add(RefreshCoupons());
      },
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          _Toolbar(searchShopName: widget.searchShopName),
          BlocBuilder<CouponListBloc, CouponListState>(
            builder: (context, state) {
              if (state is CouponListLoadInProgress) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              } else if (state is CouponListLoadSuccess) {
                return SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final coupon = state.coupons[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: CouponCardHorizontal(coupon: coupon),
                    );
                  }, childCount: state.coupons.length),
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
                          color: Colors.black,
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
    );
  }
}

class _Toolbar extends StatelessWidget {
  final String? searchShopName;

  const _Toolbar({this.searchShopName});

@override
Widget build(BuildContext context) {
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
          child: Container(color: Colors.white),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
          child: Container(
            width: double.infinity,
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (searchShopName != null)
                  Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Row(
                    children: [
                      // przycisk wstecz
                      InkWell(
                        borderRadius: BorderRadius.circular(1000),
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          clipBehavior: Clip.antiAlias,
                          decoration: ShapeDecoration(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              side: const BorderSide(width: 2),
                              borderRadius: BorderRadius.circular(1000),
                            ),
                            shadows: const [
                              BoxShadow(
                                color: Color(0xFF000000),
                                blurRadius: 0,
                                offset: Offset(3, 3),
                                spreadRadius: 0,
                              )
                            ],
                          ),
                          child: SvgPicture.asset(
                            'icons/back.svg',
                            width: 18,
                            height: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // "wyszukiwanie dla sklepu: <nazwa>"
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                          decoration: ShapeDecoration(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              side: const BorderSide(width: 2),
                              borderRadius: BorderRadius.circular(16),
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
                          child: Text(
                            'Wyniki dla sklepu: $searchShopName',
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontFamily: 'Itim',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
                else
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: SearchBarWide(
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
                  ),
                Row(
                  children: [
                    CustomTextButton.iconSmall(
                      label: 'Filtruj',
                      onTap: () => showDialog(
                        context: context,
                        builder: (dialogContext) => BlocProvider.value(
                          value: context.read<CouponListBloc>(),
                          child: const _CouponFilterDialog(),
                        ),
                      ).then((_) {
                        if (context.mounted) {
                          context.read<CouponListBloc>().add(LeaveCouponFilterPopUp());
                        }
                      }),
                      icon: const Icon(Icons.filter_alt),
                    ),
                    CustomTextButton.iconSmall(
                      label: 'Sortuj',
                      onTap: () => showDialog(
                        context: context,
                        builder: (dialogContext) => BlocProvider.value(
                          value: context.read<CouponListBloc>(),
                          child: const _CouponSortDialog(),
                        ),
                      ).then((_) {
                        if (context.mounted) {
                          context.read<CouponListBloc>().add(LeaveCouponSortPopUp());
                        }
                      }),
                      icon: const Icon(Icons.sort),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    ),
    toolbarHeight: 200,
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
      child: Scaffold(
        body: SingleChildScrollView(
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
                        // icon: SvgPicture.asset('icons/back.svg'),
                        // TODO: svg crash fix
                        icon: const Icon(Icons.arrow_back),
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
                          color: Colors.black,
                          fontSize: 24,
                          fontFamily: 'Itim',
                          fontWeight: FontWeight.w400,
                          ),
                        ),
                        ),
                        const Divider(
                        color: Colors.black,
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
                                          color: Colors.black,
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

                            const Divider(
                              color: Colors.black,
                              thickness: 1,
                              height: 1,
                            ),
                                            
                            Column( // Cena
                              children: [
                                const Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                      'Cena',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 20,
                                          fontFamily: 'Itim',
                                          fontWeight: FontWeight.w400,
                                      ),
                                  )
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: CustomTextField(
                                        label: 'od',
                                        controller: minPriceController,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text('-'),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: CustomTextField(
                                        label: 'do',
                                        controller: maxPriceController,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            const Divider(
                              color: Colors.black,
                              thickness: 1,
                              height: 1,
                            ),
                                            
                            Column( // Reputacja
                              children: [
                                const Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                      'Min. reputacja sprzedającego',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 20,
                                          fontFamily: 'Itim',
                                          fontWeight: FontWeight.w400,
                                      ),
                                  )
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Slider(
                                        value: minReputation,
                                        divisions: 1,
                                        min: 0,
                                        max: 100,
                                        activeColor: Colors.lightGreen,
                                        onChanged: (v) => setState(() => minReputation = v),
                                      ),
                                    ),
                                    Text(minReputation.round().toString()),
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
                            CustomTextButton.icon(
                              label: 'Wyczyść',
                              icon: const Icon(Icons.delete_outline),
                              onTap: () {
                                Navigator.of(context).pop();
                                context.read<CouponListBloc>().add(ClearCouponFilters());
                              },
                            ),
                            CustomTextButton.icon(
                              label: 'Zastosuj',
                              icon: const Icon(Icons.check),
                              onTap: () {
                                Navigator.of(context).pop();
                                context.read<CouponListBloc>().add(
                                  ApplyCouponFilters(
                                    reductionIsFixed: reductionIsFixed,
                                    reductionIsPercentage: reductionIsPercentage,
                                    minPrice: minPriceController.text.isEmpty ? null : double.tryParse(minPriceController.text),
                                    maxPrice: maxPriceController.text.isEmpty ? null : double.tryParse(maxPriceController.text),
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
      child: Scaffold(
        body: SingleChildScrollView(
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
                        // icon: SvgPicture.asset('icons/back.svg'),
                        // TODO: svg crash fix
                        icon: const Icon(Icons.arrow_back),
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
                          color: Colors.black,
                          fontSize: 24,
                          fontFamily: 'Itim',
                          fontWeight: FontWeight.w400,
                          ),
                        ),
                        ),
                        const Divider(
                        color: Colors.black,
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
                                          color: Colors.black,
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
                                          color: Colors.black,
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
                                          color: Colors.black,
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
                                          color: Colors.black,
                                          fontSize: 20,
                                          fontFamily: 'Itim',
                                          fontWeight: FontWeight.w400,
                                      ),
                                  )
                                ),
                                CustomRadioButton(
                                  label: 'od najbliszej',
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
                            CustomTextButton.icon(
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
