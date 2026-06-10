class EmergencyReport {
  final int id;
  final String triggerType;
  final DateTime timestamp;
  final double? latitude;
  final double? longitude;
  final String status;
  final String note;

  EmergencyReport({
    required this.id,
    required this.triggerType,
    required this.timestamp,
    required this.status,
    required this.note,
    this.latitude,
    this.longitude,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'triggerType': triggerType,
      'timestamp': timestamp.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'status': status,
      'note': note,
    };
  }

  factory EmergencyReport.fromJson(Map<String, dynamic> json) {
    return EmergencyReport(
      id: json['id'] ?? 0,

      triggerType:
      json['triggerType'] ??
          json['type'] ??
          '',

      timestamp:
      DateTime.tryParse(
        json['timestamp'] ?? '',
      ) ??
          DateTime.now(),

      latitude:
      (json['latitude'] as num?)?.toDouble(),

      longitude:
      (json['longitude'] as num?)?.toDouble(),

      status:
      json['status'] ?? '',

      note:
      json['note'] ??
          json['message'] ??
          '',
    );
  }
}