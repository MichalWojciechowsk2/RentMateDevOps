import 'package:flutter/material.dart';
import '../models/message.dart';
import '../models/user.dart';
import '../services/message_service.dart';
import '../services/auth_service.dart';

class ChatScreen extends StatefulWidget {
  final int otherUserId;
  final String otherUsername;

  const ChatScreen({
    super.key,
    required this.otherUserId,
    required this.otherUsername,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final MessageService _messageService = MessageService();
  final AuthService _authService = AuthService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Message> _messages = [];
  Map<int, Map<String, dynamic>> _chatUsers = {}; // Map userId -> user data (firstName, lastName, photoUrl)
  int? _chatId;
  bool _isLoading = true;
  User? _currentUser;
  String _otherUserName = ''; // Imię i nazwisko rozmówcy

  @override
  void initState() {
    super.initState();
    _initChat();
  }

  Future<void> _initChat() async {
    await _loadCurrentUser();
    await _loadMessages();
  }

  Future<void> _loadCurrentUser() async {
    final user = await _authService.getCurrentUser();
    setState(() {
      _currentUser = user;
    });
  }

  Future<void> _loadMessages() async {
    try {
      setState(() => _isLoading = true);
      
      // Najpierw utwórz lub pobierz prywatny czat
      final chatData = await _messageService.createPrivateChat(widget.otherUserId);
      final chatId = chatData['chatId'] as int;
      _chatId = chatId;
      
      // Następnie pobierz wiadomości oraz użytkowników z czatu
      final result = await _messageService.getPrivateChatMessages(chatId);
      final messages = result['messages'] as List<Message>;
      final users = result['users'] as List<dynamic>;
      
      // Utwórz mapę użytkowników (userId -> user data)
      final Map<int, Map<String, dynamic>> usersMap = {};
      final currentUserId = int.tryParse(_currentUser?.id ?? '') ?? 0;
      String otherUserName = widget.otherUsername;
      
      for (var user in users) {
        final userId = user['id'] is int ? user['id'] : int.tryParse(user['id']?.toString() ?? '') ?? 0;
        if (userId > 0) {
          final firstName = user['firstName']?.toString() ?? '';
          final lastName = user['lastName']?.toString() ?? '';
          usersMap[userId] = {
            'firstName': firstName,
            'lastName': lastName,
            'photoUrl': user['photoUrl']?.toString(),
          };
          
          // Jeśli to nie jest aktualny użytkownik, ustaw imię i nazwisko rozmówcy
          if (userId != currentUserId && firstName.isNotEmpty) {
            otherUserName = '$firstName $lastName';
          }
        }
      }
      
      setState(() {
        _messages = messages;
        _chatUsers = usersMap;
        _otherUserName = otherUserName;
        _isLoading = false;
      });
      
      // Oznacz wiadomości jako przeczytane po załadowaniu czatu
      if (chatId > 0) {
        await _messageService.markMessagesAsRead(chatId);
      }
      
      _scrollToBottom();
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load messages: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty || _chatId == null) return;

    final content = _messageController.text.trim();
    _messageController.clear();

    try {
      // Wyślij wiadomość do prywatnego czatu używając chatId
      await _messageService.sendPrivateMessage(_chatId!, content);

      // Po wysłaniu wiadomości, odśwież listę wiadomości, aby upewnić się, że mamy aktualne dane
      await _loadMessages();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send message: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  bool _isMyMessage(Message message) {
    if (_currentUser == null) return false;
    return int.tryParse(_currentUser!.id) == message.senderId;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_otherUserName.isNotEmpty ? _otherUserName : widget.otherUsername),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                    ? const Center(
                        child: Text(
                          'No messages yet. Start the conversation!',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final message = _messages[index];
                          final isMyMessage = _isMyMessage(message);
                          
                          // Pobierz informacje o nadawcy z mapy użytkowników
                          final senderInfo = _chatUsers[message.senderId];
                          final senderName = senderInfo != null
                              ? '${senderInfo['firstName']} ${senderInfo['lastName']}'
                              : message.senderUsername;
                          final senderPhotoUrl = senderInfo?['photoUrl'] as String?;
                          
                          // Dla moich wiadomości używaj danych z _currentUser
                          final displayName = isMyMessage
                              ? (_currentUser != null 
                                  ? '${_currentUser!.firstName} ${_currentUser!.lastName}'
                                  : 'Ja')
                              : senderName;
                          final displayPhotoUrl = isMyMessage
                              ? _currentUser?.photoUrl
                              : senderPhotoUrl;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              mainAxisAlignment: isMyMessage
                                  ? MainAxisAlignment.end
                                  : MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (!isMyMessage) ...[
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundColor: Colors.grey[300],
                                    backgroundImage: displayPhotoUrl != null && displayPhotoUrl.isNotEmpty
                                        ? NetworkImage('https://localhost:7281$displayPhotoUrl')
                                        : null,
                                    child: displayPhotoUrl == null || displayPhotoUrl.isEmpty
                                        ? (senderName.isNotEmpty
                                            ? Text(
                                                senderName[0].toUpperCase(),
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              )
                                            : const Icon(Icons.person, size: 16))
                                        : null,
                                  ),
                                  const SizedBox(width: 8),
                                ],
                                Flexible(
                                  child: Column(
                                    crossAxisAlignment: isMyMessage
                                        ? CrossAxisAlignment.end
                                        : CrossAxisAlignment.start,
                                    children: [
                                      // Imię i nazwisko nadawcy (tylko dla wiadomości innych użytkowników)
                                      if (!isMyMessage) ...[
                                        Padding(
                                          padding: const EdgeInsets.only(left: 8, bottom: 4),
                                          child: Text(
                                            displayName,
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                        ),
                                      ],
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 10,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isMyMessage
                                              ? Theme.of(context).primaryColor
                                              : Colors.grey[200],
                                          borderRadius: BorderRadius.only(
                                            topLeft: const Radius.circular(20),
                                            topRight: const Radius.circular(20),
                                            bottomLeft: isMyMessage
                                                ? const Radius.circular(20)
                                                : const Radius.circular(4),
                                            bottomRight: isMyMessage
                                                ? const Radius.circular(4)
                                                : const Radius.circular(20),
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: isMyMessage
                                              ? CrossAxisAlignment.end
                                              : CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              message.content,
                                              style: TextStyle(
                                                color: isMyMessage
                                                    ? Colors.white
                                                    : Colors.black,
                                                fontSize: 16,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              _formatTime(message.createdAt),
                                              style: TextStyle(
                                                color: isMyMessage
                                                    ? Colors.white70
                                                    : Colors.grey[600],
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Imię i nazwisko nadawcy (dla moich wiadomości)
                                      if (isMyMessage) ...[
                                        Padding(
                                          padding: const EdgeInsets.only(right: 8, top: 4),
                                          child: Text(
                                            displayName,
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                if (isMyMessage) ...[
                                  const SizedBox(width: 8),
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundColor: Colors.grey[300],
                                    backgroundImage: displayPhotoUrl != null && displayPhotoUrl.isNotEmpty
                                        ? NetworkImage('https://localhost:7281$displayPhotoUrl')
                                        : null,
                                    child: displayPhotoUrl == null || displayPhotoUrl.isEmpty
                                        ? Text(
                                            _currentUser?.firstName.isNotEmpty == true
                                                ? _currentUser!.firstName[0].toUpperCase()
                                                : '?',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          )
                                        : null,
                                  ),
                                ],
                              ],
                            ),
                          );
                        },
                      ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(25)),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _sendMessage,
                  icon: const Icon(Icons.send),
                  color: Theme.of(context).primaryColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
} 