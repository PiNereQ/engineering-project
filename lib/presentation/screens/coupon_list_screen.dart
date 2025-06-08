import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

import 'package:proj_inz/bloc/coupon_list/coupon_list_bloc.dart';
import 'package:proj_inz/presentation/widgets/coupon_card.dart';
import 'package:proj_inz/presentation/widgets/input/buttons/checkbox.dart';
import 'package:proj_inz/presentation/widgets/input/buttons/custom_icon_button.dart';
import 'package:proj_inz/presentation/widgets/input/buttons/custom_text_button.dart';
import 'package:proj_inz/presentation/widgets/input/buttons/search_button.dart';
import 'package:proj_inz/presentation/widgets/input/text_fields/custom_text_field.dart';

// Local debugging flags
bool stopCouponLoading = false; // Default to false

class CouponListScreen extends StatelessWidget {
  const CouponListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: context.read<CouponListBloc>(),
      child: const _CouponListScreenContent(),
    );
  }
}

class _CouponListScreenContent extends StatefulWidget {
  const _CouponListScreenContent();

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
      bloc.add(FetchCoupons());
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
          const _Toolbar(),
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
              } else if (state is CouponListLoadFailure) {
                return SliverFillRemaining(
                  child: Center(child: Text(state.message)),
                );
              }
              return const SliverFillRemaining(
                child: Center(child: Text('Nie znaleźliśmy wyników pasujących do Twoich filtrów.')),
              );
            },
          ),
        ],
      ),
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
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Stack(
        children: [
          Positioned(
            // hides coupons behind the toolbar
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
                mainAxisAlignment: MainAxisAlignment.start,
                spacing: 16,
                children: [
                  SearchButtonWide(
                    label: 'Wyszukaj sklep lub kategorię',
                    onTap: () {},
                  ),
                  Row(
                    children: [
                      CustomTextButton.iconSmall(
                        label: 'Filtruj',
                        onTap:
                            () => showDialog(
                              context: context,
                              builder: (dialogContext) => BlocProvider.value(
                                value: context.read<CouponListBloc>(),
                                child: const _CouponFilterDialog(),
                              ),
                            ).then((_) {
                              if (context.mounted) {
                                context.read<CouponListBloc>().add(LeaveCouponFiltersPopUp());
                              }
                            }),
                        icon: const Icon(Icons.filter_alt),
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
                        icon: SvgPicture.asset('icons/back.svg'),
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
