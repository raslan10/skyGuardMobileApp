import 'package:flutter/material.dart';

class TripDetailsScreen extends StatelessWidget {
  const TripDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Trip Details")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _infoCard("Start time", "—"),
            _infoCard("End time", "—"),
            _infoCard("Distance", "— km"),
            _infoCard("Avg speed", "— km/h"),
            _infoCard("Max speed", "— km/h"),
            _infoCard("Harsh brakes", "—"),
            _infoCard("Safety score", "—"),
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