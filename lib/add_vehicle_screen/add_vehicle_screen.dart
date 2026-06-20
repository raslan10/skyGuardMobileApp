import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skyguardmobileapp/core/widgets/app_snackbar.dart';

class AddVehicleScreen extends StatefulWidget {
  static const String routeName = "addVehicle";

  const AddVehicleScreen({super.key});

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _carNameController;
  late TextEditingController _plateNumberController;
  late TextEditingController _modelYearController;

  String _selectedVehicleType = "Sedan";
  bool _isLoading = false;

  final List<String> _vehicleTypes = ["Sedan", "SUV", "Hatchback", "Truck", "Motorcycle"];

  @override
  void initState() {
    super.initState();
    _carNameController = TextEditingController();
    _plateNumberController = TextEditingController();
    _modelYearController = TextEditingController();
  }

  @override
  void dispose() {
    _carNameController.dispose();
    _plateNumberController.dispose();
    _modelYearController.dispose();
    super.dispose();
  }

  Future<void> _submitVehicle() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // 🧠 هنا بيتم الربط المستقبلي مع الـ API بتاعك (مثال: vehicleService.addVehicle)
      await Future.delayed(const Duration(milliseconds: 1200)); // محاكاة سريعة للرفع

      if (!mounted) return;

      AppSnackbar.success(
        context,
        "${_carNameController.text.trim()} added to your fleet successfully! 🚗🔥",
      );

      // العودة للشاشة السابقة وتحديث القائمة
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      AppSnackbar.error(context, "Failed to add vehicle. Please try again.");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Add New Vehicle",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF007BA7),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Icon(
                    Icons.directions_car_filled_outlined,
                    size: 72,
                    color: const Color(0xFF007BA7).withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: Text(
                    "Register a Vehicle to SkyGuard",
                    style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
                  ),
                ),
                const SizedBox(height: 28),

                // 🚗 حقل اسم السيارة
                _buildFieldLabel("Vehicle Name / Model"),
                TextFormField(
                  controller: _carNameController,
                  style: GoogleFonts.poppins(fontSize: 14),
                  decoration: _buildInputDecoration("e.g. Hyundai Elantra"),
                  validator: (value) => value == null || value.trim().isEmpty ? 'Please enter vehicle name' : null,
                ),
                const SizedBox(height: 16),

                // 🔢 حقل رقم اللوحة
                _buildFieldLabel("Plate Number"),
                TextFormField(
                  controller: _plateNumberController,
                  style: GoogleFonts.poppins(fontSize: 14),
                  decoration: _buildInputDecoration("e.g. 1234 أ ب ج"),
                  validator: (value) => value == null || value.trim().isEmpty ? 'Please enter plate number' : null,
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    // 📅 حقل سنة الموديل
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFieldLabel("Model Year"),
                          TextFormField(
                            controller: _modelYearController,
                            keyboardType: TextInputType.number,
                            style: GoogleFonts.poppins(fontSize: 14),
                            decoration: _buildInputDecoration("e.g. 2024"),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) return 'Enter year';
                              if (int.tryParse(value) == null) return 'Invalid year';
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),

                    // 🚙 قائمة نوع السيارة
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFieldLabel("Vehicle Type"),
                          DropdownButtonFormField<String>(
                            value: _selectedVehicleType,
                            dropdownColor: Colors.white,
                            style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
                            decoration: _buildInputDecoration(""),
                            items: _vehicleTypes.map((type) {
                              return DropdownMenuItem(value: type, child: Text(type));
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => _selectedVehicleType = value);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 34),

                // 🚀 زرار الحفظ
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF007BA7),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: _isLoading ? null : _submitVehicle,
                    child: _isLoading
                        ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                    )
                        : Text(
                      "Save Vehicle",
                      style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 6),
      child: Text(
        label,
        style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.grey[700]),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.poppins(color: Colors.grey[400], fontSize: 13),
      filled: true,
      fillColor: Colors.grey[50],
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.black12, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF007BA7), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
    );
  }
}