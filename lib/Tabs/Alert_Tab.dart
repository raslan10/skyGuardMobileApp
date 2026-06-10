import 'package:flutter/material.dart';
import 'package:skyguardmobileapp/alerts/alert_details_screen.dart';
import 'package:skyguardmobileapp/core-api/errors/error_handler.dart';
import 'package:skyguardmobileapp/models/alert_model.dart';
import 'package:skyguardmobileapp/services/alert_service.dart';

class AlertTab extends StatefulWidget {
  const AlertTab({super.key});

  @override
  State<AlertTab> createState() => _AlertTabState();
}

class _AlertTabState extends State<AlertTab> {
  final AlertService alertService = AlertService();

  bool isLoading = true;
  List<AlertModel> alerts = [];

  @override
  void initState() {
    super.initState();
    fetchAlerts();
  }

  Future<void> fetchAlerts() async {
    setState(() {
      isLoading = true;
    });

    try {
      final result = await alertService.getAlerts();

      if (!mounted) return;

      setState(() {
        alerts = result;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ErrorHandler.handle(e),
          ),
        ),
      );
    } finally {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Alerts"),
        actions: [
          IconButton(
            onPressed: fetchAlerts,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (alerts.isEmpty) {
      return _emptyState();
    }

    return _alertsList(context);
  }

  Widget _emptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_off, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              "No alerts",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 8),
            Text(
              "When an accident is detected, alerts will appear here.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _alertsList(BuildContext context) {
    return ListView.builder(
      itemCount: alerts.length,
      itemBuilder: (context, index) {
        final alert = alerts[index];

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: ListTile(
            leading: const Icon(
              Icons.warning_amber_rounded,
              color: Colors.red,
            ),
            title: Text(alert.type),
            subtitle: Text(
              'Severity: ${alert.severity}\nTime: ${alert.timestamp}',
            ),
            isThreeLine: true,
            trailing: const Icon(Icons.arrow_forward_ios, size: 18),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AlertDetailsScreen(alert: alert),
                ),
              );
            },
          ),
        );
      },
    );
  }
}