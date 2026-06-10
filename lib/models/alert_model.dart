class AlertModel {
  final int id;
  final String type;
  final double lat;
  final double lng;
  final String timestamp;
  final String severity;

  AlertModel({
    required this.id,
    required this.type,
    required this.lat,
    required this.lng,
    required this.timestamp,
    required this.severity,
  });

  factory AlertModel.fromJson(Map<String, dynamic> json) {
    return AlertModel(
      id: json['id'],
      type: json['type'],
      lat: (json['location']['lat'] as num).toDouble(),
      lng: (json['location']['lng'] as num).toDouble(),
      timestamp: json['timestamp'],
      severity: json['severity'],
    );
  }
}