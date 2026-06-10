import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapsScreen extends StatelessWidget {
  static const String routeName = '/map';

  final double lat;
  final double lng;
  final String? type;
  final String? severity;

  const MapsScreen({
    super.key,
    this.lat = 30.0444,
    this.lng = 31.2357,
    this.type,
    this.severity,
  });

  @override
  Widget build(BuildContext context) {
    final position = LatLng(lat, lng);

    return Scaffold(
      appBar: AppBar(
        title: Text(type == null ? "Map" : "$type Location"),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: position,
          zoom: 15,
        ),
        markers: {
          Marker(
            markerId: const MarkerId("alert_location"),
            position: position,
            infoWindow: InfoWindow(
              title: type ?? "Alert Location",
              snippet: severity == null ? null : "Severity: $severity",
            ),
          ),
        },
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        zoomControlsEnabled: false,
      ),
    );
  }
}