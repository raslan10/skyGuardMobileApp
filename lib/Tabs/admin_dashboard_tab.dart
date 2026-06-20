import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminDashboardTab extends StatefulWidget {
  const AdminDashboardTab({super.key});

  @override
  State<AdminDashboardTab> createState() => _AdminDashboardTabState();
}

class _AdminDashboardTabState extends State<AdminDashboardTab> {
  // 📊 داتا مراقبة الأسطول - مخصصة فقط لبيانات القيادة والحوادث العامة بدون أي تدخل في عائلة السائق
  final List<Map<String, dynamic>> fleetDrivers = [
    {
      "name": "Ahmed Ruslan",
      "email": "ahmed@skyguard.com",
      "status": "Active",
      "isCritical": false,
      "car": "Hyundai Elantra (Speed: 19.4 km/h | Fuel: 78%)"
    },
    {
      "name": "Mohamed Mahmoud",
      "email": "mohamed@skyguard.com",
      "status": "🚨 CRITICAL (Accident Detected)",
      "isCritical": true,
      "car": "Toyota Corolla (Speed: 0 km/h | Fuel: 12%)"
    },
    {
      "name": "Captain Mahmoud",
      "email": "mahmoud@skyguard.com",
      "status": "Active",
      "isCritical": false,
      "car": "Kia Cerato (Speed: 65 km/h | Fuel: 50%)"
    }
  ];

  void _addNewDriver() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Register New Fleet Driver", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(decoration: InputDecoration(labelText: "Driver Full Name", labelStyle: GoogleFonts.poppins())),
            const SizedBox(height: 10),
            TextField(decoration: InputDecoration(labelText: "Car Model & Plate Number", labelStyle: GoogleFonts.poppins())),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF007BA7)),
            onPressed: () => Navigator.pop(context),
            child: const Text("Add Driver", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF007BA7),
        onPressed: _addNewDriver,
        icon: const Icon(Icons.person_add_alt_1, color: Colors.white),
        label: Text("Add Driver", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Text(
                "Supervisor Control Panel 🛠️",
                style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF014F6E)),
              ),
              Text(
                "Monitor corporate fleet security, real-time telemetry, and accident dispatch logs.",
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(height: 20),
              _buildFleetOverviewStats(),
              const SizedBox(height: 24),
              Text(
                "Live Fleet Status",
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: fleetDrivers.length,
                  itemBuilder: (context, index) {
                    final driver = fleetDrivers[index];
                    final bool hasIssue = driver['isCritical'];
                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: ExpansionTile(
                        leading: CircleAvatar(
                          backgroundColor: hasIssue ? Colors.red.withOpacity(0.1) : const Color(0xFFE3F2FD),
                          child: Icon(
                            hasIssue ? Icons.warning_amber_rounded : Icons.directions_car,
                            color: hasIssue ? Colors.red : const Color(0xFF007BA7),
                          ),
                        ),
                        title: Text(driver['name'], style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                        subtitle: Text(
                          "Fleet Status: ${driver['status']}",
                          style: GoogleFonts.poppins(
                            color: hasIssue ? Colors.red : Colors.green,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Divider(),
                                _buildDetailRow(Icons.email_outlined, "Driver Email: ", driver['email']),
                                const SizedBox(height: 8),
                                _buildDetailRow(Icons.speed, "Telemetry & Fuel: ", driver['car']),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    OutlinedButton.icon(
                                      style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                                      onPressed: () {},
                                      icon: const Icon(Icons.block, size: 16),
                                      label: const Text("Deactivate Fleet Access"),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFleetOverviewStats() {
    return Row(
      children: [
        Expanded(
          child: _statCard("Total Fleet Drivers", "${fleetDrivers.length}", Colors.blue),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statCard("Active Emergencies", "1", Colors.red),
        ),
      ],
    );
  }

  Widget _statCard(String label, String val, Color col) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: col.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: col.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[700])),
          const SizedBox(height: 4),
          Text(val, style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: col)),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(label, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13)),
        Expanded(child: Text(value, style: GoogleFonts.poppins(color: Colors.grey[700], fontSize: 13))),
      ],
    );
  }
}