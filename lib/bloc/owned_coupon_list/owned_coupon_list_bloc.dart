import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:proj_inz/data/models/owned_coupon_model.dart';
import 'package:proj_inz/data/repositories/coupon_repository.dart';

part 'owned_coupon_list_event.dart';
part 'owned_coupon_list_state.dart';

enum OwnedCouponsOrdering {
  purchaseDateAsc,
  purchaseDateDesc,
  expiryDateAsc,
  expiryDateDesc,
  priceAsc,
  priceDesc,
}

void _resetFiltersAndOrdering() {
  _reductionIsPercentage = true;
  _reductionIsFixed = true;
  _showUsed = true;
  _showUnused = true;
  _shopId = null;

  _ordering = OwnedCouponsOrdering.purchaseDateDesc;
}

// filters state
bool _reductionIsPercentage = true;
bool _reductionIsFixed = true;
bool _showUsed = true;
bool _showUnused = true;
String? _shopId;

// ordering state
OwnedCouponsOrdering _ordering = OwnedCouponsOrdering.purchaseDateDesc;

class OwnedCouponListBloc extends Bloc<OwnedCouponListEvent, OwnedCouponListState> {
  final CouponRepository couponRepository;
  final int limit = 50;
  
  final List<OwnedCoupon> _allCoupons = [];
  DocumentSnapshot? _lastDocument;
  bool _hasMore = true;
  bool _isFetching = false;

  List<OwnedCoupon> get allCoupons => List.unmodifiable(_allCoupons);

  OwnedCouponListBloc(this.couponRepository) : super(OwnedCouponListInitial()) {
    _resetFiltersAndOrdering();
    on<FetchCoupons>(_onFetchCoupons);
    on<FetchMoreCoupons>(_onFetchMoreCoupons);
    on<RefreshCoupons>(_onRefreshCoupons);

    // filters
    on<ReadOwnedCouponFilters>(_onReadFilters);
    on<ApplyOwnedCouponFilters>(_onApplyFilters);
    on<ClearOwnedCouponFilters>(_onClearFilters);

    // sorting
    on<ReadOwnedCouponOrdering>(_onReadOrdering);
    on<ApplyOwnedCouponOrdering>(_onApplyOrdering);
  }


    Future<void> _onFetchCoupons(FetchCoupons event, Emitter<OwnedCouponListState> emit) async {
    emit(OwnedCouponListLoadInProgress());
    _allCoupons.clear();
    _lastDocument = null;
    _hasMore = true;
    add(FetchMoreCoupons());
  }

  Future<void> _onFetchMoreCoupons(FetchMoreCoupons event, Emitter<OwnedCouponListState> emit) async {
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
      final ownedCoupons = result.coupons;
      final lastDoc = result.lastDocument;
      debugPrint('Fetched ${ownedCoupons.length} coupons: $ownedCoupons');

      _hasMore = ownedCoupons.length == limit;
      _allCoupons.addAll(ownedCoupons);
      _lastDocument = lastDoc;

      // apply filters
      var filtered = _allCoupons.where((c) {
        if (_reductionIsPercentage && !_reductionIsFixed) {
          if (!c.reductionIsPercentage) return false;
        }
        else if (!_reductionIsPercentage && _reductionIsFixed) {
          if (c.reductionIsPercentage) return false;
        }
        else if (!_reductionIsPercentage && !_reductionIsFixed) {
          return false;
        }

        if (!_showUsed && c.isUsed) return false;
        if (!_showUnused && !c.isUsed) return false;

        if (_shopId != null && c.shopId != _shopId) return false;

        return true;
      }).toList();

      // apply ordering
      filtered.sort((a, b) {
        switch (_ordering) {
          case OwnedCouponsOrdering.purchaseDateAsc:
            return (a.purchaseDate ?? DateTime(0))
                .compareTo(b.purchaseDate ?? DateTime(0));
          case OwnedCouponsOrdering.purchaseDateDesc:
            return (b.purchaseDate ?? DateTime(0))
                .compareTo(a.purchaseDate ?? DateTime(0));
          case OwnedCouponsOrdering.expiryDateAsc:
            return a.expiryDate.compareTo(b.expiryDate);
          case OwnedCouponsOrdering.expiryDateDesc:
            return b.expiryDate.compareTo(a.expiryDate);
          case OwnedCouponsOrdering.priceAsc:
            return a.price.compareTo(b.price);
          case OwnedCouponsOrdering.priceDesc:
            return b.price.compareTo(a.price);
        }
      });

      emit(OwnedCouponListLoadSuccess(coupons: filtered, hasMore: _hasMore));

      if (filtered.isEmpty) {
        emit(OwnedCouponListLoadEmpty());
      }


      if (_allCoupons.isEmpty) {
        emit(OwnedCouponListLoadEmpty());
      }
    } catch (e) {
      if (kDebugMode) debugPrint(e.toString());
      emit(OwnedCouponListLoadFailure(message: e.toString()));
    } finally {
      _isFetching = false;
    }
  }

  Future<void> _onRefreshCoupons(RefreshCoupons event, Emitter<OwnedCouponListState> emit) async {
    emit(OwnedCouponListLoadInProgress());
    _allCoupons.clear();
    _lastDocument = null;
    _hasMore = true;
    add(FetchCoupons());
  }

  // filter handlers
  void _onReadFilters(ReadOwnedCouponFilters event, Emitter emit) {
    emit(OwnedCouponFilterRead(
      reductionIsPercentage: _reductionIsPercentage,
      reductionIsFixed: _reductionIsFixed,
      showUsed: _showUsed,
      showUnused: _showUnused,
      shopId: _shopId,
    ));
  }

  void _onApplyFilters(ApplyOwnedCouponFilters event, Emitter emit) {
    _reductionIsPercentage = event.reductionIsPercentage;
    _reductionIsFixed = event.reductionIsFixed;
    _showUsed = event.showUsed;
    _showUnused = event.showUnused;
    _shopId = event.shopId;

    add(FetchCoupons());
  }

  void _onClearFilters(ClearOwnedCouponFilters event, Emitter emit) {
    _reductionIsPercentage = true;
    _reductionIsFixed = true;
    _showUsed = true;
    _showUnused = true;
    _shopId = null;

    add(FetchCoupons());
  }

  // sorting handlers
  void _onReadOrdering(ReadOwnedCouponOrdering event, Emitter emit) {
    emit(OwnedCouponOrderingRead(_ordering));
  }

  void _onApplyOrdering(ApplyOwnedCouponOrdering event, Emitter emit) {
    _ordering = event.ordering;
    add(FetchCoupons());
  }

}
