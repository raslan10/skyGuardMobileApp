import 'package:flutter/material.dart';

import '../models/emergency_report.dart';
import '../services/emergency_reports_service.dart';

class EmergencyReportsScreen extends StatefulWidget {
  const EmergencyReportsScreen({super.key});

  @override
  State<EmergencyReportsScreen> createState() =>
      _EmergencyReportsScreenState();
}

class _EmergencyReportsScreenState
    extends State<EmergencyReportsScreen> {
  final EmergencyReportsService _service =
  EmergencyReportsService();

  List<EmergencyReport> reports = [];

  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    loadReports();
  }

  Future<void> loadReports() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      final data = await _service.getReports();

      setState(() {
        reports = data.reversed.toList();
      });
    } catch (e) {
      setState(() {
        error = e.toString();
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  String formatDate(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}  '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Reports'),
      ),
      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : error != null
          ? Center(
        child: Text(error!),
      )
          : reports.isEmpty
          ? const Center(
        child: Text(
          'No emergency reports yet',
        ),
      )
          : RefreshIndicator(
        onRefresh: loadReports,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: reports.length,
          itemBuilder: (context, index) {
            final report = reports[index];

            return Card(
              margin:
              const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.red,
                  child: Icon(
                    Icons.warning,
                    color: Colors.white,
                  ),
                ),
                title: Text(report.triggerType),
                subtitle: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 6),
                    Text(
                      'Time: ${formatDate(report.timestamp)}',
                    ),
                    Text(
                      'Status: ${report.status}',
                    ),
                    Text(
                      'Note: ${report.note}',
                    ),
                    Text(
                      'Location: ${report.latitude ?? 'N/A'}, ${report.longitude ?? 'N/A'}',
                    ),
                  ],
                ),
                isThreeLine: true,
              ),
            );
          },
        ),
      ),
    );
  }
}