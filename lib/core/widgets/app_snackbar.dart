import 'package:flutter/material.dart';

class AppSnackbar {
  static void success(
      BuildContext context,
      String message,
      ) {
    _show(
      context,
      message,
      backgroundColor: Colors.green,
      icon: Icons.check_circle,
    );
  }

  static void error(
      BuildContext context,
      String message,
      ) {
    _show(
      context,
      message,
      backgroundColor: Colors.red,
      icon: Icons.error,
    );
  }

  static void info(
      BuildContext context,
      String message,
      ) {
    _show(
      context,
      message,
      backgroundColor: Colors.blue,
      icon: Icons.info,
    );
  }

  static void _show(
      BuildContext context,
      String message, {
        required Color backgroundColor,
        required IconData icon,
      }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}