import 'package:flutter/material.dart';
import 'package:skyguardmobileapp/Login_screen.dart';
import 'package:skyguardmobileapp/services/auth_service.dart';

class VerifyEmailScreen extends StatefulWidget {
  final String email;

  const VerifyEmailScreen({
    super.key,
    required this.email,
  });

  @override
  State<VerifyEmailScreen> createState() =>
      _VerifyEmailScreenState();
}

class _VerifyEmailScreenState
    extends State<VerifyEmailScreen> {
  final TextEditingController otpController =
  TextEditingController();

  final AuthService authService = AuthService();

  bool isLoading = false;

  Future<void> verify() async {
    if (otpController.text.trim().isEmpty) return;

    setState(() {
      isLoading = true;
    });

    try {
      await authService.verifyEmail(
        email: widget.email,
        otp: otpController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
          Text('Email verified successfully'),
        ),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        ),
            (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Email'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'Enter OTP sent to\n${widget.email}',
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 20),

            TextField(
              controller: otpController,
              decoration: const InputDecoration(
                labelText: 'OTP Code',
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                isLoading ? null : verify,
                child: isLoading
                    ? const CircularProgressIndicator()
                    : const Text(
                  'Verify',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}