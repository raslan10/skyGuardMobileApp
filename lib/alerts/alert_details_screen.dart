import 'package:flutter/material.dart';
import 'package:skyguardmobileapp/models/alert_model.dart';
import 'package:skyguardmobileapp/MapScreen/mapsScreen.dart';

class AlertDetailsScreen extends StatelessWidget {
  final AlertModel alert;

  const AlertDetailsScreen({
    super.key,
    required this.alert,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Alert Details"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _infoCard("ID", alert.id.toString()),
            _infoCard("Type", alert.type),
            _infoCard("Severity", alert.severity),
            _infoCard("Latitude", alert.lat.toString()),
            _infoCard("Longitude", alert.lng.toString()),
            _infoCard("Timestamp", alert.timestamp),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MapsScreen(
                        lat: alert.lat,
                        lng: alert.lng,
                        type: alert.type,
                        severity: alert.severity,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.map),
                label: const Text("Open on Map"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoCard(String title, String value) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(title),
        subtitle: Text(value),
      ),
    );
  }
}