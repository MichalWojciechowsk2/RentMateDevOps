import 'property_image.dart';

class Property {
  final int id;
  final int ownerId;
  final String title;
  final String description;
  final double basePrice;
  final double baseDeposit;
  final String address;
  final String city;
  final String district;
  final String postalCode;
  final int roomCount;
  final String area;
  final List<PropertyImage> images;
  final bool isActive;
  final int? chatGroupId;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? ownerUsername;

  Property({
    required this.id,
    required this.ownerId,
    required this.title,
    required this.description,
    required this.basePrice,
    required this.baseDeposit,
    required this.address,
    required this.city,
    required this.district,
    required this.postalCode,
    required this.roomCount,
    required this.area,
    required this.images,
    required this.isActive,
    this.chatGroupId,
    required this.createdAt,
    this.updatedAt,
    this.ownerUsername,
  });

  factory Property.fromJson(Map<String, dynamic> json) {
    return Property(
      id: json['id'] is int ? json['id'] ?? 0 : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      ownerId: json['ownerId'] is int ? json['ownerId'] ?? 0 : int.tryParse(json['ownerId']?.toString() ?? '') ?? 0,
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      basePrice: json['basePrice'] != null ? (json['basePrice'] as num).toDouble() : 0.0,
      baseDeposit: json['baseDeposit'] != null ? (json['baseDeposit'] as num).toDouble() : 0.0,
      address: json['address']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      district: json['district']?.toString() ?? '',
      postalCode: json['postalCode']?.toString() ?? '',
      roomCount: json['roomCount'] is int ? json['roomCount'] ?? 0 : int.tryParse(json['roomCount']?.toString() ?? '') ?? 0,
      area: json['area']?.toString() ?? '',
      images: (json['images'] as List?)?.map((e) => PropertyImage.fromJson(e)).toList() ?? [],
      isActive: json['isActive'] is bool ? json['isActive'] ?? false : (json['isActive']?.toString() == 'true'),
      chatGroupId: json['chatGroupId'] is int ? json['chatGroupId'] : int.tryParse(json['chatGroupId']?.toString() ?? ''),
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      ownerUsername: json['ownerUsername']?.toString(),
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
      'district': district,
      'postalCode': postalCode,
      'roomCount': roomCount,
      'area': area,
      'images': images.map((e) => e.toJson()).toList(),
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'ownerUsername': ownerUsername,
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
    required String district,
    required String postalCode,
    required int roomCount,
    required String area,
    required String ownerUsername,
    List<PropertyImage> images = const [],
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
      district: district,
      postalCode: postalCode,
      roomCount: roomCount,
      area: area,
      images: images,
      isActive: isActive,
      createdAt: DateTime.now(),
      ownerUsername: ownerUsername,
    );
  }
  
  // Metoda pomocnicza do pobierania głównego zdjęcia
  String? get mainImageUrl {
    final mainImage = images.where((img) => img.isMainImage).firstOrNull;
    return mainImage?.imageUrl ?? images.firstOrNull?.imageUrl;
  }
  
  // Metoda pomocnicza do pobierania wszystkich URL zdjęć
  List<String> get imageUrls {
    return images.map((img) => img.imageUrl).toList();
  }
} 