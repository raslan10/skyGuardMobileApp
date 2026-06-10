class AccidentModel {
  final int id;
  final String type;
  final String severity;
  final double latitude;
  final double longitude;
  final String timestamp;

  AccidentModel({
    required this.id,
    required this.type,
    required this.severity,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
  });

  factory AccidentModel.fromJson(Map<String, dynamic> json) {
    return AccidentModel(
      id: json['id'],
      type: json['type'],
      severity: json['severity'],
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      timestamp: json['timestamp'],
    );
  }
}