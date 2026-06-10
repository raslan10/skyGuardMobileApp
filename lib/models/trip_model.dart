class TripModel {
  final int id;
  final String startLocation;
  final String endLocation;
  final String startTime;
  final String endTime;
  final double distance;
  final String status;

  TripModel({
    required this.id,
    required this.startLocation,
    required this.endLocation,
    required this.startTime,
    required this.endTime,
    required this.distance,
    required this.status,
  });

  factory TripModel.fromJson(Map<String, dynamic> json) {
    return TripModel(
      id: json['id'],
      startLocation: json['startLocation'],
      endLocation: json['endLocation'],
      startTime: json['startTime'],
      endTime: json['endTime'],
      distance: (json['distance'] as num).toDouble(),
      status: json['status'],
    );
  }
}