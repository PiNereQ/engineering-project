import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';


class DebugScreen extends StatefulWidget {
  const DebugScreen({super.key});

  @override
  State<DebugScreen> createState() => _DebugScreenState();
}

class _DebugScreenState extends State<DebugScreen> {
  bool _isLoading = true;

  @override
  Widget build(BuildContext context) {
    final apiKey = dotenv.env['GEOAPIFY_API_KEY'] ?? '';
    
    return Scaffold(
      appBar: AppBar(title: const Text('Debug'),),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: const LatLng(52.069328, 19.480216), // środek Polski
              initialZoom: 6.0,
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
              RichAttributionWidget(
                showFlutterMapAttribution: false,
                attributions: [
                  TextSourceAttribution(
                    'OpenStreetMap contributors',
                    onTap:
                        () => launchUrl(
                          Uri.parse('https://openstreetmap.org/copyright'),
                        ),
                  ),
                  TextSourceAttribution(
                    'Geoapify',
                    onTap:
                        () => launchUrl(
                          Uri.parse('https://www.geoapify.com/terms-of-use'),
                        ),
                  )
                ],
              ),
            ],
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