import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skyguardmobileapp/core/resources/reusable/AssetsManager.dart';
import 'package:skyguardmobileapp/core/resources/reusable/StringsManager.dart';
import 'package:skyguardmobileapp/core/resources/reusable/CustomField.dart';
import 'package:skyguardmobileapp/core-api/errors/error_handler.dart';
import 'package:skyguardmobileapp/core/widgets/app_snackbar.dart';
import 'package:skyguardmobileapp/services/auth_service.dart';
import 'package:skyguardmobileapp/verify_email_screen/verify_email_screen.dart';

class SignupScreen extends StatefulWidget {
  static const String routeName = "signup";

  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController passwordController;
  late TextEditingController phoneController;

  String selectedRole = "user";
  String selectedCountryCode = "+20";

  final List<Map<String, String>> countryCodes = [
    {"code": "+20", "flag": "🇪🇬", "name": "Egypt"},
    {"code": "+966", "flag": "🇸🇦", "name": "KSA"},
    {"code": "+971", "flag": "🇦🇪", "name": "UAE"},
    {"code": "+1", "flag": "🇺🇸", "name": "USA"},
    {"code": "+44", "flag": "🇬🇧", "name": "UK"},
    {"code": "+965", "flag": "🇰🇼", "name": "Kuwait"},
  ];

  final AuthService authService = AuthService();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    phoneController = TextEditingController();
  }

  Future<void> handleRegister() async {
    if (!formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
    });

    try {
      // ✨ التعديل السحري: شيلنا الـ phone من هنا عشان الـ AuthService مش معرفها جواه وبيجيب إيرور
      final result = await authService.register(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        role: selectedRole,
      );

      if (!mounted) return;

      AppSnackbar.success(
        context,
        result['message'] ?? 'Register successful',
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => VerifyEmailScreen(
            email: emailController.text.trim(),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      AppSnackbar.error(
        context,
        ErrorHandler.handle(e),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Center(
                  child: Container(
                    height: 78,
                    width: 78,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF7FB),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Center(
                      child: Image.asset(
                        AssetsManager.appbar,
                        height: 42,
                        width: 42,
                        color: const Color(0xFF007BA7),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Center(
                  child: Text(
                    "Create Account",
                    style: GoogleFonts.poppins(fontSize: 26, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A)),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    "Sign up to get started with SkyGuard",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
                  ),
                ),
                const SizedBox(height: 28),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Sign Up",
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 20, color: const Color(0xFF007BA7)),
                      ),
                      const SizedBox(height: 20),

                      CustomField(
                        controller: nameController,
                        icon: AssetsManager.profile,
                        title: "Full Name",
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return 'Please enter your name';
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      CustomField(
                        controller: emailController,
                        icon: AssetsManager.email,
                        title: StringsManager.email,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return 'Please enter your email';
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      // 📞 حقل رقم الهاتف الدولي (مصر وبره مصر) هيفضل شغال تمام في الـ UI
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 4, bottom: 6),
                            child: Text(
                              "Phone Number",
                              style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.grey[700]),
                            ),
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 105,
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.black12, width: 1),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: selectedCountryCode,
                                    dropdownColor: Colors.white,
                                    isExpanded: true,
                                    items: countryCodes.map((country) {
                                      return DropdownMenuItem<String>(
                                        value: country["code"],
                                        child: Center(
                                          child: Text(
                                            "${country["flag"]} ${country["code"]}",
                                            style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      if (value != null) {
                                        setState(() => selectedCountryCode = value);
                                      }
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextFormField(
                                  controller: phoneController,
                                  keyboardType: TextInputType.phone,
                                  style: GoogleFonts.poppins(fontSize: 14),
                                  decoration: InputDecoration(
                                    hintText: "100 123 4567",
                                    hintStyle: GoogleFonts.poppins(color: Colors.grey[400]),
                                    filled: true,
                                    fillColor: Colors.grey[50],
                                    contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
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
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) return 'Please enter your phone number';
                                    if (value.length < 7) return 'Invalid phone number';
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      CustomField(
                        controller: passwordController,
                        icon: AssetsManager.pass,
                        title: StringsManager.password,
                        isPassword: true,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return 'Please enter your password';
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 4, bottom: 6),
                            child: Text(
                              "Account Type (Role)",
                              style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.grey[700]),
                            ),
                          ),
                          DropdownButtonFormField<String>(
                            initialValue: selectedRole,
                            elevation: 2,
                            dropdownColor: Colors.white,
                            style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.manage_accounts_outlined, color: Color(0xFF007BA7)),
                              filled: true,
                              fillColor: Colors.grey[50],
                              contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.black12, width: 1)),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF007BA7), width: 1.5)),
                            ),
                            items: const [
                              DropdownMenuItem(value: "user", child: Text("Driver / User")),
                              DropdownMenuItem(value: "admin", child: Text("Supervisor / Admin")),
                            ],
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                setState(() => selectedRole = newValue);
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : handleRegister,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF007BA7),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: isLoading
                              ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                          )
                              : Text(
                            "Create Account",
                            style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Already have an account? ", style: GoogleFonts.poppins(color: Colors.grey[700])),
                          TextButton(
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              "Login",
                              style: GoogleFonts.poppins(color: const Color(0xFF007BA7), fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}