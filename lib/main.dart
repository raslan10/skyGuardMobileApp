import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:skyguardmobileapp/Home_Screen/Home_Screen.dart';
import 'package:skyguardmobileapp/Login_screen.dart';
import 'package:skyguardmobileapp/Register_Screen/Register_Screen.dart';
import 'package:skyguardmobileapp/ForgetPassword/ForgetPassword.dart';
import 'package:skyguardmobileapp/vehicles_screen/vehicles_screen.dart';
import 'package:skyguardmobileapp/add_vehicle_screen/add_vehicle_screen.dart';
import 'package:skyguardmobileapp/MapScreen/mapsScreen.dart';
import 'package:skyguardmobileapp/emergency/screens/emergency_contacts_screen.dart';
import 'package:skyguardmobileapp/emergency/screens/emergency_reports_screen.dart';
import 'package:skyguardmobileapp/services/notification_service.dart';

import 'firebase_options.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await NotificationService().init();

  runApp(const MyApp());
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  bool isLoading = true;
  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    final token = await secureStorage.read(key: 'token');

    if (!mounted) return;

    setState(() {
      isLoggedIn = token != null && token.isNotEmpty;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return isLoggedIn ? const HomeScreen() : const LoginScreen();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        useMaterial3: true,

        scaffoldBackgroundColor:
        const Color(0xFFF7F9FC),

        primaryColor:
        const Color(0xFF007BA7),

        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,

        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF007BA7),
          primary: const Color(0xFF007BA7),
          secondary: const Color(0xFF00B4D8),
          surface: Colors.white,
        ),

        textTheme:
        GoogleFonts.poppinsTextTheme(),

        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
          scrolledUnderElevation: 0,
          titleTextStyle:
          GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
          iconTheme: const IconThemeData(
            color: Colors.black87,
          ),
        ),

        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shadowColor:
          Colors.black.withOpacity(0.05),
          shape: RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(18),
          ),
          margin: EdgeInsets.zero,
        ),

        elevatedButtonTheme:
        ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor:
            const Color(0xFF007BA7),
            foregroundColor: Colors.white,
            elevation: 0,
            padding:
            const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 15,
            ),
            shape: RoundedRectangleBorder(
              borderRadius:
              BorderRadius.circular(16),
            ),
            textStyle:
            GoogleFonts.poppins(
              fontSize: 15,
              fontWeight:
              FontWeight.w600,
            ),
          ),
        ),

        outlinedButtonTheme:
        OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor:
            const Color(0xFF007BA7),
            side: const BorderSide(
              color: Color(0xFF007BA7),
            ),
            padding:
            const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 15,
            ),
            shape: RoundedRectangleBorder(
              borderRadius:
              BorderRadius.circular(16),
            ),
            textStyle:
            GoogleFonts.poppins(
              fontSize: 14,
              fontWeight:
              FontWeight.w600,
            ),
          ),
        ),

        inputDecorationTheme:
        InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,

          hintStyle:
          GoogleFonts.poppins(
            color: Colors.grey[500],
            fontSize: 14,
          ),

          labelStyle:
          GoogleFonts.poppins(
            color: Colors.grey[700],
            fontSize: 14,
          ),

          contentPadding:
          const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),

          border: OutlineInputBorder(
            borderRadius:
            BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),

          enabledBorder:
          OutlineInputBorder(
            borderRadius:
            BorderRadius.circular(16),
            borderSide: BorderSide(
              color: Colors.grey.shade200,
            ),
          ),

          focusedBorder:
          OutlineInputBorder(
            borderRadius:
            BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: Color(0xFF007BA7),
              width: 1.5,
            ),
          ),

          errorBorder: OutlineInputBorder(
            borderRadius:
            BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: Colors.red,
            ),
          ),
        ),

        snackBarTheme: SnackBarThemeData(
          behavior:
          SnackBarBehavior.floating,
          backgroundColor:
          Colors.black87,
          elevation: 0,
          contentTextStyle:
          GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 13,
            fontWeight:
            FontWeight.w500,
          ),
          shape: RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(14),
          ),
        ),

        progressIndicatorTheme:
        const ProgressIndicatorThemeData(
          color: Color(0xFF007BA7),
        ),

        dividerColor:
        Colors.grey.shade200,
      ),

      home: const AuthGate(),

      routes: {
        LoginScreen.routeName: (_) => const LoginScreen(),
        SignupScreen.routeName: (_) => const SignupScreen(),
        HomeScreen.routeName: (_) => const HomeScreen(),
        Forgetpassword.routeName: (_) => const Forgetpassword(),
        VehiclesScreen.routeName: (_) => const VehiclesScreen(),
        AddVehicleScreen.routeName: (_) => const AddVehicleScreen(),
        MapsScreen.routeName: (_) => const MapsScreen(),
        '/emergencyContacts': (_) => const EmergencyContactsScreen(),
        '/emergencyReports': (_) => const EmergencyReportsScreen(),
      },
    );
  }
}