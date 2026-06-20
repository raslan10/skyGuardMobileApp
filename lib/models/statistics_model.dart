class StatisticsModel {
  final int totalAlerts;
  final int totalAccidents;
  final int fireCount;
  final int accidentCount;
  final int highSeverityCount;
  final int mediumSeverityCount;

  // ✨ المتغيرات الذكية الجديدة المضافة من الباك آند
  final int safetyScore;
  final String driverRank;
  final double drivingHoursToday;
  final String weeklyTrend;

  StatisticsModel({
    required this.totalAlerts,
    required this.totalAccidents,
    required this.fireCount,
    required this.accidentCount,
    required this.highSeverityCount,
    required this.mediumSeverityCount,
    required this.safetyScore,
    required this.driverRank,
    required this.drivingHoursToday,
    required this.weeklyTrend,
  });

  factory StatisticsModel.fromJson(Map<String, dynamic> json) {
    return StatisticsModel(
      totalAlerts: json['totalAlerts'] ?? 0,
      totalAccidents: json['totalAccidents'] ?? 0,
      fireCount: json['fireCount'] ?? 0,
      accidentCount: json['accidentCount'] ?? 0,
      highSeverityCount: json['highSeverityCount'] ?? 0,
      mediumSeverityCount: json['mediumSeverityCount'] ?? 0,

      // 🧠 قراءة وحماية المتغيرات الجديدة (مع عمل cast للـ double والـ int للتأكيد)
      safetyScore: json['safety_score'] ?? json['safetyScore'] ?? 100,
      driverRank: json['driver_rank'] ?? json['driverRank'] ?? "Excellent",
      drivingHoursToday: (json['driving_hours_today'] ?? json['drivingHoursToday'] ?? 0.0).toDouble(),
      weeklyTrend: json['weekly_trend'] ?? json['weeklyTrend'] ?? "+0.0%",
    );
  }
}