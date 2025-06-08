import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proj_inz/bloc/coupon_list/coupon_list_bloc.dart';
import 'package:proj_inz/presentation/widgets/coupon_card.dart';
import 'package:proj_inz/presentation/widgets/input/buttons/search_button.dart';

class BoughtCoupons extends StatelessWidget {
  const BoughtCoupons({ super.key });

  @override
  Widget build(BuildContext context){
    return BlocProvider.value(
      value: context.read<CouponListBloc>(),
      child: const _BoughtCouponsContent(),
    );
  }
}

class _BoughtCouponsContent extends StatefulWidget {
  const _BoughtCouponsContent();

  @override
  State<_BoughtCouponsContent> createState() => _BoughtCouponsContentState();
}

class _BoughtCouponsContentState extends State<_BoughtCouponsContent> {
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
    // Only fetch if the state is initial (not loaded yet)
    if (state is CouponListInitial) {
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
  return Scaffold(
    body: RefreshIndicator(
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
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final coupon = state.coupons[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: CouponCardHorizontal(coupon: coupon),
                      );
                    },
                    childCount: state.coupons.length,
                  ),
                );
              } else if (state is CouponListLoadFailure) {
                return SliverFillRemaining(
                  child: Center(child: Text('Error: ${state.message}')),
                );
              }
              return const SliverFillRemaining(
                child: Center(child: Text('No coupons available.')),
              );
            },
          ),
        ],
      ),
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
          Positioned( // hides coupons behind the toolbar
            left: 0,
            right: 0,
            top: 0,
            height: 60,
            child: Container(
              color: Colors.white,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
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
                  )
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: SearchButtonWide(
                label: 'Wyszukaj sklep lub kategorię',
                onTap: () {},
              ),
            ),
          ),
        ],
      ),
      toolbarHeight: 126,
    );
  }
}