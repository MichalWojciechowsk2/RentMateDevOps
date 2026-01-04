class AdminReview {
  final int id;
  final int? propertyId;
  final int? userId;
  final int authorId;
  final double? rating;
  final String comment;
  final DateTime createdAt;
  final String? authorName;
  final String? propertyAddress;
  final String? reviewedUserName;

  AdminReview({
    required this.id,
    this.propertyId,
    this.userId,
    required this.authorId,
    this.rating,
    required this.comment,
    required this.createdAt,
    this.authorName,
    this.propertyAddress,
    this.reviewedUserName,
  });

  factory AdminReview.fromJson(Map<String, dynamic> json) {
    return AdminReview(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      propertyId: json['propertyId'],
      userId: json['userId'],
      authorId: json['authorId'] is int ? json['authorId'] : int.tryParse(json['authorId']?.toString() ?? '') ?? 0,
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : null,
      comment: json['comment']?.toString() ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
      authorName: json['authorName']?.toString(),
      propertyAddress: json['propertyAddress']?.toString(),
      reviewedUserName: json['reviewedUserName']?.toString(),
    );
  }
}

