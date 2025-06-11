import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import 'package:proj_inz/data/models/coupon_model.dart';
import 'package:proj_inz/data/repositories/coupon_repository.dart';

part 'coupon_list_event.dart';
part 'coupon_list_state.dart';

enum Ordering {creationDateAsc, creationDateDesc,
                priceAsc, priceDesc,
                reputationAsc, reputationDesc,
                expiryDateAsc, expiryDateDesc}

class CouponListBloc extends Bloc<CouponListEvent, CouponListState> {
  final CouponRepository couponRepository;
  CouponListState _previousListState = CouponListInitial();

  final int _limit = 50;
  
  final List<Coupon> _allCoupons = [];
  DocumentSnapshot? _lastDocument;
  bool _hasMore = true;
  bool _isFetching = false;

  // filters
  bool? _reductionIsFixed;
  bool? _reductionIsPercentage; 
  double? _minPrice; 
  double? _maxPrice; 
  int? _minReputation; 

  // sorting
  Ordering _ordering = Ordering.creationDateDesc;

  CouponListBloc(this.couponRepository) : super(CouponListInitial()) {
    on<FetchCoupons>(_onFetchCoupons);
    on<FetchMoreCoupons>(_onFetchMoreCoupons);
    on<RefreshCoupons>(_onRefreshCoupons);
    on<ApplyCouponFilters>(_onApplyCouponFilters);
    on<ClearCouponFilters>(_onClearCouponFilters);
    on<ReadCouponFilters>(_onReadCouponFilters);
    on<LeaveCouponFilterPopUp>(_onLeaveCouponFilterPopUp);
    on<ApplyCouponOrdering>(_onApplyCouponOrdering);
    on<ReadCouponOrdering>(_onReadCouponOrdering);
    on<LeaveCouponSortPopUp>(_onLeaveCouponSortPopUp);
  }

  _onFetchCoupons(FetchCoupons event, Emitter<CouponListState> emit) async {
    emit(CouponListLoadInProgress());
    _allCoupons.clear();
    _lastDocument = null;
    _hasMore = true;
    add(FetchMoreCoupons());
  }

  _onFetchMoreCoupons(FetchMoreCoupons event, Emitter<CouponListState> emit) async {
    if (_isFetching) {
      debugPrint("Still loading");
      return;
    }
    if (!_hasMore) {
      debugPrint("No more coupons to load.");
      return;
    }

    _isFetching = true;
    emit(CouponListLoadInProgress());

    try {
      final result = await couponRepository.fetchCouponsPaginated(
        limit: _limit,
        startAfter: _lastDocument,
        reductionIsFixed: _reductionIsFixed,
        reductionIsPercentage: _reductionIsPercentage,
        minPrice: _minPrice,
        maxPrice: _maxPrice,
        minReputation: _minReputation,
        ordering: _ordering
      );
      final coupons = result.coupons;
      final lastDoc = result.lastDocument;
      debugPrint('Fetched ${coupons.length} coupons: $coupons');

      _hasMore = coupons.length == _limit;
      _allCoupons.addAll(coupons);
      _lastDocument = lastDoc;

      var successState = CouponListLoadSuccess(coupons: _allCoupons, hasMore: _hasMore);
      _previousListState = successState;
      emit(successState);

      if (_allCoupons.isEmpty) {
        var failureState = const CouponListLoadFailure(message: 'Nie znaleziono kuponów.');
        _previousListState = failureState;
        emit(failureState);
      }
    } catch (e) {
      if (kDebugMode) debugPrint(e.toString());
      var failureState = CouponListLoadFailure(message: e.toString());
      _previousListState = failureState;
      emit(failureState);
    } finally {
      _isFetching = false;
    }
  }

  _onRefreshCoupons(RefreshCoupons event, Emitter<CouponListState> emit) async {
    _allCoupons.clear();
    _lastDocument = null;
    _hasMore = true;
    add(FetchCoupons());
  }

  _onApplyCouponFilters(ApplyCouponFilters event, Emitter<CouponListState> emit) {
    if (kDebugMode) debugPrint('Applied filters:\n\t%:${event.reductionIsFixed}\tzł:${event.reductionIsPercentage}\n\tminPrice:${event.minPrice}\tmaxPrice:${event.maxPrice}\n\trep:${event.minReputation}');
    emit(CouponListFilterApplyInProgress());
    _reductionIsFixed = event.reductionIsFixed;
    _reductionIsPercentage = event.reductionIsPercentage;
    _minPrice = event.minPrice;
    _maxPrice = event.maxPrice;
    _minReputation = event.minReputation;
    emit(CouponListFilterApplySuccess(
      _reductionIsPercentage,
      _reductionIsFixed,
      _minPrice,
      _maxPrice,
      _minReputation
    ));

    add(FetchCoupons());
  }

  _onClearCouponFilters(ClearCouponFilters event, Emitter<CouponListState> emit) {
    if (kDebugMode) debugPrint('Filters cleared.');
    _reductionIsFixed = null;
    _reductionIsPercentage = null;
    _minPrice = null;
    _maxPrice = null;
    _minReputation = null;
    emit(CouponListFilterApplySuccess(
      _reductionIsPercentage,
      _reductionIsFixed,
      _minPrice,
      _maxPrice,
      _minReputation
    ));

    add(FetchCoupons());
  }

  _onReadCouponFilters(ReadCouponFilters event, Emitter<CouponListState> emit) {
    emit(CouponListFilterRead(
      reductionIsPercentage: _reductionIsPercentage,
      reductionIsFixed: _reductionIsFixed,
      minPrice: _minPrice,
      maxPrice: _maxPrice, 
      minReputation: _minReputation
    ));
  }

  _onLeaveCouponFilterPopUp(LeaveCouponFilterPopUp event, Emitter<CouponListState> emit) {
    emit(_previousListState);
  }

  _onApplyCouponOrdering(ApplyCouponOrdering event, Emitter<CouponListState> emit) {
    if (kDebugMode) debugPrint('Applied order:\t%:${event.ordering}');
    emit(CouponListOrderingApplyInProgress());
    _ordering = event.ordering;
    emit(CouponListOrderingApplySuccess(_ordering));

    add(FetchCoupons());
  }

  _onReadCouponOrdering(ReadCouponOrdering event, Emitter<CouponListState> emit) {
    emit(CouponListOrderingRead(_ordering));
  }

  _onLeaveCouponSortPopUp(LeaveCouponSortPopUp event, Emitter<CouponListState> emit) {
    emit(_previousListState);
  }
}
