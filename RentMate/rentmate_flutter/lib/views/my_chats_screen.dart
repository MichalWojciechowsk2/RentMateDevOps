import 'package:flutter/material.dart';
import '../models/message.dart';
import '../models/user.dart';
import '../services/message_service.dart';
import '../services/auth_service.dart';
import 'chat_screen.dart';

class MyChatsScreen extends StatefulWidget {
  const MyChatsScreen({super.key});

  @override
  State<MyChatsScreen> createState() => _MyChatsScreenState();
}

class _MyChatsScreenState extends State<MyChatsScreen> {
  final MessageService _messageService = MessageService();
  final AuthService _authService = AuthService();
  List<Map<String, dynamic>> _chats = [];
  User? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final user = await _authService.getCurrentUser();
      final chats = await _messageService.getPrivateChats();
      setState(() {
        _currentUser = user;
        _chats = chats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Błąd podczas ładowania czatów: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Pobierz userId rozmówcy z czatu (musimy pobrać użytkowników z czatu)
  Future<int?> _getOtherUserIdFromChat(int chatId) async {
    try {
      final result = await _messageService.getPrivateChatMessages(chatId);
      final users = result['users'] as List<dynamic>;
      final currentUserId = int.tryParse(_currentUser?.id ?? '') ?? 0;
      
      for (var user in users) {
        final userId = user['id'] is int ? user['id'] : int.tryParse(user['id']?.toString() ?? '') ?? 0;
        if (userId > 0 && userId != currentUserId) {
          return userId;
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Sortuj czaty po dacie ostatniej wiadomości
    final sortedChats = List<Map<String, dynamic>>.from(_chats)
      ..sort((a, b) {
        final dateA = a['lastMessageCreatedAt'] as DateTime?;
        final dateB = b['lastMessageCreatedAt'] as DateTime?;
        if (dateA == null && dateB == null) return 0;
        if (dateA == null) return 1;
        if (dateB == null) return -1;
        return dateB.compareTo(dateA);
      });

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Messages'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : sortedChats.isEmpty
              ? const Center(child: Text('No conversations yet.'))
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView.builder(
                    itemCount: sortedChats.length,
                    itemBuilder: (context, index) {
                      final chat = sortedChats[index];
                      final otherUserName = chat['otherUserName'] as String;
                      final otherUserPhotoUrl = chat['otherUserPhotoUrl'] as String?;
                      final lastMessageContent = chat['lastMessageContent'] as String?;
                      final lastMessageCreatedAt = chat['lastMessageCreatedAt'] as DateTime?;
                      final chatId = chat['chatId'] as int;

                      String formatTime(DateTime? dateTime) {
                        if (dateTime == null) return '';
                        return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
                      }

                      return ListTile(
                        leading: CircleAvatar(
                          radius: 25,
                          backgroundColor: Colors.grey[300],
                          backgroundImage: otherUserPhotoUrl != null && otherUserPhotoUrl.isNotEmpty
                              ? NetworkImage('https://localhost:7281$otherUserPhotoUrl')
                              : null,
                          child: otherUserPhotoUrl == null || otherUserPhotoUrl.isEmpty
                              ? Text(
                                  otherUserName.isNotEmpty ? otherUserName[0].toUpperCase() : '?',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : null,
                        ),
                        title: Text(
                          otherUserName,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          lastMessageContent ?? 'Brak wiadomości',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Text(
                          formatTime(lastMessageCreatedAt),
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        onTap: () async {
                          // Pobierz userId rozmówcy z czatu
                          final otherUserId = await _getOtherUserIdFromChat(chatId);
                          if (otherUserId != null) {
                            if (mounted) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatScreen(
                                    otherUserId: otherUserId,
                                    otherUsername: otherUserName,
                                  ),
                                ),
                              ).then((_) {
                                // Odśwież listę czatów po powrocie
                                _loadData();
                              });
                            }
                          } else {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Nie można otworzyć czatu'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                      );
                    },
                  ),
                ),
    );
  }
} 