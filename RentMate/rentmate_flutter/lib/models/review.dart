class Review {
  final int id;
  final int? propertyId;
  final int? userId;
  final int authorId;
  final double rating;
  final String comment;
  final DateTime createdAt;
  final Map<String, dynamic>? author;

  Review({
    required this.id,
    this.propertyId,
    this.userId,
    required this.authorId,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.author,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] is int ? json['id'] ?? 0 : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      propertyId: json['propertyId'],
      userId: json['userId'],
      authorId: json['authorId'] is int ? json['authorId'] ?? 0 : int.tryParse(json['authorId']?.toString() ?? '') ?? 0,
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : 0.0,
      comment: json['comment']?.toString() ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
      author: json['author'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'propertyId': propertyId,
      'userId': userId,
      'authorId': authorId,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
      'author': author,
    };
  }
}

class CreateReviewDto {
  final int? propertyId;
  final int? userId;
  final double rating;
  final String comment;

  CreateReviewDto({
    this.propertyId,
    this.userId,
    required this.rating,
    required this.comment,
  });

  Map<String, dynamic> toJson() {
    return {
      'propertyId': propertyId,
      'userId': userId,
      'rating': rating,
      'comment': comment,
    };
  }
}
