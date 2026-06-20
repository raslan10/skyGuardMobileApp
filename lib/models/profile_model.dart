class ProfileModel {
  final String name;
  final String email;
  final String phone;
  final String role;
  final String profileImage;

  ProfileModel({
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.profileImage,
  });

  factory ProfileModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return ProfileModel(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'] ?? 'Driver',
      profileImage:
      json['profileImage'] ??
          json['profile_image'] ??
          '',
    );
  }
}