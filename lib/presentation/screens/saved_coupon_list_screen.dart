import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:proj_inz/bloc/saved_coupon_list/saved_coupon_list_bloc.dart';
import 'package:proj_inz/core/theme.dart';
import 'package:proj_inz/data/repositories/coupon_repository.dart';
import 'package:proj_inz/presentation/widgets/coupon_card.dart';

class SavedCouponListScreen extends StatelessWidget {
  const SavedCouponListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return BlocProvider(
      create: (context) => SavedCouponListBloc(
        context.read<CouponRepository>(),
      )..add(FetchSavedCoupons(userId: userId)),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              context
                  .read<SavedCouponListBloc>()
                  .add(RefreshSavedCoupons(userId: userId));
            },
            child: CustomScrollView(
              slivers: const [
                _Toolbar(),
                _SavedCouponsContent(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SavedCouponsContent extends StatelessWidget {
  const _SavedCouponsContent();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SavedCouponListBloc, SavedCouponListState>(
      builder: (context, state) {
        if (state is SavedCouponListLoadInProgress ||
            state is SavedCouponListInitial) {
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

        if (state is SavedCouponListLoadSuccess) {
          return SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final coupon = state.coupons[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: CouponCardHorizontal(coupon: coupon),
                  );
                },
                childCount: state.coupons.length,
              ),
            ),
          );
        }

        return const SliverFillRemaining(child: SizedBox.shrink());
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