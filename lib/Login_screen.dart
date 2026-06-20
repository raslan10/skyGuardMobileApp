import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skyguardmobileapp/Home_Screen/home_screen.dart';
import 'package:skyguardmobileapp/Register_Screen/Register_Screen.dart';
import 'package:skyguardmobileapp/ForgetPassword/ForgetPassword.dart';
import 'package:skyguardmobileapp/core/resources/reusable/AssetsManager.dart';
import 'package:skyguardmobileapp/core/resources/reusable/StringsManager.dart';
import 'package:skyguardmobileapp/core/resources/reusable/CustomField.dart';
import 'package:skyguardmobileapp/core-api/errors/error_handler.dart';
// 💡 تم إشالة الـ Import غير المستخدم الخاص بـ googleButton
import 'package:skyguardmobileapp/services/auth_service.dart';
import 'package:skyguardmobileapp/core/widgets/app_snackbar.dart';

class LoginScreen extends StatefulWidget {
  static const String routeName = "login";

  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  late TextEditingController emailController;
  late TextEditingController passwordController;
  final FocusNode emailFocusNode = FocusNode();

  final AuthService authService = AuthService();

  bool isLoading = false;
  String? detectedRole;
  bool isCheckingRole = false;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    passwordController = TextEditingController();

    emailFocusNode.addListener(() {
      if (!emailFocusNode.hasFocus && emailController.text.trim().isNotEmpty) {
        _checkUserRoleAutomatically();
      }
    });
  }

  Future<void> _checkUserRoleAutomatically() async {
    final email = emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) return;

    setState(() {
      isCheckingRole = true;
      detectedRole = null;
    });

    try {
      if (email.toLowerCase().contains('admin')) {
        detectedRole = "admin";
      } else {
        detectedRole = "user";
      }
    } catch (_) {
      detectedRole = "user";
    } finally {
      if (mounted) {
        setState(() {
          isCheckingRole = false;
        });
      }
    }
  }

  Future<void> handleLogin() async {
    if (!formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
    });

    try {
      final result = await authService.login(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (!mounted) return;

      AppSnackbar.success(
        context,
        result['message'] ?? 'Login successful',
      );

      Navigator.pushReplacementNamed(
        context,
        HomeScreen.routeName,
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
    emailController.dispose();
    passwordController.dispose();
    emailFocusNode.dispose();
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
                    "Welcome Back",
                    style: GoogleFonts.poppins(fontSize: 26, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A)),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    "Login to continue using SkyGuard",
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
                        StringsManager.loginAccount,
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 20, color: const Color(0xFF007BA7)),
                      ),
                      const SizedBox(height: 20),

                      Focus(
                        focusNode: emailFocusNode,
                        child: CustomField(
                          controller: emailController,
                          icon: AssetsManager.email,
                          title: StringsManager.email,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your email';
                            }
                            return null;
                          },
                        ),
                      ),

                      if (isCheckingRole)
                        const Padding(
                          padding: EdgeInsets.only(top: 8, left: 6),
                          child: SizedBox(height: 14, width: 14, child: CircularProgressIndicator(strokeWidth: 2)),
                        )
                      else if (detectedRole != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8, left: 6),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: detectedRole == "admin" ? Colors.amber[50] : Colors.green[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: detectedRole == "admin" ? Colors.amber : Colors.green, width: 1),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  detectedRole == "admin" ? Icons.admin_panel_settings : Icons.person,
                                  size: 14,
                                  color: detectedRole == "admin" ? Colors.amber[800] : Colors.green[800],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  detectedRole == "admin" ? "Account Type: Supervisor / Admin" : "Account Type: Driver / User",
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: detectedRole == "admin" ? Colors.amber[800] : Colors.green[800],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      const SizedBox(height: 14),
                      CustomField(
                        controller: passwordController,
                        icon: AssetsManager.pass,
                        title: StringsManager.password,
                        isPassword: true,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 6),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const Forgetpassword()),
                            );
                          },
                          child: Text(
                            "Forgot Password?",
                            style: GoogleFonts.poppins(color: const Color(0xFF007BA7), fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : handleLogin,
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
                            "Login to Account",
                            style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),

                      // ✨ تم إزالة الـ Divider وزرار الـ Google من هنا لتبسيط الشاشة وتفادي الضغطات الخاطئة
                      const SizedBox(height: 20),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Don’t have an account? ", style: GoogleFonts.poppins(color: Colors.grey[700])),
                          TextButton(
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const SignupScreen()),
                              );
                            },
                            child: Text(
                              "Sign Up",
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