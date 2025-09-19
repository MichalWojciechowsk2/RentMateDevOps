class PropertyImage {
  final int id;
  final int propertyId;
  final String imageUrl;
  final bool isMainImage;
  final DateTime createdAt;

  PropertyImage({
    required this.id,
    required this.propertyId,
    required this.imageUrl,
    required this.isMainImage,
    required this.createdAt,
  });

  factory PropertyImage.fromJson(Map<String, dynamic> json) {
    return PropertyImage(
      id: json['id'] ?? 0,
      propertyId: json['propertyId'] ?? 0,
      imageUrl: json['imageUrl'] ?? '',
      isMainImage: json['isMainImage'] ?? false,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'propertyId': propertyId,
      'imageUrl': imageUrl,
      'isMainImage': isMainImage,
      'createdAt': createdAt.toIso8601String(),
    };
  }
} 