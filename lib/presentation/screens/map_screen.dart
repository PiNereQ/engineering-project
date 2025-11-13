import 'dart:async';
import 'package:flutter/material.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:app_settings/app_settings.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import 'package:proj_inz/presentation/widgets/custom_snack_bar.dart';
import 'package:proj_inz/presentation/widgets/input/buttons/custom_icon_button.dart';
import 'package:proj_inz/presentation/widgets/input/buttons/custom_text_button.dart';
import 'package:proj_inz/presentation/widgets/location_dot.dart';



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

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
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
      locationButtonPressed();
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

  Future<Position> getPosition() async {
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

  Future<void> locationButtonPressed() async {
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
      final position = await getPosition();
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

  @override
  Widget build(BuildContext context) {
    final apiKey = dotenv.env['GEOAPIFY_API_KEY'] ?? '';

    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: const LatLng(52.23, 19.09), // środek Polski
                initialZoom: 5.9,
                onMapReady: () {
                  setState(() {
                    _isLoading = false;
                  });
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
                  maxZoom: 18,
                  panBuffer: 1,
                ),
                if (_currentPosition != null)
                  MarkerLayer(
                    markers: [
                      Marker(point: _currentPosition!, child: LocationDot()),
                    ],
                  ),
                _AttributionWidget()
              ],
            ),
            Positioned(
              left: 24,
              top: 16,
              child: CustomIconButton(
                icon: SvgPicture.asset('assets/icons/back.svg'),
                onTap: () {
                  Navigator.of(context).pop();
                },
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
                onTap: locationButtonPressed,
              ),
            ),
            if (_isLoading) const Center(child: CircularProgressIndicator()),
          ],
        ),
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