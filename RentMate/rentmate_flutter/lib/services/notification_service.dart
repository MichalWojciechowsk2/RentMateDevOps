import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/notification.dart';
import 'auth_service.dart';

class NotificationService {
  final String _baseUrl = 'https://localhost:7281/api';
  final AuthService _authService = AuthService();

  Future<List<Notification>> getNotifications() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/Notification'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _authService.getToken()}',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Notification.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load notifications: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to load notifications: $e');
    }
  }

  Future<void> markAsRead(int notificationId) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/Notification/$notificationId/read'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _authService.getToken()}',
        },
      );

      if (response.statusCode != 204 && response.statusCode != 200) {
        throw Exception('Failed to mark notification as read: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to mark notification as read: $e');
    }
  }

  Future<int> getUnreadCount() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/Notification/countUnreadNotification'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _authService.getToken()}',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data is int ? data : (data['count'] ?? 0);
      } else {
        return 0;
      }
    } catch (e) {
      return 0;
    }
  }
}


