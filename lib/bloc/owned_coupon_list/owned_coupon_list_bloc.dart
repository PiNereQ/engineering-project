import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:proj_inz/data/models/coupon_model.dart';
import 'package:proj_inz/data/repositories/coupon_repository.dart';

part 'owned_coupon_list_event.dart';
part 'owned_coupon_list_state.dart';

class OwnedCouponListBloc extends Bloc<OwnedCouponListEvent, OwnedCouponListState> {
  final CouponRepository couponRepository;
  final int limit = 50;
  
  final List<Coupon> _allCoupons = [];
  DocumentSnapshot? _lastDocument;
  bool _hasMore = true;
  bool _isFetching = false;

  OwnedCouponListBloc(this.couponRepository) : super(OwnedCouponListInitial()) {
    on<FetchCoupons>(_onFetchCoupons);
    on<FetchMoreCoupons>(_onFetchMoreCoupons);
    on<RefreshCoupons>(_onRefreshCoupons);
  }

    _onFetchCoupons(FetchCoupons event, Emitter<OwnedCouponListState> emit) async {
    emit(OwnedCouponListLoadInProgress());
    _allCoupons.clear();
    _lastDocument = null;
    _hasMore = true;
    add(FetchMoreCoupons());
  }

  _onFetchMoreCoupons(FetchMoreCoupons event, Emitter<OwnedCouponListState> emit) async {
    if (_isFetching) {
      debugPrint("Still loading");
      return;
    }
    if (!_hasMore) {
      debugPrint("No more coupons to load.");
      return;
    }

    _isFetching = true;
    emit(OwnedCouponListLoadInProgress());

    try {
      final result = await couponRepository.fetchOwnedCouponsPaginated(limit, _lastDocument);
      final coupons = result.coupons;
      final lastDoc = result.lastDocument;
      debugPrint('Fetched ${coupons.length} coupons: $coupons');

      _hasMore = coupons.length == limit;
      _allCoupons.addAll(coupons);
      _lastDocument = lastDoc;

      if (_allCoupons.isEmpty) {
        emit(OwnedCouponListLoadEmpty());
      }

      emit(OwnedCouponListLoadSuccess(coupons: _allCoupons, hasMore: _hasMore));
    } catch (e) {
      if (kDebugMode) debugPrint(e.toString());
      emit(OwnedCouponListLoadFailure(message: e.toString()));
    } finally {
      _isFetching = false;
    }
  }

  _onRefreshCoupons(RefreshCoupons event, Emitter<OwnedCouponListState> emit) async {
    _allCoupons.clear();
    _lastDocument = null;
    _hasMore = true;
    add(FetchCoupons());
  }
}
