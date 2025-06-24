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
  List<Message> _messages = [];
  User? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final user = await _authService.getCurrentUser();
    final messages = await _messageService.getMyMessages();
    setState(() {
      _currentUser = user;
      _messages = messages;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Zgrupuj wiadomości po rozmówcy (druga strona konwersacji)
    final Map<int, Message> lastMessages = {};
    for (var msg in _messages) {
      int otherUserId = msg.senderId == _currentUser?.id ? msg.receiverId : msg.senderId;
      if (!lastMessages.containsKey(otherUserId) ||
          msg.createdAt.isAfter(lastMessages[otherUserId]!.createdAt)) {
        lastMessages[otherUserId] = msg;
      }
    }
    final chatList = lastMessages.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Messages'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : chatList.isEmpty
              ? const Center(child: Text('No conversations yet.'))
              : ListView.builder(
                  itemCount: chatList.length,
                  itemBuilder: (context, index) {
                    final msg = chatList[index];
                    final isMe = msg.senderId == _currentUser?.id;
                    final otherUserId = isMe ? msg.receiverId : msg.senderId;
                    final otherUsername = isMe ? msg.receiverUsername : msg.senderUsername;
                    return ListTile(
                      leading: CircleAvatar(
                        child: Text(
                          otherUsername.isNotEmpty ? otherUsername[0].toUpperCase() : '?',
                        ),
                      ),
                      title: Text(otherUsername),
                      subtitle: Text(msg.content, maxLines: 1, overflow: TextOverflow.ellipsis),
                      trailing: Text(
                        '${msg.createdAt.hour.toString().padLeft(2, '0')}:${msg.createdAt.minute.toString().padLeft(2, '0')}',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatScreen(
                              otherUserId: otherUserId,
                              otherUsername: otherUsername,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
} 