class StatisticsModel {
  final int totalAlerts;
  final int totalAccidents;
  final int fireCount;
  final int accidentCount;
  final int highSeverityCount;
  final int mediumSeverityCount;

  StatisticsModel({
    required this.totalAlerts,
    required this.totalAccidents,
    required this.fireCount,
    required this.accidentCount,
    required this.highSeverityCount,
    required this.mediumSeverityCount,
  });

  factory StatisticsModel.fromJson(Map<String, dynamic> json) {
    return StatisticsModel(
      totalAlerts: json['totalAlerts'] ?? 0,
      totalAccidents: json['totalAccidents'] ?? 0,
      fireCount: json['fireCount'] ?? 0,
      accidentCount: json['accidentCount'] ?? 0,
      highSeverityCount: json['highSeverityCount'] ?? 0,
      mediumSeverityCount: json['mediumSeverityCount'] ?? 0,
    );
  }
}