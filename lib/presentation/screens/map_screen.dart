import 'dart:async';
import 'package:flutter/material.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/svg.dart';
import 'package:proj_inz/presentation/widgets/coupon_map/shop_location.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:app_settings/app_settings.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proj_inz/bloc/coupon_map/coupon_map_bloc.dart';
import 'package:proj_inz/data/repositories/map_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:proj_inz/presentation/widgets/custom_snack_bar.dart';
import 'package:proj_inz/presentation/widgets/input/buttons/custom_icon_button.dart';
import 'package:proj_inz/presentation/widgets/input/buttons/custom_text_button.dart';
import 'package:proj_inz/presentation/widgets/coupon_map/location_dot.dart';



class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with WidgetsBindingObserver {
  bool _isLoading = true;
  MapController? _mapController;
  bool _isLocationEnabled = false;
  bool _isLocationLoading = false;
  LatLng? _currentPosition;
  bool _waitingForLocationSettings = false;
  Timer? _locationUpdateTimer;
  bool _showSearchButton = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    WidgetsBinding.instance.addObserver(this);
    _loadMapState();
  }

  Future<void> _loadMapState() async {
    final prefs = await SharedPreferences.getInstance();
    final zoomLevel = prefs.getDouble('map_zoom_level') ?? 5.9;
    final latitude = prefs.getDouble('map_latitude') ?? 52.23;
    final longitude = prefs.getDouble('map_longitude') ?? 19.09;

    if (mounted) {
      setState(() {
        _mapController?.move(LatLng(latitude, longitude), zoomLevel);
      });
    }
  }

  Future<void> _saveMapState() async {
    if (_mapController != null) {
      final prefs = await SharedPreferences.getInstance();
      final center = _mapController!.camera.center;
      final zoom = _mapController!.camera.zoom;

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
    _locationUpdateTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _waitingForLocationSettings) {
      _waitingForLocationSettings = false;
      // Retry getting location when app resumes
      _locationButtonPressed();
    }
  }

  void _startLocationUpdates() {
    _locationUpdateTimer?.cancel();
    _locationUpdateTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_isLocationEnabled && !_isLocationLoading) {
        _updateLocation();
      }
    });
  }

  void _stopLocationUpdates() {
    _locationUpdateTimer?.cancel();
  }

  Future<void> _updateLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition();
      final newPosition = LatLng(position.latitude, position.longitude);
      debugPrint(newPosition.toString());

      if (mounted) {
        setState(() {
          _currentPosition = newPosition;
        });
      }
    } catch (e) {
      debugPrint('Error updating location: $e');
      if (mounted) {
        setState(() {
          _isLocationEnabled = false;
          _currentPosition = null;
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
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: const BorderSide(width: 2, color: Colors.black),
            ),
            title: const Text(
              'Dostęp do lokalizacji',
              style: TextStyle(
                fontFamily: 'Itim',
                fontSize: 22,
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
            ),
            content: const Text(
              'Potrzebujemy dostępu do lokalizacji, aby pokazać Twoją aktualną pozycję na mapie.',
              style: TextStyle(
                fontFamily: 'Itim',
                fontSize: 16,
                color: Color(0xFF646464),
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
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: const BorderSide(width: 2, color: Colors.black),
            ),
            title: const Text(
              'Odmówiono dostępu do lokalizacji',
              style: TextStyle(
                fontFamily: 'Itim',
                fontSize: 22,
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
            ),
            content: const Text(
              'Czy chcesz przejść do ustawień aplikacji aby to zmienić?',
              style: TextStyle(
                fontFamily: 'Itim',
                fontSize: 16,
                color: Color(0xFF646464),
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
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: const BorderSide(width: 2, color: Colors.black),
            ),
            title: const Text(
              'Porada',
              style: TextStyle(
                fontFamily: 'Itim',
                fontSize: 22,
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
            ),
            content: const Text(
              'Wejdź w sekcję "Uprawnienia", a następnie "Lokalizacja".',
              style: TextStyle(
                fontFamily: 'Itim',
                fontSize: 16,
                color: Color(0xFF646464),
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
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: const BorderSide(width: 2, color: Colors.black),
            ),
            title: const Text(
              'Czy chcesz włączyć usługi lokalizacyjne?',
              style: TextStyle(
                fontFamily: 'Itim',
                fontSize: 22,
                fontWeight: FontWeight.w400,
                color: Colors.black,
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
        _waitingForLocationSettings = true;
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
          showCustomSnackBar(
            context,
            'Usługi lokalizacji są wyłączone.',
          );
        }
        return Future.error('Location service disabled.');
      }
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<void> _locationButtonPressed() async {
    if (_isLocationEnabled) {
      setState(() {
        _currentPosition = null;
        _isLocationEnabled = false;
      });
      _stopLocationUpdates();
      return;
    }

    try {
      setState(() {
        _isLocationLoading = true;
      });
      final position = await _getPosition();
      final newPosition = LatLng(position.latitude, position.longitude);

      setState(() {
        _currentPosition = newPosition;
        _isLocationEnabled = true;
      });

      _mapController?.move(newPosition, 16.0);
      _startLocationUpdates();
    } catch (e) {
      debugPrint('Error getting location: $e');
    } finally {
      setState(() {
        _isLocationLoading = false;
      });
    }
  }

  void _onMapMove() {
    setState(() {
      _showSearchButton = true;
    });
  }

  

  @override
  Widget build(BuildContext context) {
    final apiKey = dotenv.env['GEOAPIFY_API_KEY'] ?? '';

    return BlocProvider(
      create: (context) => CouponMapBloc(mapRepository: MapRepository())..add(LoadLocations()),
      child: BlocBuilder<CouponMapBloc, CouponMapState>(
        builder: (context, state) {

          void searchInCurrentView() {
            if (_mapController != null) {
              final zoomLevel = _mapController!.camera.zoom;
              if (zoomLevel < 11) {
                showCustomSnackBar(
                  context,
                  'Przybliż mapę, aby wyszukać.',
                );
                return;
              }
              final bounds = _mapController?.camera.visibleBounds;
              if (bounds != null) {
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
              _showSearchButton = false;
            });
          }


          List<Marker> markers = [];

          if (state is CouponMapLoaded) {
            markers = state.locations.map((location) {
              return Marker(
                point: LatLng(location.latitude, location.longitude),
                child: ShopLocation(),
              );
            }).toList();
          }

          return Scaffold(
            body: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: const LatLng(52.23, 19.09),
                    initialZoom: 5.9,
                    maxZoom: 20.0,
                    onMapReady: () {
                      setState(() {
                        _isLoading = false;
                      });
                    },
                    onPositionChanged: (position, hasGesture) {
                      if (hasGesture) {
                        _onMapMove();
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
                    TileLayer(
                      urlTemplate:
                          'https://maps.geoapify.com/v1/tile/carto/{z}/{x}/{y}.png?&apiKey=$apiKey',
                      userAgentPackageName: 'com.coupidyn.proj_inz',
                      maxZoom: 20,
                      panBuffer: 1,
                    ),
                    if (_currentPosition != null)
                      MarkerLayer(
                        markers: [
                          Marker(point: _currentPosition!, child: LocationDot()),
                        ],
                      ),
                    MarkerLayer(markers: markers),
                    _AttributionWidget()
                  ],
                ),
                Positioned(
                  left: 24,
                  top: 16,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 24.0),
                    child: CustomIconButton(
                      icon: SvgPicture.asset('assets/icons/back.svg'),
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ),
                Positioned(
                  right: 24,
                  bottom: 64,
                  child: CustomIconButton(
                    icon:
                        _isLocationLoading
                            ? const CircularProgressIndicator(
                          color: Colors.black,
                          padding: EdgeInsets.all(12.0),
                          strokeWidth: 2.0,
                        )
                            : _isLocationEnabled
                            ? Icon(Icons.my_location)
                            : Icon(Icons.location_searching),
                    onTap: _locationButtonPressed,
                  ),
                ),
                if (_showSearchButton)
                  Positioned(
                    bottom: 16,
                    right: 16,
                    child: CustomTextButton.small(
                      label: 'Szukaj w tym obszarze',
                      onTap: searchInCurrentView,
                    ),
                  ),
                if (_isLoading) const Center(child: CircularProgressIndicator()),
              ],
            ),
          );
        },
      ),
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
          color: Colors.white.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(4),
        ),
        child: GestureDetector(
          onTap:
              () => launchUrl(Uri.parse('https://openstreetmap.org/copyright')),
          child: Padding(
            padding: const EdgeInsets.all(3),
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