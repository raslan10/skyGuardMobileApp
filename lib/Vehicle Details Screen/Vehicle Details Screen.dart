import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skyguardmobileapp/MapScreen/appbar.dart';
import 'package:skyguardmobileapp/core-api/errors/error_handler.dart';
import 'package:skyguardmobileapp/core-api/network/api_client.dart';
import 'package:skyguardmobileapp/core-api/network/api_constants.dart';
import 'package:skyguardmobileapp/core/widgets/app_snackbar.dart';

class VehicleDetailsScreen extends StatefulWidget {
  final int vehicleId;

  const VehicleDetailsScreen({
    super.key,
    required this.vehicleId,
  });

  @override
  State<VehicleDetailsScreen> createState() =>
      _VehicleDetailsScreenState();
}

class _VehicleDetailsScreenState
    extends State<VehicleDetailsScreen> {
  final Dio _dio = ApiClient().dio;

  bool isLoading = true;

  Map<String, dynamic>? vehicleData;

  @override
  void initState() {
    super.initState();

    fetchVehicleDetails();
  }

  Future<void> fetchVehicleDetails() async {
    try {
      final response = await _dio.get(
        ApiConstants.vehicleDetails(widget.vehicleId),
      );

      if (!mounted) return;

      final data = response.data;

      setState(() {
        vehicleData = Map<String, dynamic>.from(
          data['vehicle'],
        );

        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      AppSnackbar.error(
        context,
        ErrorHandler.handle(e),
      );
    }
  }

  Widget sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 14,
      ),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget buildInfoCard({
    required String title,
    required String value,
    required IconData icon,
    Color valueColor = Colors.black,
  }) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color:
            Colors.black.withOpacity(
              0.04,
            ),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding:
            const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(
                0xFF007BA7,
              ).withOpacity(0.1),
              borderRadius:
              BorderRadius.circular(
                12,
              ),
            ),
            child: const Icon(
              Icons.info,
              color: Color(0xFF007BA7),
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style:
                  GoogleFonts.poppins(
                    color: Colors.grey,
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  value,
                  style:
                  GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight:
                    FontWeight.w600,
                    color: valueColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lastLocation =
    vehicleData?['lastLocation']
    as Map<String, dynamic>?;

    final lastAlert =
    vehicleData?['lastAlert']
    as Map<String, dynamic>?;

    final status =
        vehicleData?['status']
            ?.toString()
            .toLowerCase() ??
            '';

    final isActive =
        status == 'active';

    return Scaffold(
      appBar: const WaveAppBar(),
      backgroundColor:
      Colors.grey.shade100,
      body: isLoading
          ? const Center(
        child:
        CircularProgressIndicator(),
      )
          : vehicleData == null
          ? Center(
        child: Text(
          "Failed to load vehicle details",
          style:
          GoogleFonts.poppins(),
        ),
      )
          : SingleChildScrollView(
        padding:
        const EdgeInsets.all(
          16,
        ),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment
              .start,
          children: [
            Container(
              width:
              double.infinity,
              padding:
              const EdgeInsets.all(
                22,
              ),
              decoration:
              BoxDecoration(
                color: Colors.white,
                borderRadius:
                BorderRadius.circular(
                  22,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors
                        .black
                        .withOpacity(
                      0.05,
                    ),
                    blurRadius:
                    14,
                    offset:
                    const Offset(
                      0,
                      5,
                    ),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding:
                    const EdgeInsets.all(
                      18,
                    ),
                    decoration:
                    BoxDecoration(
                      color:
                      const Color(
                        0xFF007BA7,
                      ).withOpacity(
                        0.1,
                      ),
                      shape:
                      BoxShape.circle,
                    ),
                    child:
                    const Icon(
                      Icons
                          .directions_car,
                      size: 42,
                      color:
                      Color(
                        0xFF007BA7,
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  Text(
                    vehicleData?['name']
                        ?.toString() ??
                        '',
                    textAlign:
                    TextAlign
                        .center,
                    style:
                    GoogleFonts.poppins(
                      fontSize:
                      24,
                      fontWeight:
                      FontWeight
                          .w700,
                    ),
                  ),

                  const SizedBox(
                    height: 14,
                  ),

                  Container(
                    padding:
                    const EdgeInsets.symmetric(
                      horizontal:
                      14,
                      vertical:
                      8,
                    ),
                    decoration:
                    BoxDecoration(
                      color: isActive
                          ? Colors
                          .green
                          .withOpacity(
                          0.12)
                          : Colors
                          .red
                          .withOpacity(
                          0.12),
                      borderRadius:
                      BorderRadius.circular(
                        20,
                      ),
                    ),
                    child: Text(
                      status
                          .toUpperCase(),
                      style:
                      GoogleFonts.poppins(
                        color: isActive
                            ? Colors
                            .green
                            : Colors
                            .red,
                        fontWeight:
                        FontWeight
                            .w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: 24,
            ),

            sectionTitle(
              "Vehicle Information",
            ),

            buildInfoCard(
              title:
              "Plate Number",
              value: vehicleData?[
              'plateNumber']
                  ?.toString() ??
                  '—',
              icon: Icons
                  .confirmation_number,
            ),

            buildInfoCard(
              title: "Device ID",
              value: vehicleData?[
              'deviceId']
                  ?.toString() ??
                  '—',
              icon: Icons.memory,
            ),

            const SizedBox(
              height: 14,
            ),

            sectionTitle(
              "Last Location",
            ),

            buildInfoCard(
              title: "Latitude",
              value: lastLocation?[
              'lat']
                  ?.toString() ??
                  '—',
              icon:
              Icons.location_on,
            ),

            buildInfoCard(
              title:
              "Longitude",
              value: lastLocation?[
              'lng']
                  ?.toString() ??
                  '—',
              icon: Icons.map,
            ),

            const SizedBox(
              height: 14,
            ),

            sectionTitle(
              "Last Alert",
            ),

            buildInfoCard(
              title: "Type",
              value: lastAlert?[
              'type']
                  ?.toString() ??
                  '—',
              icon:
              Icons.warning,
            ),

            buildInfoCard(
              title:
              "Severity",
              value: lastAlert?[
              'severity']
                  ?.toString() ??
                  '—',
              icon: Icons
                  .priority_high,
            ),

            buildInfoCard(
              title:
              "Timestamp",
              value: lastAlert?[
              'timestamp']
                  ?.toString() ??
                  '—',
              icon: Icons
                  .access_time,
            ),

            const SizedBox(
              height: 24,
            ),

            SizedBox(
              width:
              double.infinity,
              child:
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(
                    context,
                  );
                },
                icon: const Icon(
                  Icons
                      .arrow_back,
                  color:
                  Colors.white,
                ),
                label: Text(
                  "Back to Vehicles",
                  style:
                  GoogleFonts.poppins(
                    color:
                    Colors.white,
                    fontWeight:
                    FontWeight
                        .w600,
                  ),
                ),
                style:
                ElevatedButton.styleFrom(
                  backgroundColor:
                  const Color(
                    0xFF007BA7,
                  ),
                  padding:
                  const EdgeInsets.symmetric(
                    vertical:
                    16,
                  ),
                  shape:
                  RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(
                      16,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}