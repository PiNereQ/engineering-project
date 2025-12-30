import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:proj_inz/bloc/saved_coupon_list/saved_coupon_list_bloc.dart';
import 'package:proj_inz/core/theme.dart';
import 'package:proj_inz/data/models/coupon_model.dart';
import 'package:proj_inz/data/repositories/coupon_repository.dart';
import 'package:proj_inz/presentation/widgets/coupon_card.dart';

class SavedCouponListScreen extends StatefulWidget {
  const SavedCouponListScreen({super.key});

  @override
  State<SavedCouponListScreen> createState() => _SavedCouponListScreenState();
}

class _SavedCouponListScreenState extends State<SavedCouponListScreen> {
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
        context.read<SavedCouponListBloc>().add(FetchMoreSavedCoupons());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return BlocProvider(
      create: (context) => SavedCouponListBloc(
        context.read<CouponRepository>(),
      )..add(FetchSavedCoupons(userId: userId)),
      child: BlocBuilder<SavedCouponListBloc, SavedCouponListState>(
        builder: (context, state) {
          if (!_scrollListenerAdded) {
            _setupScrollListener(context);
            _scrollListenerAdded = true;
          }

          return Scaffold(
            backgroundColor: AppColors.background,
            body: SafeArea(
              child: RefreshIndicator(
                onRefresh: () async {
                  context
                      .read<SavedCouponListBloc>()
                      .add(RefreshSavedCoupons());
                },
                child: CustomScrollView(
                  controller: _scrollController,
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

  Widget _listContent(SavedCouponListState state) {
    if (state is SavedCouponListInitial) {
      return const SliverFillRemaining(
        child: Center(
          child: CircularProgressIndicator(color: AppColors.textPrimary),
        ),
      );
    }

    if (state is SavedCouponListLoadInProgress && state.coupons.isEmpty) {
      return const SliverFillRemaining(
        child: Center(
          child: CircularProgressIndicator(color: AppColors.textPrimary),
        ),
      );
    }

    if (state is SavedCouponListLoadEmpty) {
      return const SliverFillRemaining(
        child: Center(
          child: Text(
            'Nie masz zapisanych kuponów.',
            style: TextStyle(
              fontSize: 18,
              fontFamily: 'Itim',
              color: AppColors.textPrimary,
            ),
          ),
        ),
      );
    }

    if (state is SavedCouponListLoadFailure) {
      return SliverFillRemaining(
        child: Center(child: Text(state.message)),
      );
    }

    final coupons = switch (state) {
      SavedCouponListLoadSuccess s => s.coupons,
      SavedCouponListLoadInProgress s => s.coupons,
      _ => const <Coupon>[],
    };

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index == coupons.length) {
              return const SizedBox(height: 86);
            }
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: CouponCardHorizontal(coupon: coupons[index]),
            );
          },
          childCount: coupons.length + 1,
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
      elevation: 0,
      title: const Text(
        'Zapisane kupony',
        style: TextStyle(
          fontFamily: 'Itim',
          fontSize: 22,
          color: AppColors.textPrimary,
        ),
      ),
      leading: BackButton(color: AppColors.textPrimary),
    );
  }
}