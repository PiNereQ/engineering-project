import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:proj_inz/presentation/widgets/custom_snack_bar.dart';
import 'package:proj_inz/presentation/widgets/input/buttons/custom_icon_button.dart';
import 'package:proj_inz/presentation/widgets/location_dot.dart';
import 'package:url_launcher/url_launcher.dart';


class DebugScreen extends StatefulWidget {
  const DebugScreen({super.key});

  @override
  State<DebugScreen> createState() => _DebugScreenState();
}

class _DebugScreenState extends State<DebugScreen> {
  bool _isLoading = true;
  MapController? _mapController;
  Key _mapKey = UniqueKey();
  bool _isLocationEnabled = false;
  LatLng? _currentPosition;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  void _reloadMap() {
    setState(() {
      _isLoading = true;
      _mapKey = UniqueKey();
      _mapController = MapController();
    });
  }

  @override
  Widget build(BuildContext context) {
    final apiKey = dotenv.env['GEOAPIFY_API_KEY'] ?? '';

    Future<Position> _getPosition() async {
      bool serviceEnabled;
      LocationPermission permission;

      permission = await Geolocator.checkPermission(); 
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return Future.error('Nie przyznano pozwolenia na lokalizację.');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return Future.error(
            'Pozwolenie na lokalizację zostało trwale odrzucone, nie można go zażądać ponownie.');
      }

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return Future.error('Usługi lokalizacyjne są wyłączone.');
      }

      return await Geolocator.getCurrentPosition();
    }

    Future<void> locationButtonPressed() async {
      if (_isLocationEnabled) {
        setState(() {
          _currentPosition = null;
          _isLocationEnabled = false;
        });
        return;
      }
      try {
        final position = await _getPosition();
        final newPosition = LatLng(position.latitude, position.longitude);
        
        setState(() {
          _currentPosition = newPosition;
          _isLocationEnabled = true;
        });

        _mapController?.move(newPosition, 15.0);
      } catch (e) {
        debugPrint('Error getting location: $e');
        showCustomSnackBar(context, '$e');
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _reloadMap,
            tooltip: 'Reload Map',
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            key: _mapKey,
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
                flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://maps.geoapify.com/v1/tile/carto/{z}/{x}/{y}.png?&apiKey=$apiKey',
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
              SimpleAttributionWidget(
                source: Text('Dane mapy z OpenStreetMap'),
                onTap:
                    () => launchUrl(
                      Uri.parse('https://openstreetmap.org/copyright'),
                    ),
              ),
            ],
          ),
          Positioned(
            right: 16,
            bottom: 64,
            child: CustomIconButton(
              icon: _isLocationEnabled ? Icon(Icons.my_location) : Icon(Icons.location_searching),
              onTap: locationButtonPressed,
            ),
          ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
    
  }
}