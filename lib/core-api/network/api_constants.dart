class ApiConstants {
  static const String baseUrl =
      'https://kelp-cage-makeover.ngrok-free.dev';

  static const String login = '/login';
  static const String register = '/register';

  static const String alerts = '/alerts';
  static const String statistics = '/statistics';

  // HISTORY
  static const String trips = '/history';
  static const String accidents = '/history';

  static const String profile = '/profile';
  static const String reviews = '/reviews';

  static const String vehicles = '/vehicles';

  static const String contact = '/contact-us';

  static const String sos = '/sos';

  static const String fcmToken = '/fcm-token';
  static const String sendTestNotification =
      '/send-test-notification';
  static const String verifyEmail = '/verify-email';

  static String vehicleDetails(int id) =>
      '/vehicles/$id';
}