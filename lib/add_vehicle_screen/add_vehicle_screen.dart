import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skyguardmobileapp/MapScreen/appbar.dart';
import 'package:skyguardmobileapp/core-api/errors/error_handler.dart';
import 'package:skyguardmobileapp/core/widgets/app_snackbar.dart';
import 'package:skyguardmobileapp/services/vehicles_service.dart';

class AddVehicleScreen extends StatefulWidget {
  static const String routeName = "addVehicle";

  const AddVehicleScreen({super.key});

  @override
  State<AddVehicleScreen> createState() =>
      _AddVehicleScreenState();
}

class _AddVehicleScreenState
    extends State<AddVehicleScreen> {
  final _formKey = GlobalKey<FormState>();

  final _plateController =
  TextEditingController();

  final VehiclesService vehiclesService =
  VehiclesService();

  String? _selectedBrand;
  String? _selectedModel;
  int? _selectedYear;

  bool isLoading = false;

  final Map<String, List<String>> brandsModels = {
    "Toyota": ["Corolla", "Camry", "RAV4"],
    "Honda": ["Civic", "Accord", "CR-V"],
    "Ford": ["Focus", "Fiesta", "Mustang"],
  };

  List<String> get modelsForSelectedBrand =>
      _selectedBrand != null
          ? brandsModels[_selectedBrand!]!
          : [];

  @override
  void dispose() {
    _plateController.dispose();

    super.dispose();
  }

  Future<void> saveVehicle() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final vehicleName =
          '$_selectedBrand $_selectedModel';

      final response =
      await vehiclesService.addVehicle(
        name: vehicleName,
        plateNumber:
        _plateController.text.trim(),
        deviceId: 'SKY-001',
      );

      if (!mounted) return;

      AppSnackbar.success(
        context,
        response['message'] ??
            'Vehicle added successfully',
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      AppSnackbar.error(
        context,
        ErrorHandler.handle(e),
      );
    } finally {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  InputDecoration inputDecoration(
      String label,
      ) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(14),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Color(0xFF007BA7),
          width: 2,
        ),
      ),
      filled: true,
      fillColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF007BA7);

    return Scaffold(
      appBar: const WaveAppBar(),
      backgroundColor:
      Colors.grey.shade100,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Form(
          key: _formKey,
          child: Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius:
              BorderRadius.circular(20),
            ),
            child: Padding(
              padding:
              const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    "Add Vehicle",
                    style:
                    GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight:
                      FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    "Add your vehicle information below.",
                    style:
                    GoogleFonts.poppins(
                      color:
                      Colors.grey[600],
                    ),
                  ),

                  const SizedBox(height: 24),

                  _buildTextField(
                    "Plate Number",
                    _plateController,
                  ),

                  const SizedBox(height: 16),

                  _buildDropdown(
                    label: "Brand",
                    value: _selectedBrand,
                    items: brandsModels.keys
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedBrand =
                            value;

                        _selectedModel =
                        null;
                      });
                    },
                  ),

                  const SizedBox(height: 16),

                  _buildDropdown(
                    label: "Model",
                    value: _selectedModel,
                    items:
                    modelsForSelectedBrand,
                    onChanged: (value) {
                      setState(() {
                        _selectedModel =
                            value;
                      });
                    },
                  ),

                  const SizedBox(height: 16),

                  _buildYearPicker(
                    primaryColor,
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width:
                    double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : saveVehicle,
                      style:
                      ElevatedButton.styleFrom(
                        backgroundColor:
                        primaryColor,
                        padding:
                        const EdgeInsets.symmetric(
                          vertical: 16,
                        ),
                        shape:
                        RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(
                            16,
                          ),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                        height: 22,
                        width: 22,
                        child:
                        CircularProgressIndicator(
                          strokeWidth:
                          2,
                          color: Colors
                              .white,
                        ),
                      )
                          : Text(
                        "Save Vehicle",
                        style:
                        GoogleFonts.poppins(
                          color: Colors
                              .white,
                          fontSize:
                          18,
                          fontWeight:
                          FontWeight
                              .w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      String label,
      TextEditingController controller,
      ) {
    return TextFormField(
      controller: controller,
      decoration: inputDecoration(
        label,
      ),
      validator: (value) {
        if (value == null ||
            value.trim().isEmpty) {
          return "Please enter $label";
        }

        return null;
      },
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required void Function(String?)
    onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items
          .map(
            (item) =>
            DropdownMenuItem(
              value: item,
              child: Text(item),
            ),
      )
          .toList(),
      onChanged: onChanged,
      decoration: inputDecoration(
        label,
      ),
      validator: (value) {
        if (value == null) {
          return "Please select $label";
        }

        return null;
      },
    );
  }

  Widget _buildYearPicker(
      Color primaryColor,
      ) {
    return TextFormField(
      readOnly: true,
      decoration: InputDecoration(
        labelText: _selectedYear == null
            ? "Select Year"
            : "Year: $_selectedYear",
        border: OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(14),
        ),
        focusedBorder:
        OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(14),
          borderSide:
          const BorderSide(
            color: Color(0xFF007BA7),
            width: 2,
          ),
        ),
        filled: true,
        fillColor: Colors.white,
        suffixIcon: Icon(
          Icons.calendar_today,
          color: primaryColor,
        ),
      ),
      onTap: () async {
        final currentYear =
            DateTime.now().year;

        final picked =
        await showDatePicker(
          context: context,
          initialDate:
          DateTime(currentYear),
          firstDate: DateTime(1990),
          lastDate:
          DateTime(currentYear),
        );

        if (picked != null) {
          setState(() {
            _selectedYear =
                picked.year;
          });
        }
      },
      validator: (value) {
        if (_selectedYear == null) {
          return "Please select year";
        }

        return null;
      },
    );
  }
}