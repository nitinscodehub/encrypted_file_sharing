import 'dart:io';
import 'package:flutter/material.dart';
import 'package:network_info_plus/network_info_plus.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';

class IpChatScreen extends StatefulWidget {
  const IpChatScreen({super.key});

  @override
  State<IpChatScreen> createState() => _IpChatScreenState();
}

class _IpChatScreenState extends State<IpChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _ipController = TextEditingController();
  String? _myIp;
  List<Map<String, dynamic>> _messages = [];
  bool _isListening = false;
  ServerSocket? _serverSocket;

  @override
  void initState() {
    super.initState();
    _getMyIp();
    _startListening();
  }

  Future<void> _getMyIp() async {
    try {
      final info = NetworkInfo();
      _myIp = await info.getWifiIP();
    } catch (e) {
      _myIp = 'Unable to get IP';
    }
    if (mounted) setState(() {});
  }

  Future<void> _startListening() async {
    if (_isListening) return;
    _isListening = true;
    if (mounted) setState(() {});

    try {
      _serverSocket = await ServerSocket.bind(InternetAddress.anyIPv4, 8080);
      _serverSocket!.listen((Socket client) {
        client.listen((data) {
          final message = String.fromCharCodes(data);
          if (mounted) {
            setState(() {
              _messages.insert(0, {
                'text': message,
                'isSent': false,
                'timestamp': DateTime.now(),
              });
            });
            Helpers.showSnackBar(context, 'New message received!');
          }
        });
      });
    } catch (e) {
      print('Listening error: $e');
      _isListening = false;
      if (mounted) setState(() {});
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.isEmpty) {
      Helpers.showSnackBar(context, 'Enter a message');
      return;
    }
    if (_ipController.text.isEmpty) {
      Helpers.showSnackBar(context, 'Enter receiver IP');
      return;
    }

    try {
      final socket = await Socket.connect(_ipController.text, 8080, timeout: const Duration(seconds: 5));
      socket.write(_messageController.text);
      await socket.close();

      if (mounted) {
        setState(() {
          _messages.insert(0, {
            'text': _messageController.text,
            'isSent': true,
            'timestamp': DateTime.now(),
          });
          _messageController.clear();
        });
        Helpers.showSnackBar(context, 'Message sent to ${_ipController.text}');
      }
    } catch (e) {
      Helpers.showSnackBar(context, 'Failed to send: $e', isError: true);
    }
  }

  void _copyMyIp() {
    if (_myIp != null && _myIp != 'Unable to get IP') {
      Helpers.showSnackBar(context, 'IP Copied: $_myIp');
    } else {
      Helpers.showSnackBar(context, 'Unable to get IP', isError: true);
    }
  }

  @override
  void dispose() {
    _serverSocket?.close();
    _messageController.dispose();
    _ipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green.shade50, Colors.green.shade100],
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.wifi_tethering, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('YOUR IP ADDRESS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.green)),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Text(_myIp ?? 'Loading...', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(width: 10),
                          if (_myIp != null && _myIp != 'Unable to get IP')
                            GestureDetector(
                              onTap: _copyMyIp,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.green),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.copy, size: 12, color: Colors.green),
                                    SizedBox(width: 4),
                                    Text('Copy', style: TextStyle(fontSize: 10, color: Colors.green)),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text('Share this IP with friend to chat (same WiFi)', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _isListening ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _isListening ? '● Listening' : '● Not Listening',
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
              ],
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _ipController,
              decoration: const InputDecoration(
                labelText: 'Receiver IP Address',
                hintText: 'e.g., 192.168.1.100',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.computer),
              ),
            ),
          ),
          
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline, size: 50, color: Colors.grey[400]),
                        const SizedBox(height: 10),
                        Text('No messages yet', style: TextStyle(color: Colors.grey[600])),
                        const SizedBox(height: 5),
                        Text('Enter IP and send message', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                      ],
                    ),
                  )
                : ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      return Align(
                        alignment: msg['isSent'] ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.75,
                          ),
                          decoration: BoxDecoration(
                            color: msg['isSent'] ? Colors.green : Colors.grey[300],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                msg['text'],
                                style: TextStyle(
                                  color: msg['isSent'] ? Colors.white : Colors.black,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${msg['timestamp'].hour.toString().padLeft(2, '0')}:${msg['timestamp'].minute.toString().padLeft(2, '0')}',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: msg['isSent'] ? Colors.white70 : Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          
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
}
