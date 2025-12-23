import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:proj_inz/data/models/coupon_model.dart';
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
  
  final List<Coupon> _allCoupons = [];
  int? _lastOffset;
  bool _hasMore = true;
  bool _isFetching = false;
  String? _userId;

  List<Coupon> get allCoupons => List.unmodifiable(_allCoupons);

  List<({String id, String name})> get uniqueShops {
    final map = <String, String>{};

    for (final c in _allCoupons) {
      map[c.shopId] = c.shopName;
    }

    return map.entries
        .map((e) => (id: e.key, name: e.value))
        .toList();
  }

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
    _lastOffset = null;
    _hasMore = true;
    _userId = event.userId;
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
    if (_userId == null) {
      debugPrint("No user ID provided");
      emit(OwnedCouponListLoadFailure(message: 'User ID required'));
      return;
    }

    _isFetching = true;
    emit(OwnedCouponListLoadInProgress());

    // Map ordering enum to backend sort string
    String? sort;
    switch (_ordering) {
      case OwnedCouponsOrdering.purchaseDateAsc:
        sort = 'purchase+asc';
        break;
      case OwnedCouponsOrdering.purchaseDateDesc:
        sort = 'purchase+desc';
        break;
      case OwnedCouponsOrdering.expiryDateAsc:
        sort = 'expiry+asc';
        break;
      case OwnedCouponsOrdering.expiryDateDesc:
        sort = 'expiry+desc';
        break;
      case OwnedCouponsOrdering.priceAsc:
        sort = 'price+asc';
        break;
      case OwnedCouponsOrdering.priceDesc:
        sort = 'price+desc';
        break;
    }

    try {
      final result = await couponRepository.fetchOwnedCouponsPaginated(
        limit: limit,
        offset: _lastOffset ?? 0,
        userId: _userId!,
        reductionIsPercentage: _reductionIsPercentage,
        reductionIsFixed: _reductionIsFixed,
        showUsed: _showUsed,
        showUnused: _showUnused,
        shopId: _shopId,
        sort: sort,
      );
      final ownedCoupons = result.coupons;
      debugPrint('Fetched ${ownedCoupons.length} coupons: $ownedCoupons');

      _hasMore = ownedCoupons.length == limit;
      _allCoupons.addAll(ownedCoupons);
      _lastOffset = result.lastOffset;

      emit(OwnedCouponListLoadSuccess(coupons: _allCoupons, hasMore: _hasMore));

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
    _lastOffset = null;
    _hasMore = true;
    if (_userId != null) {
      add(FetchCoupons(userId: _userId!));
    }
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

    if (_userId != null) {
      add(FetchCoupons(userId: _userId!));
    }
  }

  void _onClearFilters(ClearOwnedCouponFilters event, Emitter emit) {
    _reductionIsPercentage = true;
    _reductionIsFixed = true;
    _showUsed = true;
    _showUnused = true;
    _shopId = null;

    if (_userId != null) {
      add(FetchCoupons(userId: _userId!));
    }
  }

  // sorting handlers
  void _onReadOrdering(ReadOwnedCouponOrdering event, Emitter emit) {
    emit(OwnedCouponOrderingRead(_ordering));
  }

  void _onApplyOrdering(ApplyOwnedCouponOrdering event, Emitter emit) {
    _ordering = event.ordering;
    if (_userId != null) {
      add(FetchCoupons(userId: _userId!));
    }
  }

}
