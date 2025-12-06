enum NotificationType {
  sendOffer,
  acceptOffer,
  declineOffer,
  createPayment,
  paymentDue,
  invitationAccepted,
  createIssue,
  other,
}

class Notification {
  final int id;
  final int senderId;
  final int receiverId;
  final String title;
  final String message;
  final DateTime createdAt;
  final bool isRead;
  final NotificationType type;
  final Map<String, dynamic>? sender;
  final Map<String, dynamic>? receiver;

  Notification({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.title,
    required this.message,
    required this.createdAt,
    required this.isRead,
    required this.type,
    this.sender,
    this.receiver,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    NotificationType type;
    final typeValue = json['type'] is int ? json['type'] : int.tryParse(json['type']?.toString() ?? '0') ?? 0;
    switch (typeValue) {
      case 0:
        type = NotificationType.sendOffer;
        break;
      case 1:
        type = NotificationType.acceptOffer;
        break;
      case 2:
        type = NotificationType.declineOffer;
        break;
      case 3:
        type = NotificationType.createPayment;
        break;
      case 4:
        type = NotificationType.paymentDue;
        break;
      case 5:
        type = NotificationType.invitationAccepted;
        break;
      case 6:
        type = NotificationType.createIssue;
        break;
      default:
        type = NotificationType.other;
    }

    return Notification(
      id: json['id'] is int ? json['id'] ?? 0 : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      senderId: json['senderId'] is int ? json['senderId'] ?? 0 : int.tryParse(json['senderId']?.toString() ?? '') ?? 0,
      receiverId: json['receiverId'] is int ? json['receiverId'] ?? 0 : int.tryParse(json['receiverId']?.toString() ?? '') ?? 0,
      title: json['title']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
      isRead: json['isRead'] ?? false,
      type: type,
      sender: json['sender'],
      receiver: json['receiver'],
    );
  }

  Map<String, dynamic> toJson() {
    int typeValue;
    switch (type) {
      case NotificationType.sendOffer:
        typeValue = 0;
        break;
      case NotificationType.acceptOffer:
        typeValue = 1;
        break;
      case NotificationType.declineOffer:
        typeValue = 2;
        break;
      case NotificationType.createPayment:
        typeValue = 3;
        break;
      case NotificationType.paymentDue:
        typeValue = 4;
        break;
      case NotificationType.invitationAccepted:
        typeValue = 5;
        break;
      case NotificationType.createIssue:
        typeValue = 6;
        break;
      default:
        typeValue = 7;
    }

    return {
      'id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'title': title,
      'message': message,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
      'type': typeValue,
      'sender': sender,
      'receiver': receiver,
    };
  }
}


