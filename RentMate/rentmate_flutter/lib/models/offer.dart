enum OfferStatus {
  active,
  accepted,
  completed,
  cancelled,
}

class Offer {
  final int id;
  final int propertyId;
  final double rentAmount;
  final double depositAmount;
  final DateTime rentalPeriodStart;
  final DateTime rentalPeriodEnd;
  final OfferStatus status;
  final int? tenantId;
  final DateTime createdAt;
  final DateTime? acceptedAt;
  final String? offerContract;
  final String? contractPdfUrl;
  final Map<String, dynamic>? tenant;
  final String tenantName;

  Offer({
    required this.id,
    required this.propertyId,
    required this.rentAmount,
    required this.depositAmount,
    required this.rentalPeriodStart,
    required this.rentalPeriodEnd,
    required this.status,
    this.tenantId,
    required this.createdAt,
    this.acceptedAt,
    this.offerContract,
    this.contractPdfUrl,
    this.tenant,
    this.tenantName = '',
  });

  factory Offer.fromJson(Map<String, dynamic> json) {
    OfferStatus status;
    switch (json['status']?.toString().toLowerCase()) {
      case 'active':
        status = OfferStatus.active;
        break;
      case 'accepted':
        status = OfferStatus.accepted;
        break;
      case 'completed':
        status = OfferStatus.completed;
        break;
      case 'cancelled':
        status = OfferStatus.cancelled;
        break;
      default:
        status = OfferStatus.active;
    }

    return Offer(
      id: json['id'] is int ? json['id'] ?? 0 : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      propertyId: json['propertyId'] is int ? json['propertyId'] ?? 0 : int.tryParse(json['propertyId']?.toString() ?? '') ?? 0,
      rentAmount: json['rentAmount'] != null ? (json['rentAmount'] as num).toDouble() : 0.0,
      depositAmount: json['depositAmount'] != null ? (json['depositAmount'] as num).toDouble() : 0.0,
      rentalPeriodStart: json['rentalPeriodStart'] != null
          ? DateTime.parse(json['rentalPeriodStart'].toString())
          : DateTime.now(),
      rentalPeriodEnd: json['rentalPeriodEnd'] != null
          ? DateTime.parse(json['rentalPeriodEnd'].toString())
          : DateTime.now(),
      status: status,
      tenantId: json['tenantId'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
      acceptedAt: json['acceptedAt'] != null
          ? DateTime.parse(json['acceptedAt'].toString())
          : null,
      offerContract: json['offerContract'],
      contractPdfUrl: json['contractPdfUrl'],
      tenant: json['tenant'],
      tenantName: json['tenant'] != null && json['tenant'] is Map
          ? '${json['tenant']['firstName'] ?? ''} ${json['tenant']['lastName'] ?? ''}'.trim()
          : json['tenantName']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    String statusString;
    switch (status) {
      case OfferStatus.active:
        statusString = 'Active';
        break;
      case OfferStatus.accepted:
        statusString = 'Accepted';
        break;
      case OfferStatus.completed:
        statusString = 'Completed';
        break;
      case OfferStatus.cancelled:
        statusString = 'Cancelled';
        break;
    }

    return {
      'id': id,
      'propertyId': propertyId,
      'rentAmount': rentAmount,
      'depositAmount': depositAmount,
      'rentalPeriodStart': rentalPeriodStart.toIso8601String(),
      'rentalPeriodEnd': rentalPeriodEnd.toIso8601String(),
      'status': statusString,
      'tenantId': tenantId,
      'createdAt': createdAt.toIso8601String(),
      'acceptedAt': acceptedAt?.toIso8601String(),
      'offerContract': offerContract,
      'contractPdfUrl': contractPdfUrl,
      'tenant': tenant,
    };
  }
}

class CreateOfferDto {
  final int propertyId;
  final double rentAmount;
  final double depositAmount;
  final DateTime rentalPeriodStart;
  final DateTime rentalPeriodEnd;
  final int tenantId;

  CreateOfferDto({
    required this.propertyId,
    required this.rentAmount,
    required this.depositAmount,
    required this.rentalPeriodStart,
    required this.rentalPeriodEnd,
    required this.tenantId,
  });

  Map<String, dynamic> toJson() {
    return {
      'propertyId': propertyId,
      'rentAmount': rentAmount,
      'depositAmount': depositAmount,
      'rentalPeriodStart': rentalPeriodStart.toIso8601String(),
      'rentalPeriodEnd': rentalPeriodEnd.toIso8601String(),
      'tenantId': tenantId,
    };
  }
}



