class AnalyticsModel {
  final String accidentRiskPrediction;
  final String mainDangerCause;
  final String peakDangerHours;

  AnalyticsModel({
    required this.accidentRiskPrediction,
    required this.mainDangerCause,
    required this.peakDangerHours,
  });

  factory AnalyticsModel.fromJson(Map<String, dynamic> json) {
    return AnalyticsModel(
      accidentRiskPrediction: json['accident_risk_prediction'] ?? "0%",
      mainDangerCause: json['main_danger_cause'] ?? "None",
      peakDangerHours: json['peak_danger_hours'] ?? "N/A",
    );
  }
}