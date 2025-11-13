import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:proj_inz/bloc/owned_coupon_list/owned_coupon_list_bloc.dart';
import 'package:proj_inz/data/repositories/coupon_repository.dart';
import 'package:proj_inz/presentation/widgets/coupon_card.dart';
import 'package:proj_inz/presentation/widgets/error_card.dart';
import 'package:proj_inz/presentation/widgets/input/buttons/custom_icon_button.dart';
import 'package:proj_inz/presentation/widgets/input/buttons/search_button.dart';

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
            final coupon = state.coupons[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: CouponCardHorizontal.bought(coupon: coupon),
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
      automaticallyImplyLeading: false, // removes back button
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: 12,
                children: [
                  CustomIconButton(
                    icon: SvgPicture.asset('assets/icons/back.svg'),
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  Expanded(
                    child: SearchButtonWide(label: 'Wyszukaj...', onTap: () {}),
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
