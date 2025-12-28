import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:flutter_map_cache/flutter_map_cache.dart';
import 'package:flutter_svg/svg.dart';
import 'package:proj_inz/bloc/coupon_list/coupon_list_bloc.dart';
import 'package:proj_inz/data/models/shop_location_model.dart';
import 'package:proj_inz/presentation/screens/coupon_list_screen.dart';
import 'package:proj_inz/presentation/widgets/coupon_card.dart';
import 'package:proj_inz/presentation/widgets/help/help_button.dart';

import 'package:url_launcher/url_launcher.dart';
import 'package:app_settings/app_settings.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:proj_inz/bloc/coupon_map/coupon_map_bloc.dart';
import 'package:proj_inz/data/repositories/map_repository.dart';
import 'package:proj_inz/data/repositories/coupon_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:proj_inz/bloc/map_cache/map_cache_bloc.dart';
import 'package:proj_inz/data/repositories/map_cache_repository.dart';
import 'package:proj_inz/presentation/widgets/custom_snack_bar.dart';
import 'package:proj_inz/presentation/widgets/input/buttons/custom_icon_button.dart';
import 'package:proj_inz/presentation/widgets/input/buttons/custom_text_button.dart';
import 'package:proj_inz/presentation/widgets/coupon_map/location_dot.dart';
import 'package:proj_inz/presentation/widgets/coupon_map/shop_location.dart';
import 'package:proj_inz/core/theme.dart';
import 'package:proj_inz/core/map/grid_cluster.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<MapCacheBloc>(
          create:
              (context) =>
                  MapCacheBloc(mapCacheRepository: MapCacheRepository())
                    ..add(MapCacheInitialiseRequested()),
        ),
        BlocProvider<CouponMapBloc>(
          create: (context) => CouponMapBloc(
            mapRepository: MapRepository(),
            couponRepository: CouponRepository(),
          ),
        ),
      ],
      child: const _MapScreenView(),
    );
  }
}

class _MapScreenView extends StatefulWidget {
  const _MapScreenView();

  @override
  State<_MapScreenView> createState() => _MapScreenViewState();
}

class _MapScreenViewState extends State<_MapScreenView>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  bool _isMapLoading = true;
  AnimatedMapController? _mapController;
  bool _isUserLocationEnabled = false;
  bool _isUserLocationLoading = false;
  LatLng? _currentUserLocation;
  bool _waitingForUserLocationSettings = false;
  Timer? _userLocationUpdateTimer;
  double? _lastZoomLevel;

  @override
  void initState() {
    super.initState();
    _mapController = AnimatedMapController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      cancelPreviousAnimations: true
    );
    WidgetsBinding.instance.addObserver(this);
  }

  Future<void> _saveMapState() async {
    if (_mapController != null) {
      final prefs = await SharedPreferences.getInstance();
      final center = _mapController!.mapController.camera.center;
      final zoom = _mapController!.mapController.camera.zoom;

      await prefs.setDouble('map_latitude', center.latitude);
      await prefs.setDouble('map_longitude', center.longitude);
      await prefs.setDouble('map_zoom_level', zoom);
    }
  }

  @override
  void dispose() {
    _saveMapState();
    WidgetsBinding.instance.removeObserver(this);
    _mapController?.dispose();
    _userLocationUpdateTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _waitingForUserLocationSettings) {
      _waitingForUserLocationSettings = false;
      // Retry getting location when app resumes
      _locationButtonPressed();
    }
  }

  void _startLocationUpdates() {
    _userLocationUpdateTimer?.cancel();
    _userLocationUpdateTimer = Timer.periodic(const Duration(seconds: 3), (
      timer,
    ) {
      if (_isUserLocationEnabled && !_isUserLocationLoading) {
        _updateLocation();
      }
    });
  }

  void _stopLocationUpdates() {
    _userLocationUpdateTimer?.cancel();
  }

  Future<void> _updateLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition();
      final newPosition = LatLng(position.latitude, position.longitude);
      debugPrint(newPosition.toString());

      if (mounted) {
        setState(() {
          _currentUserLocation = newPosition;
        });
      }
    } catch (e) {
      debugPrint('Error updating location: $e');
      if (mounted) {
        setState(() {
          _isUserLocationEnabled = false;
          _currentUserLocation = null;
        });
        _stopLocationUpdates();
      }
    }
  }

  Future<void> _showLocationPermissionDialog() async {
    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: const BorderSide(width: 2, color: AppColors.textPrimary),
            ),
            title: const Text(
              'Dostęp do lokalizacji',
              style: TextStyle(
                fontFamily: 'Itim',
                fontSize: 22,
                fontWeight: FontWeight.w400,
                color: AppColors.textPrimary,
              ),
            ),
            content: const Text(
              'Potrzebujemy dostępu do lokalizacji, aby pokazać Twoją aktualną pozycję na mapie.',
              style: TextStyle(
                fontFamily: 'Itim',
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
            actionsPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            actions: [
              CustomTextButton.small(
                label: 'Rozumiem',
                width: 100,
                onTap: () => Navigator.of(context).pop(),
              ),
            ],
          ),
    );
  }

  Future<bool> _showLocationPermissionDenialDialog() async {
    final result = await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: const BorderSide(width: 2, color: AppColors.textPrimary),
            ),
            title: const Text(
              'Odmówiono dostępu do lokalizacji',
              style: TextStyle(
                fontFamily: 'Itim',
                fontSize: 22,
                fontWeight: FontWeight.w400,
                color: AppColors.textPrimary,
              ),
            ),
            content: const Text(
              'Czy chcesz przejść do ustawień aplikacji aby to zmienić?',
              style: TextStyle(
                fontFamily: 'Itim',
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
            actionsPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            actions: [
              CustomTextButton.small(
                label: 'Nie',
                width: 100,
                onTap: () => Navigator.of(context).pop(false),
              ),
              CustomTextButton.small(
                label: 'Tak',
                width: 100,
                onTap: () async {
                  Navigator.of(context).pop(true);
                },
              ),
            ],
          ),
    );
    return result ?? false;
  }

  Future<void> _showPremissionTipDialog() async {
    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: const BorderSide(width: 2, color: AppColors.textPrimary),
            ),
            title: const Text(
              'Porada',
              style: TextStyle(
                fontFamily: 'Itim',
                fontSize: 22,
                fontWeight: FontWeight.w400,
                color: AppColors.textPrimary,
              ),
            ),
            content: const Text(
              'Wejdź w sekcję "Uprawnienia", a następnie "Lokalizacja".',
              style: TextStyle(
                fontFamily: 'Itim',
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
            actionsPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            actions: [
              CustomTextButton.small(
                label: 'Rozumiem',
                width: 100,
                onTap: () => Navigator.of(context).pop(),
              ),
            ],
          ),
    );
  }

  Future<bool> _showServiceEnableDialog() async {
    final result = await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: const BorderSide(width: 2, color: AppColors.textPrimary),
            ),
            title: const Text(
              'Czy chcesz włączyć usługi lokalizacyjne?',
              style: TextStyle(
                fontFamily: 'Itim',
                fontSize: 22,
                fontWeight: FontWeight.w400,
                color: AppColors.textPrimary,
              ),
            ),
            actionsPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            actions: [
              CustomTextButton.small(
                label: 'Nie',
                width: 100,
                onTap: () => Navigator.of(context).pop(false),
              ),
              CustomTextButton.small(
                label: 'Tak',
                width: 100,
                onTap: () {
                  Navigator.of(context).pop(true);
                },
              ),
            ],
          ),
    );

    return result ?? false;
  }

  Future<Position> _getPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // https://github.com/Baseflow/flutter-geolocator/wiki/Breaking-changes-in-7.0.0#android-permission-update
    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      await _showLocationPermissionDialog();
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        return Future.error('Location permission denied.');
      }

      if (permission == LocationPermission.deniedForever) {
        final userWantsToChangePermission =
            await _showLocationPermissionDenialDialog();
        if (userWantsToChangePermission) {
          await _showPremissionTipDialog();
          AppSettings.openAppSettings();
        }

        return Future.error('Location permission denied forever.');
      }
    }

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      final userWantsLocation = await _showServiceEnableDialog();
      if (userWantsLocation) {
        _waitingForUserLocationSettings = true;
        Geolocator.openLocationSettings();
        if (mounted) {
          showCustomSnackBar(
            context,
            'Włącz usługi lokalizacji i wróć do aplikacji.',
          );
        }
        // The settings open and this function finishes.
        // After user returns to the app, didChangeAppLifecycleState() runs and checks for location services again.
        return Future.error('Waiting for location settings.');
      } else {
        if (mounted) {
          showCustomSnackBar(context, 'Usługi lokalizacji są wyłączone.');
        }
        return Future.error('Location service disabled.');
      }
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<void> _locationButtonPressed() async {
    if (_isUserLocationEnabled) {
      setState(() {
        _currentUserLocation = null;
        _isUserLocationEnabled = false;
      });
      _stopLocationUpdates();
      return;
    }

    try {
      setState(() {
        _isUserLocationLoading = true;
      });
      final position = await _getPosition();
      final newPosition = LatLng(position.latitude, position.longitude);

      setState(() {
        _currentUserLocation = newPosition;
        _isUserLocationEnabled = true;
      });

      _mapController?.animateTo(dest: newPosition, zoom: 16.0);
      _startLocationUpdates();
    } catch (e) {
      debugPrint('Error getting location: $e');
    } finally {
      setState(() {
        _isUserLocationLoading = false;
      });
    }
  }

  void _onMapMove() {
    if (_mapController != null) {
      final zoomLevel = _mapController!.mapController.camera.zoom;
      
      if (_lastZoomLevel == null || zoomLevel != _lastZoomLevel) {
        _lastZoomLevel = zoomLevel;
        context.read<CouponMapBloc>().add(
          CouponMapZoomLevelChanged(zoomLevel: zoomLevel),
        );
        // Force rebuild so clustering reflects new zoom level.
        setState(() {});
      }
    }
  }

  void _updateZoomTip() {
    if (_mapController != null) {
      final zoomLevel = _mapController!.mapController.camera.zoom;
      context.read<CouponMapBloc>().add(
        CouponMapZoomLevelChanged(zoomLevel: zoomLevel),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final apiKey = dotenv.env['GEOAPIFY_API_KEY'] ?? '';

    return BlocBuilder<CouponMapBloc, CouponMapState>(
      builder: (context, state) {
        Future<void> initializeMap() async {
          final prefs = await SharedPreferences.getInstance();
          final zoomLevel = prefs.getDouble('map_zoom_level') ?? 5.9;
          final latitude = prefs.getDouble('map_latitude') ?? 52.23;
          final longitude = prefs.getDouble('map_longitude') ?? 19.09;

          if (mounted) {
            setState(() {
              _mapController?.mapController.move(LatLng(latitude, longitude), zoomLevel);
            });

            _updateZoomTip();
          }

          if (_mapController != null) {
            if (zoomLevel >= 11) {
              final bounds = _mapController!.mapController.camera.visibleBounds;
              final customBounds = LatLngBounds(
                LatLng(bounds.southWest.latitude, bounds.southWest.longitude),
                LatLng(bounds.northEast.latitude, bounds.northEast.longitude),
              );
              context.read<CouponMapBloc>().add(
                LoadLocationsInBounds(bounds: customBounds),
              );
                        }
          }

          setState(() {
            _isMapLoading = false;
          });
        }

        void searchInCurrentView() {
          if (_mapController != null) {
            final zoomLevel = _mapController!.mapController.camera.zoom;
            if (zoomLevel < 11) return;

            final bounds = _mapController!.mapController.camera.visibleBounds;
            final customBounds = LatLngBounds(
              LatLng(bounds.southWest.latitude, bounds.southWest.longitude),
              LatLng(bounds.northEast.latitude, bounds.northEast.longitude),
            );
            context.read<CouponMapBloc>().add(
              LoadLocationsInBounds(bounds: customBounds),
            );
                    }
        }

        final double currentZoom =
            _isMapLoading
                ? 5.9
                : (_mapController?.mapController.camera.zoom ?? 5.9);
        final int zoomLevelInt = currentZoom.round();

        const clusteringMaxZoom = 17;
        final bool enableClustering = zoomLevelInt < clusteringMaxZoom;

        // Scale cell size with zoom level - larger cells when zoomed out
        final double baseCellSize = 60.0;
        final double zoomFactor = math.max(1.0, (18.0 - zoomLevelInt));
        final double scaledCellSize = baseCellSize * zoomFactor;
        if (kDebugMode) {
          debugPrint('Zoom level: $currentZoom, Zoom factor: $zoomFactor, Cell size: $scaledCellSize');
        }

        final clusteredLocations = enableClustering
            ? clusterItems<ShopLocation>(
                state.locations,
                zoom: zoomLevelInt,
                cellSizePx: scaledCellSize,
                toLatLng: (loc) => loc.latLng,
              )
            : state.locations
                .map(
                  (loc) => GridCluster<ShopLocation>(
                    center: loc.latLng,
                    items: [loc],
                  ),
                )
                .toList();

        final markers = <Marker>[];

        for (final cluster in clusteredLocations) {
          final hasSelected = cluster.items.any(
            (loc) => loc.shopLocationId == state.selectedShopLocationId,
          );
          if (hasSelected) continue;

          if (cluster.isCluster) {
            final clusterMarkerSize = cluster.items.length > 10 ? 50.0 : 40.0;
            final fontSize = cluster.items.length > 10 ? 24.0 : 20.0;
            
            markers.add(
              Marker(
                height: clusterMarkerSize,
                width: clusterMarkerSize,
                point: cluster.center,
                child: GestureDetector(
                  onTap: () {
                    const double minDetailZoom = 16;
                    final double zoomAfterTap = (currentZoom + 2).clamp(5.0, 20.0);
                    final double targetZoom =
                        zoomAfterTap < minDetailZoom ? minDetailZoom : zoomAfterTap;
                    _mapController?.animateTo(
                      dest: cluster.center,
                      zoom: targetZoom
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.notificationDot,
                      shape: BoxShape.circle,
                      border: const Border.fromBorderSide(
                        BorderSide(
                          color: AppColors.textPrimary,
                          width: 2,
                        ),
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.textPrimary,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${cluster.items.length}',
                      style: TextStyle(
                        fontFamily: 'Itim',
                        fontSize: fontSize,
                        color: AppColors.surface,
                      ),
                    ),
                  ),
                ),
              ),
            );
          } else {
            final location = cluster.items.first;
            final borderWidth = 1.2;

            markers.add(
              Marker(
                height: 53,
                width: 253,
                point: location.latLng,
                child: Transform.translate(
                  offset: const Offset(108, -19),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    spacing: 4,
                    children: [
                      GestureDetector(
                        onTap: () {
                          _mapController!.animateTo(
                            dest: location.latLng,
                            zoom:
                                _mapController!.mapController.camera.zoom,
                          );
                          context.read<CouponMapBloc>().add(
                            CouponMapLocationSelected(
                              shopLocationId: location.shopLocationId,
                              shopId: location.shopId,
                              shopName: location.shopName,
                            ),
                          );
                        },
                        child: ShopLocationPin(
                          active: state.selectedShopLocationId == null,
                        ),
                      ),
                      if (state.selectedShopLocationId == null)
                        SizedBox(
                          width: 200,
                          child: Stack(
                            children: [
                              Text(
                                location.shopName ?? '',
                                style: TextStyle(
                                  height: 0.8,
                                  fontFamily: 'Itim',
                                  fontSize: 18,
                                  color: AppColors.textPrimary,
                                  shadows: [
                                    Shadow(
                                      offset:
                                          Offset(-borderWidth, -borderWidth),
                                      color: AppColors.surface,
                                    ),
                                    Shadow(
                                      offset:
                                          Offset(borderWidth, -borderWidth),
                                      color: AppColors.surface,
                                    ),
                                    Shadow(
                                      offset:
                                          Offset(borderWidth, borderWidth),
                                      color: AppColors.surface,
                                    ),
                                    Shadow(
                                      offset:
                                          Offset(-borderWidth, borderWidth),
                                      color: AppColors.surface,
                                    ),
                                    Shadow(
                                      offset: Offset(-borderWidth, 0),
                                      color: AppColors.surface,
                                    ),
                                    Shadow(
                                      offset: Offset(borderWidth, 0),
                                      color: AppColors.surface,
                                    ),
                                    Shadow(
                                      offset: Offset(0, -borderWidth),
                                      color: AppColors.surface,
                                    ),
                                    Shadow(
                                      offset: Offset(0, borderWidth),
                                      color: AppColors.surface,
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
            );
          }
        }

        final selectedMarker = state.locations
            .where(
              (location) =>
                  state.selectedShopLocationId == location.shopLocationId,
            )
            .map((location) {
          
          final borderWidth = 1.2;
          return Marker(
            height: 53,
            width: 253,
            point: location.latLng,
            child: Transform.translate(
              offset: const Offset(108, -19),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: 4,
                children: [
                  ShopLocationPin(
                    active: true,
                    selected: true,
                  ), 
                  SizedBox(
                    width: 200,
                    child: Stack(
                      children: [
                        Text(
                          location.shopName ?? '',
                          style: TextStyle(
                            height: 0.8,
                            fontFamily: 'Itim',
                            fontSize: 18,
                            color: AppColors.textPrimary,
                            shadows: [
                              Shadow(
                                offset: Offset(-borderWidth, -borderWidth),
                                color: AppColors.surface
                              ),
                              Shadow(
                                offset: Offset(borderWidth, -borderWidth),
                                color: AppColors.surface
                              ),
                              Shadow(
                                offset: Offset(borderWidth, borderWidth),
                                color: AppColors.surface
                              ),
                              Shadow(
                                offset: Offset(-borderWidth, borderWidth),
                                color: AppColors.surface
                              ),
                              Shadow(
                                offset: Offset(-borderWidth, 0),
                                color: AppColors.surface
                              ),
                              Shadow(
                                offset: Offset(borderWidth, 0),
                                color: AppColors.surface
                              ),
                              Shadow(
                                offset: Offset(0, -borderWidth),
                                color: AppColors.surface
                              ),
                              Shadow(
                                offset: Offset(0, borderWidth),
                                color: AppColors.surface
                              ),
                            ]
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList();

        final tileStyle = 'klokantech-basic';
        return Scaffold(
          body: Stack(
            children: [
              FlutterMap(
                mapController: _mapController!.mapController,
                options: MapOptions(
                  initialCenter: const LatLng(52.23, 19.09),
                  initialZoom: 5.9,
                  maxZoom: 20.0,
                  onMapReady: () {
                    initializeMap();
                    _updateZoomTip();
                  },
                  onPositionChanged: (position, hasGesture) {
                    _onMapMove();
                    if (hasGesture) {
                      _updateZoomTip();
                    }
                  },
                  interactionOptions: const InteractionOptions(
                    flags:
                        InteractiveFlag.pinchZoom |
                        InteractiveFlag.drag |
                        InteractiveFlag.pinchMove |
                        InteractiveFlag.doubleTapZoom |
                        InteractiveFlag.scrollWheelZoom,
                  ),
                ),
                children: [
                  BlocBuilder<MapCacheBloc, MapCacheState>(
                    builder: (context, state) {
                      if (state is MapCacheInitialisedSuccess ||
                          state is MapCacheGetStatusSuccess ||
                          state is MapCacheGetStatusInProgress) {
                        return TileLayer(
                          urlTemplate:
                              'https://maps.geoapify.com/v1/tile/$tileStyle/{z}/{x}/{y}.png?&apiKey=$apiKey',
                          userAgentPackageName: 'com.coupidyn.proj_inz',
                          maxZoom: 19,
                          panBuffer: 1,
                          tileProvider: CachedTileProvider(
                            store:
                                context
                                    .read<MapCacheBloc>()
                                    .mapCacheRepository
                                    .cacheStore,
                            maxStale: const Duration(days: 30),
                          ),
                        );
                      } else {
                        return TileLayer(
                          urlTemplate:
                              'https://maps.geoapify.com/v1/tile/$tileStyle/{z}/{x}/{y}.png?&apiKey=$apiKey',
                          userAgentPackageName: 'com.coupidyn.proj_inz',
                          maxZoom: 19,
                          panBuffer: 1,
                        );
                      }
                    },
                  ),
                  
                  if (_currentUserLocation != null)
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _currentUserLocation!,
                          child: LocationDot(),
                        ),
                      ],
                    ),
                  MarkerLayer(markers: markers),
                  if (state.selectedShopLocationId != null)
                  Positioned.fill(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                      child: Container(
                        color: Colors.black.withValues(
                          alpha: 0.3,
                        ),
                      ),
                    ),
                  ),
                  MarkerLayer(markers: selectedMarker),
                  _AttributionWidget(),
                ],
              ),
              // top buttons
              if (state.selectedShopLocationId == null)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 48.0, horizontal: 24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CustomIconButton(
                        icon: SvgPicture.asset('assets/icons/back.svg'),
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                      ),
                        HelpButton(
                          title: "Mapa",
                          body: Text(
                            "Na tej mapie możesz znaleźć sklepy z dostępnymi kuponami. \n\n• Użyj przycisku lokalizacji, aby pokazać swoją aktualną pozycję na mapie. \n\n• Przybliż mapę, aby móc wyszukać sklepy w danym obszarze. \n\n• Kliknij na znacznik sklepu, aby zobaczyć dostępne kupony w tym sklepie.",
                            style: const TextStyle(
                              fontFamily: 'Itim',
                              fontSize: 16,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              // bottom navigation bar
              if (state.selectedShopLocationId == null)
              Positioned(
                bottom: 20,
                left: 8,
                right: 8,
                child: Container(
                  height: 74,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.textPrimary, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.textPrimary,
                        offset: const Offset(4, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    spacing: 16,
                    children: [
                      Flexible(
                        child: Container(
                          alignment: Alignment.center,
                          child: state.showZoomTip
                              ? const Text(
                                'Przybliż mapę, aby móc wyszukać sklepy z dostępnymi kuponami.',
                                style: TextStyle(
                                  fontFamily: 'Itim',
                                  fontSize: 16,
                                  color: AppColors.textPrimary,
                                ),
                              )
                              : state.showSearchButton
                              ? CustomTextButton.small(
                                label: "Szukaj w tym obszarze",
                                icon:
                                    state.status == CouponMapStatus.loading
                                        ? const CircularProgressIndicator(
                                          color: AppColors.textPrimary,
                                          strokeWidth: 4.0,
                                        )
                                        : Icon(Icons.radar),
                                onTap:
                                    state.status == CouponMapStatus.loading
                                        ? () {}
                                        : searchInCurrentView,
                              )
                              : Text(
                                markers.isEmpty
                                    ? 'Nie znaleźliśmy sklepów z dostępnymi kuponów w tym obszarze.'
                                    : markers.length == 1
                                    ? 'W tym obszarze znaleźliśmy 1 sklep z dostępnymi kuponami.'
                                    : markers.length <= 4
                                    ? 'W tym obszarze znaleźliśmy ${markers.length} sklepy z dostępnymi kuponami.'
                                    : 'W tym obszarze znaleźliśmy ${markers.length} sklepów z dostępnymi kuponami.',
                                style: TextStyle(
                                  fontFamily: 'Itim',
                                  fontSize: 16,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                        ),
                      ),
                      CustomIconButton(
                        icon:
                            _isUserLocationLoading
                                ? const CircularProgressIndicator(
                                  color: AppColors.textPrimary,
                                  padding: EdgeInsets.all(12.0),
                                  strokeWidth: 2.0,
                                )
                                : _isUserLocationEnabled
                                ? Icon(Icons.my_location)
                                : Icon(Icons.location_searching),
                        onTap: _locationButtonPressed,
                      ),
                    ],
                  ),
                ),
              ),
              if (_isMapLoading)
                const Center(child: CircularProgressIndicator()),
              // selected location coupon list
              if (state.selectedShopLocationId != null)
                Positioned.fill(
                  // click-outside detector
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () =>
                      context
                          .read<CouponMapBloc>()
                          .add(const CouponMapLocationCleared()),
                    onHorizontalDragStart: (details) =>
                      context
                          .read<CouponMapBloc>()
                          .add(const CouponMapLocationCleared()),
                    onVerticalDragStart: (details) => 
                      context
                          .read<CouponMapBloc>()
                          .add(const CouponMapLocationCleared())
                  ),
                ),
              // top buttons if shop location selected
              if (state.selectedShopLocationId != null)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 48.0, horizontal: 24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CustomIconButton(
                        icon: SvgPicture.asset('assets/icons/back.svg'),
                        onTap: () {
                          context
                          .read<CouponMapBloc>()
                          .add(const CouponMapLocationCleared());
                        },
                      ),
                      
                    ],
                  ),
                ),
              ),
              // selected location coupon list
              if (state.selectedShopLocationId != null)
              Positioned(
                  bottom: 20,
                  left: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: AppColors.textPrimary,
                        width: 2,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.textPrimary,
                          offset: Offset(4, 4),
                        ),
                      ],
                    ),
                    child:
                        state.status == CouponMapStatus.loading
                            ? Center(child: CircularProgressIndicator())
                            : state.selectedShopLocationCoupons.isEmpty
                            ? const Text(
                              'Brak dostępnych kuponów w tym sklepie.',
                              style: TextStyle(
                                fontFamily: 'Itim',
                                fontSize: 16,
                                color: AppColors.textPrimary,
                              ),
                              textAlign: TextAlign.center,
                            )
                            : Column(
                              spacing: 16,
                              children: [
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 4.0),
                                    child: Row(
                                      spacing: 10,
                                      children: [
                                        const SizedBox(width: 8),
                                        ...state.selectedShopLocationCoupons
                                            .map(
                                              (coupon) => CouponCardVertical(
                                                coupon: coupon,
                                              ),
                                            ),
                                        const SizedBox(width: 8),
                                      ],
                                    ),
                                  ),
                                ),
                                CustomTextButton(
                                  label: 'Pokaż więcej',
                                  onTap:
                                      () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (_) => BlocProvider(
                                                  create:
                                                      (context) => CouponListBloc(
                                                        context.read<CouponRepository>(),
                                                      )..add(FetchCoupons(userId: FirebaseAuth.instance.currentUser!.uid, shopId: state.selectedShopId)),
                                                  child: CouponListScreen(
                                                    selectedShopId: state.selectedShopId,
                                                    searchShopName: state.selectedShopName,
                                                  ),
                                                ),
                                          ),
                                        );
                                      },
                                ),
                              ],
                            ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _AttributionWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) => SafeArea(
    child: Align(
      alignment: Alignment.bottomRight,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(4),
        ),
        child: GestureDetector(
          onTap:
              () => launchUrl(Uri.parse('https://openstreetmap.org/copyright')),
          child: Padding(
            padding: const EdgeInsets.all(1),
            child: const Text(
              'Dane mapy © OpenstreetMap',
              style: TextStyle(fontSize: 12),
            ),
          ),
        ),
      ),
    ),
  );
}
