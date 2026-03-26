import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/websocket_service.dart';
import '../utils/helpers.dart';
import '../utils/constants.dart';

class GlobalChatScreen extends StatefulWidget {
  const GlobalChatScreen({super.key});

  @override
  State<GlobalChatScreen> createState() => _GlobalChatScreenState();
}

class _GlobalChatScreenState extends State<GlobalChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  List<Map<String, dynamic>> _messages = [];
  bool _isConnected = false;
  String _roomId = '';
  
  @override
  void initState() {
    super.initState();
    _loadUsername();
    WebSocketService.addListener(_onMessageReceived);
  }
  
  void _loadUsername() async {
    // Load saved username
    _usernameController.text = 'User${DateTime.now().millisecondsSinceEpoch % 10000}';
  }
  
  void _onMessageReceived(Map<String, dynamic> message) {
    setState(() {
      _messages.insert(0, message);
      if (_messages.length > 100) {
        _messages.removeLast();
      }
    });
  }
  
  void _connect() {
    if (_usernameController.text.trim().isEmpty) {
      Helpers.showSnackBar(context, 'Enter username');
      return;
    }
    
    setState(() {
      _isConnected = true;
      _roomId = _usernameController.text;
    });
    
    WebSocketService.connect(_usernameController.text);
    Helpers.showSnackBar(context, 'Connected to global chat!');
  }
  
  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;
    
    final message = {
      'type': 'message',
      'username': _usernameController.text,
      'text': _messageController.text,
      'timestamp': DateTime.now().toIso8601String(),
    };
    
    WebSocketService.sendMessage(message);
    _messageController.clear();
  }
  
  void _disconnect() {
    WebSocketService.disconnect();
    setState(() {
      _isConnected = false;
      _messages.clear();
    });
    Helpers.showSnackBar(context, 'Disconnected');
  }
  
  @override
  void dispose() {
    WebSocketService.removeListener(_onMessageReceived);
    WebSocketService.disconnect();
    _messageController.dispose();
    _usernameController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Global Chat 🌍'),
        backgroundColor: AppColors.primaryColor,
        actions: [
          if (_isConnected)
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              onPressed: _disconnect,
            ),
        ],
      ),
      body: Column(
        children: [
          // Connection Panel
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: _isConnected
                ? Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Connected to Global Chat', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text('Chatting as: ${_usernameController.text}', style: const TextStyle(fontSize: 12)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text('Online', style: TextStyle(color: Colors.white, fontSize: 12)),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _usernameController,
                          decoration: const InputDecoration(
                            labelText: 'Username',
                            hintText: 'Enter your name',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.person),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton.icon(
                        onPressed: _connect,
                        icon: const Icon(Icons.wifi),
                        label: const Text('Connect'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        ),
                      ),
                    ],
                  ),
          ),
          
          // Chat Messages
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline, size: 60, color: Colors.grey[400]),
                        const SizedBox(height: 20),
                        Text(
                          _isConnected ? 'No messages yet\nBe the first to say something!' : 'Connect to start chatting',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      final isMe = msg['username'] == _usernameController.text;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (!isMe)
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: Colors.grey[300],
                                child: Text(
                                  msg['username']?.substring(0, 1).toUpperCase() ?? '?',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isMe ? Colors.green : Colors.grey[300],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (!isMe)
                                      Text(
                                        msg['username'] ?? 'Unknown',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    const SizedBox(height: 4),
                                    Text(
                                      msg['text'] ?? '',
                                      style: TextStyle(
                                        color: isMe ? Colors.white : Colors.black,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _formatTime(msg['timestamp']),
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: isMe ? Colors.white70 : Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          
          // Message Input
          if (_isConnected)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: 'Type your message...',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: null,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _sendMessage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(16),
                    ),
                    child: const Icon(Icons.send, color: Colors.white),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
  
  String _formatTime(String? timestamp) {
    if (timestamp == null) return '';
    try {
      final time = DateTime.parse(timestamp);
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return '';
    }
  }
}
