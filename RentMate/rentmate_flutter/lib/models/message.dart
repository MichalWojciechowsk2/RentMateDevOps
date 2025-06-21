import 'package:flutter/foundation.dart';

class Message {
  final int id;
  final int senderId;
  final int receiverId;
  final int? issueId;
  final String content;
  final bool isRead;
  final DateTime createdAt;
  final String senderUsername;
  final String receiverUsername;

  Message({
    required this.id,
    required this.senderId,
    required this.receiverId,
    this.issueId,
    required this.content,
    required this.isRead,
    required this.createdAt,
    required this.senderUsername,
    required this.receiverUsername,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      senderId: json['senderId'],
      receiverId: json['receiverId'],
      issueId: json['issueId'],
      content: json['content'],
      isRead: json['isRead'],
      createdAt: DateTime.parse(json['createdAt']),
      senderUsername: json['senderUsername'] ?? 'Unknown',
      receiverUsername: json['receiverUsername'] ?? 'Unknown',
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