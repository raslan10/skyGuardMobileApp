import 'package:flutter/material.dart';
import '../MapScreen/mapsScreen.dart';

class AccidentDetailsScreen extends StatelessWidget {
  const AccidentDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Accident Details"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _infoCard("Severity", "—"),
            _infoCard("Status", "—"),
            _infoCard("Speed at impact", "— km/h"),
            _infoCard("Root cause", "—"),
            _infoCard("Detected at", "—"),

            const SizedBox(height: 24),

            // 🗺️ زر فتح الخريطة
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    MapsScreen.routeName,
                  );
                },
                icon: const Icon(Icons.map),
                label: const Text("View on Map"),
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