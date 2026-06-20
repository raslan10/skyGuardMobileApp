class ApiConstants {
  static const String baseUrl = 'https://kelp-cage-makeover.ngrok-free.dev';

  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = "api/auth/forgot-password";
  static const String verifyEmail = '/verify-email';

  // 🤖 تم التعديل بوضع الـ / لتفادي دمج الـ URLs الغلط
  static const String aiAnalytics = '/api/v1/ai/analytics';

  static const String alerts = '/alerts';
  static const String statistics = '/statistics';
  static const String trips = '/history';
  static const String accidents = '/history';
  static const String profile = '/profile';
  static const String reviews = '/reviews';

  // 🚗 الـ Vehicles Management
  static const String vehicles = '/vehicles';
  // ✨ تم إضافة الدالة المفقودة هنا لحل خطأ شاشة التفاصيل
  static String vehicleDetails(int id) => '/vehicles/$id';

  static const String contact = '/contact-us';
  static const String sos = '/sos';
  static const String fcmToken = '/fcm-token';
  static const String sendTestNotification = '/send-test-notification';
}