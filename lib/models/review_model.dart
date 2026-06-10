class ReviewModel {
  final int id;
  final String name;
  final int rating;
  final String comment;

  ReviewModel({
    required this.id,
    required this.name,
    required this.rating,
    required this.comment,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      rating: json['rating'] ?? 0,
      comment: json['comment'] ?? '',
    );
  }
}