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

  // Pobierz wiadomości z czatu grupowego oraz listę użytkowników
  Future<Map<String, dynamic>> getChatMessagesWithUsers(int chatId) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('No authentication token');

      final response = await http.get(
        Uri.parse('$baseUrl/Message/chat?chatId=$chatId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // ChatWithContentDto zawiera Messages i Users
        List<Message> messages = [];
        List<dynamic> users = [];
        
        if (data is Map) {
          // Pobierz wiadomości
          if (data.containsKey('messages')) {
            messages = (data['messages'] as List).map((json) => Message.fromJson(json)).toList();
          } else if (data.containsKey('Messages')) {
            messages = (data['Messages'] as List).map((json) => Message.fromJson(json)).toList();
          }
          
          // Pobierz użytkowników
          if (data.containsKey('users')) {
            users = data['users'] as List;
          } else if (data.containsKey('Users')) {
            users = data['Users'] as List;
          }
        }
        
        return {
          'messages': messages,
          'users': users,
        };
      } else {
        throw Exception('Failed to load chat messages: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting chat messages: $e');
    }
  }

  // Pobierz wiadomości z czatu grupowego (tylko dla kompatybilności wstecznej)
  Future<List<Message>> getChatMessages(int chatId) async {
    try {
      final result = await getChatMessagesWithUsers(chatId);
      return result['messages'] as List<Message>;
    } catch (e) {
      throw Exception('Error getting chat messages: $e');
    }
  }

  // Wyślij wiadomość do czatu grupowego
  Future<Message> sendGroupMessage(int chatId, String content) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('No authentication token');

      final response = await http.post(
        Uri.parse('$baseUrl/Message/send'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'chatId': chatId,
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
      throw Exception('Error sending group message: $e');
    }
  }

  // Utwórz prywatny czat z innym użytkownikiem
  Future<Map<String, dynamic>> createPrivateChat(int otherUserId) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('No authentication token');

      final response = await http.post(
        Uri.parse('$baseUrl/Chat/privateChat?otherUserId=$otherUserId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'chatId': data['id'] is int ? data['id'] : int.tryParse(data['id']?.toString() ?? '') ?? 0,
        };
      } else {
        throw Exception('Failed to create private chat: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating private chat: $e');
    }
  }

  // Pobierz wiadomości z prywatnego czatu (używając chatId)
  Future<Map<String, dynamic>> getPrivateChatMessages(int chatId) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('No authentication token');

      final response = await http.get(
        Uri.parse('$baseUrl/Message/chat?chatId=$chatId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // ChatWithContentDto zawiera Messages i Users
        List<Message> messages = [];
        List<dynamic> users = [];
        
        if (data is Map) {
          // Pobierz wiadomości
          if (data.containsKey('messages')) {
            messages = (data['messages'] as List).map((json) => Message.fromJson(json)).toList();
          } else if (data.containsKey('Messages')) {
            messages = (data['Messages'] as List).map((json) => Message.fromJson(json)).toList();
          }
          
          // Pobierz użytkowników
          if (data.containsKey('users')) {
            users = data['users'] as List;
          } else if (data.containsKey('Users')) {
            users = data['Users'] as List;
          }
        }
        
        return {
          'messages': messages,
          'users': users,
        };
      } else {
        throw Exception('Failed to load chat messages: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting private chat messages: $e');
    }
  }

  // Wyślij wiadomość do prywatnego czatu (używając chatId)
  Future<Message> sendPrivateMessage(int chatId, String content) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('No authentication token');

      final response = await http.post(
        Uri.parse('$baseUrl/Message/send'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'chatId': chatId,
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
      throw Exception('Error sending private message: $e');
    }
  }

  // Pobierz listę prywatnych czatów użytkownika
  Future<List<Map<String, dynamic>>> getPrivateChats() async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('No authentication token');

      final response = await http.get(
        Uri.parse('$baseUrl/Chat/activeUserChats'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map<Map<String, dynamic>>((chat) {
          return {
            'chatId': chat['chatId'] is int ? chat['chatId'] : int.tryParse(chat['chatId']?.toString() ?? '') ?? 0,
            'otherUserName': chat['otherUserName']?.toString() ?? 'Unknown',
            'otherUserPhotoUrl': chat['otherUserPhotoUrl']?.toString(),
            'lastMessageContent': chat['lastMessageContent']?.toString(),
            'lastMessageCreatedAt': chat['lastMessageCreatedAt'] != null 
                ? DateTime.parse(chat['lastMessageCreatedAt'].toString())
                : null,
          };
        }).toList();
      } else {
        throw Exception('Failed to load private chats: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting private chats: $e');
    }
  }

  // Pobierz liczbę nieprzeczytanych wiadomości
  Future<int> getUnreadMessagesCount() async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('No authentication token');

      final response = await http.get(
        Uri.parse('$baseUrl/Message/unread-count'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data is int ? data : int.tryParse(data.toString()) ?? 0;
      } else {
        return 0;
      }
    } catch (e) {
      return 0;
    }
  }

  // Oznacz wiadomości w czacie jako przeczytane
  Future<void> markMessagesAsRead(int chatId) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('No authentication token');

      await http.post(
        Uri.parse('$baseUrl/Message/mark-as-read?chatId=$chatId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
    } catch (e) {
      // Ignoruj błędy przy oznaczaniu wiadomości jako przeczytane
    }
  }
} 