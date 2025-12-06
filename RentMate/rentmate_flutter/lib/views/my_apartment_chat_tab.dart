import 'package:flutter/material.dart';
import '../models/property.dart';
import '../models/message.dart';
import '../models/user.dart';
import '../services/message_service.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import 'tenant_profile_view.dart';

class MyApartmentChatTab extends StatefulWidget {
  final Property property;
  final User? currentUser;

  const MyApartmentChatTab({super.key, required this.property, this.currentUser});

  @override
  State<MyApartmentChatTab> createState() => _MyApartmentChatTabState();
}

class _MyApartmentChatTabState extends State<MyApartmentChatTab> {
  final _messageService = MessageService();
  final _userService = UserService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Message> _messages = [];
  Map<int, Map<String, dynamic>> _chatUsers = {};
  bool _isLoadingMessages = false;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    try {
      setState(() => _isLoadingMessages = true);
      if (widget.property.chatGroupId != null && widget.property.chatGroupId! > 0) {
        final chatId = widget.property.chatGroupId!;
        
        final result = await _messageService.getChatMessagesWithUsers(chatId);
        final messages = result['messages'] as List<Message>;
        final users = result['users'] as List<dynamic>;
        
        final Map<int, Map<String, dynamic>> usersMap = {};
        for (var user in users) {
          final userId = user['id'] is int ? user['id'] : int.tryParse(user['id']?.toString() ?? '') ?? 0;
          if (userId > 0) {
            usersMap[userId] = {
              'firstName': user['firstName']?.toString() ?? '',
              'lastName': user['lastName']?.toString() ?? '',
              'photoUrl': user['photoUrl']?.toString(),
            };
          }
        }
        
        setState(() {
          _messages = messages;
          _chatUsers = usersMap;
          _isLoadingMessages = false;
        });
        _scrollToBottom();
      } else {
        setState(() => _isLoadingMessages = false);
      }
    } catch (e) {
      setState(() => _isLoadingMessages = false);
      print('Failed to load messages: $e');
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final content = _messageController.text.trim();
    _messageController.clear();

    try {
      if (widget.property.chatGroupId == null || widget.property.chatGroupId! <= 0) {
        throw Exception('Brak ChatGroupId dla tego mieszkania');
      }
      
      final chatId = widget.property.chatGroupId!;
      await _messageService.sendGroupMessage(chatId, content);
      await _loadMessages();
      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Błąd podczas wysyłania wiadomości: $e'),
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
    if (widget.currentUser == null) return false;
    return int.tryParse(widget.currentUser!.id) == message.senderId;
  }

  Future<void> _showUserProfile(int userId) async {
    try {
      final user = await _userService.getUserById(userId);
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => TenantProfileView(
            tenant: user,
            propertyId: widget.property.id,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Błąd podczas ładowania profilu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: _isLoadingMessages
              ? const Center(child: CircularProgressIndicator())
              : _messages.isEmpty
                  ? const Center(
                      child: Text(
                        'Brak wiadomości. Zacznij rozmowę!',
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
                        
                        final senderInfo = _chatUsers[message.senderId];
                        final senderName = senderInfo != null
                            ? '${senderInfo['firstName']} ${senderInfo['lastName']}'
                            : message.senderUsername;
                        final senderPhotoUrl = senderInfo?['photoUrl'] as String?;
                        
                        final displayName = isMyMessage
                            ? (widget.currentUser != null 
                                ? '${widget.currentUser!.firstName} ${widget.currentUser!.lastName}'
                                : 'Ja')
                            : senderName;
                        final displayPhotoUrl = isMyMessage
                            ? widget.currentUser?.photoUrl
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
                                GestureDetector(
                                  onTap: () => _showUserProfile(message.senderId),
                                  child: CircleAvatar(
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
                                ),
                                const SizedBox(width: 8),
                              ],
                              Flexible(
                                child: Column(
                                  crossAxisAlignment: isMyMessage
                                      ? CrossAxisAlignment.end
                                      : CrossAxisAlignment.start,
                                  children: [
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
                                GestureDetector(
                                  onTap: () {
                                    if (widget.currentUser != null) {
                                      final currentUserId = int.tryParse(widget.currentUser!.id);
                                      if (currentUserId != null) {
                                        _showUserProfile(currentUserId);
                                      }
                                    }
                                  },
                                  child: CircleAvatar(
                                    radius: 20,
                                    backgroundColor: Colors.grey[300],
                                    backgroundImage: displayPhotoUrl != null && displayPhotoUrl.isNotEmpty
                                        ? NetworkImage('https://localhost:7281$displayPhotoUrl')
                                        : null,
                                    child: displayPhotoUrl == null || displayPhotoUrl.isEmpty
                                        ? Text(
                                            widget.currentUser?.firstName.isNotEmpty == true
                                                ? widget.currentUser!.firstName[0].toUpperCase()
                                                : '?',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          )
                                        : null,
                                  ),
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
                    hintText: 'Napisz wiadomość...',
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
    );
  }
}

