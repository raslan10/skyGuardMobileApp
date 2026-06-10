import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skyguardmobileapp/MapScreen/appbar.dart';
import 'package:skyguardmobileapp/Vehicle%20Details%20Screen/Vehicle%20Details%20Screen.dart';
import 'package:skyguardmobileapp/add_vehicle_screen/add_vehicle_screen.dart';
import 'package:skyguardmobileapp/core-api/errors/error_handler.dart';
import 'package:skyguardmobileapp/core/widgets/app_snackbar.dart';
import 'package:skyguardmobileapp/models/vehicle_model.dart';
import 'package:skyguardmobileapp/services/vehicles_service.dart';

class VehiclesScreen extends StatefulWidget {
  static const routeName = '/vehicles';

  const VehiclesScreen({super.key});

  @override
  State<VehiclesScreen> createState() =>
      _VehiclesScreenState();
}

class _VehiclesScreenState
    extends State<VehiclesScreen> {
  final VehiclesService vehiclesService =
  VehiclesService();

  bool isLoading = true;

  List<VehicleModel> vehicles = [];

  @override
  void initState() {
    super.initState();

    fetchVehicles();
  }

  Future<void> fetchVehicles() async {
    setState(() {
      isLoading = true;
    });

    try {
      final result =
      await vehiclesService.getVehicles();

      if (!mounted) return;

      setState(() {
        vehicles = result;
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

  Widget buildVehicleCard(
      VehicleModel vehicle,
      ) {
    const primaryColor = Color(0xFF007BA7);

    return Card(
      elevation: 3,
      margin:
      const EdgeInsets.symmetric(
        vertical: 8,
      ),
      shape: RoundedRectangleBorder(
        borderRadius:
        BorderRadius.circular(18),
      ),
      child: ListTile(
        contentPadding:
        const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        leading: Container(
          padding:
          const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color:
            primaryColor.withOpacity(
              0.1,
            ),
            borderRadius:
            BorderRadius.circular(
              12,
            ),
          ),
          child: const Icon(
            Icons.directions_car,
            color: primaryColor,
            size: 28,
          ),
        ),
        title: Text(
          vehicle.name,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Padding(
          padding:
          const EdgeInsets.only(
            top: 8,
          ),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                "Plate: ${vehicle.plateNumber}",
                style:
                GoogleFonts.poppins(
                  fontSize: 13,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                "Device: ${vehicle.deviceId}",
                style:
                GoogleFonts.poppins(
                  fontSize: 13,
                ),
              ),

              const SizedBox(height: 4),

              Row(
                children: [
                  const Icon(
                    Icons.circle,
                    size: 10,
                    color: Colors.green,
                  ),

                  const SizedBox(width: 6),

                  Text(
                    vehicle.status,
                    style:
                    GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.green,
                      fontWeight:
                      FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 18,
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  VehicleDetailsScreen(
                    vehicleId: vehicle.id,
                  ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor =
    Color(0xFF007BA7);

    return Scaffold(
      appBar: const WaveAppBar(),
      backgroundColor:
      Colors.grey.shade100,
      body: RefreshIndicator(
        onRefresh: fetchVehicles,
        child: isLoading
            ? const Center(
          child:
          CircularProgressIndicator(),
        )
            : vehicles.isEmpty
            ? ListView(
          physics:
          const AlwaysScrollableScrollPhysics(),
          children: [
            const SizedBox(
              height: 180,
            ),

            Icon(
              Icons.directions_car,
              size: 90,
              color:
              Colors.grey[400],
            ),

            const SizedBox(
              height: 20,
            ),

            Center(
              child: Text(
                "No vehicles yet",
                style:
                GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight:
                  FontWeight
                      .w600,
                  color:
                  Colors.grey,
                ),
              ),
            ),

            const SizedBox(
              height: 8,
            ),

            Center(
              child: Text(
                "Tap + to add your first vehicle",
                style:
                GoogleFonts.poppins(
                  color:
                  Colors.grey[
                  600],
                ),
              ),
            ),
          ],
        )
            : ListView.builder(
          physics:
          const AlwaysScrollableScrollPhysics(),
          padding:
          const EdgeInsets.all(
            14,
          ),
          itemCount:
          vehicles.length,
          itemBuilder:
              (context, index) {
            return buildVehicleCard(
              vehicles[index],
            );
          },
        ),
      ),
      floatingActionButton:
      FloatingActionButton(
        backgroundColor:
        primaryColor,
        onPressed: () async {
          final result =
          await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (_) =>
              const AddVehicleScreen(),
            ),
          );

          if (result == true) {
            fetchVehicles();
          }
        },
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}