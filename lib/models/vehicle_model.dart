class VehicleModel {
  final int id;
  final String name;
  final String plateNumber;
  final String deviceId;
  final String status;

  VehicleModel({
    required this.id,
    required this.name,
    required this.plateNumber,
    required this.deviceId,
    required this.status,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      plateNumber: json['plateNumber'] ?? '',
      deviceId: json['deviceId'] ?? '',
      status: json['status'] ?? '',
    );
  }
}