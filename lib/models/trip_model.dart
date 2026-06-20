class TripModel {
  final int id;
  final String startLocation;
  final String endLocation;
  final String startTime;
  final String endTime;
  final double distance;
  final String status;

  // ✨ القراءات الذكية والمتقدمة المضافة من الباك آند لـ Emergency 2.0 & Analytics
  final int duration;
  final int safetyScore;
  final int distractionsCount;
  final int harshBrakesCount;

  TripModel({
    required this.id,
    required this.startLocation,
    required this.endLocation,
    required this.startTime,
    required this.endTime,
    required this.distance,
    required this.status,
    required this.duration,
    required this.safetyScore,
    required this.distractionsCount,
    required this.harshBrakesCount,
  });

  factory TripModel.fromJson(Map<String, dynamic> json) {
    return TripModel(
      id: json['id'] ?? 0,
      startLocation: json['startLocation'] ?? json['start_location'] ?? 'Unknown',
      endLocation: json['endLocation'] ?? json['end_location'] ?? 'Unknown',
      startTime: json['startTime'] ?? json['start_time'] ?? '',
      endTime: json['endTime'] ?? json['end_time'] ?? '',
      distance: (json['distance'] as num? ?? 0.0).toDouble(),
      status: json['status'] ?? 'Completed',

      // 🧠 قراءة وحماية المتغيرات المتقدمة الجديدة
      duration: json['duration'] ?? 0,
      safetyScore: json['safety_score'] ?? json['safetyScore'] ?? 100,
      distractionsCount: json['distractions_count'] ?? json['distractionsCount'] ?? 0,
      harshBrakesCount: json['harsh_brakes_count'] ?? json['harshBrakesCount'] ?? 0,
    );
  }
}