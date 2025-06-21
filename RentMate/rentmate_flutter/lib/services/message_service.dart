import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/message.dart';
import 'auth_service.dart';

class MessageService {
  static const String baseUrl = 'https://localhost:7281/api';
  final AuthService _authService = AuthService();

  Future<List<Message>> getConversation(int otherUserId) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('No authentication token');

      final response = await http.get(
        Uri.parse('$baseUrl/Message/conversation?otherUserId=$otherUserId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Message.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load conversation: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting conversation: $e');
    }
  }

  Future<Message> sendMessage(int receiverId, String content) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('No authentication token');

      print('Wysyłam wiadomość: receiverId=$receiverId, content=$content');

      final response = await http.post(
        Uri.parse('$baseUrl/Message/send'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'receiverId': receiverId,
          'content': content,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Message.fromJson(data);
      } else {
        throw Exception('Failed to send message: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error sending message: $e');
    }
  }

  Future<List<Message>> getMyMessages() async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('No authentication token');

      final response = await http.get(
        Uri.parse('$baseUrl/Message/my-messages'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Message.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load messages: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting messages: $e');
    }
  }
} 