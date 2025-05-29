class Property {
  final int id;
  final int ownerId;
  final String title;
  final String description;
  final double basePrice;
  final double baseDeposit;
  final String address;
  final String city;
  final String postalCode;
  final int roomCount;
  final double area;
  final List<String> images;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Property({
    required this.id,
    required this.ownerId,
    required this.title,
    required this.description,
    required this.basePrice,
    required this.baseDeposit,
    required this.address,
    required this.city,
    required this.postalCode,
    required this.roomCount,
    required this.area,
    required this.images,
    required this.isActive,
    required this.createdAt,
    this.updatedAt,
  });

  factory Property.fromJson(Map<String, dynamic> json) {
    return Property(
      id: json['id'] as int,
      ownerId: json['ownerId'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      basePrice: (json['basePrice'] as num).toDouble(),
      baseDeposit: (json['baseDeposit'] as num).toDouble(),
      address: json['address'] as String,
      city: json['city'] as String,
      postalCode: json['postalCode'] as String,
      roomCount: json['roomCount'] as int,
      area: (json['area'] as num).toDouble(),
      images: List<String>.from(json['images'] ?? []),
      isActive: json['isActive'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ownerId': ownerId,
      'title': title,
      'description': description,
      'basePrice': basePrice,
      'baseDeposit': baseDeposit,
      'address': address,
      'city': city,
      'postalCode': postalCode,
      'roomCount': roomCount,
      'area': area,
      'images': images,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // Metoda pomocnicza do tworzenia nowej nieruchomości
  static Property createNew({
    required String title,
    required String description,
    required double basePrice,
    required double baseDeposit,
    required String address,
    required String city,
    required String postalCode,
    required int roomCount,
    required double area,
    List<String> images = const [],
    bool isActive = true,
  }) {
    return Property(
      id: 0, // Tymczasowe ID, zostanie nadane przez serwer
      ownerId: 0, // Tymczasowe ID właściciela, zostanie nadane przez serwer
      title: title,
      description: description,
      basePrice: basePrice,
      baseDeposit: baseDeposit,
      address: address,
      city: city,
      postalCode: postalCode,
      roomCount: roomCount,
      area: area,
      images: images,
      isActive: isActive,
      createdAt: DateTime.now(),
    );
  }
} 