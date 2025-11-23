import 'package:flutter/foundation.dart';

class Message {
  final int id;
  final int senderId;
  final int receiverId;
  final int? chatId;
  final int? issueId;
  final String content;
  final bool isRead;
  final DateTime createdAt;
  final String senderUsername;
  final String receiverUsername;

  Message({
    required this.id,
    required this.senderId,
    this.receiverId = 0,
    this.chatId,
    this.issueId,
    required this.content,
    required this.isRead,
    required this.createdAt,
    required this.senderUsername,
    required this.receiverUsername,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      senderId: json['senderId'] is int ? json['senderId'] : int.tryParse(json['senderId']?.toString() ?? '') ?? 0,
      receiverId: json['receiverId'] is int ? json['receiverId'] : int.tryParse(json['receiverId']?.toString() ?? '0') ?? 0,
      chatId: json['chatId'] is int ? json['chatId'] : int.tryParse(json['chatId']?.toString() ?? ''),
      issueId: json['issueId'] is int ? json['issueId'] : int.tryParse(json['issueId']?.toString() ?? ''),
      content: json['content']?.toString() ?? '',
      isRead: json['isRead'] is bool ? json['isRead'] : (json['isRead']?.toString() == 'true'),
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'].toString()) : DateTime.now(),
      senderUsername: json['senderUsername']?.toString() ?? 'Unknown',
      receiverUsername: json['receiverUsername']?.toString() ?? 'Unknown',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'issueId': issueId,
      'content': content,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
      'senderUsername': senderUsername,
      'receiverUsername': receiverUsername,
    };
  }
} 