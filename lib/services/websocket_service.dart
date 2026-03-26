import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import 'dart:convert';

class WebSocketService {
  static final String serverUrl = 'wss://echo.websocket.org'; // Public test server
  // For production, use your own server: 'wss://your-server.com/ws'
  
  static WebSocketChannel? _channel;
  static final List<Function(Map<String, dynamic>)> _listeners = [];
  
  static void connect(String username) {
    _channel = IOWebSocketChannel.connect(serverUrl);
    
    _channel!.stream.listen((message) {
      try {
        final data = jsonDecode(message);
        for (var listener in _listeners) {
          listener(data);
        }
      } catch (e) {
        print('Error parsing message: $e');
      }
    }, onError: (error) {
      print('WebSocket error: $error');
    }, onDone: () {
      print('WebSocket disconnected');
    });
    
    // Send join message
    sendMessage({
      'type': 'join',
      'username': username,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }
  
  static void sendMessage(Map<String, dynamic> message) {
    if (_channel != null) {
      _channel!.sink.add(jsonEncode(message));
    }
  }
  
  static void addListener(Function(Map<String, dynamic>) listener) {
    _listeners.add(listener);
  }
  
  static void removeListener(Function(Map<String, dynamic>) listener) {
    _listeners.remove(listener);
  }
  
  static void disconnect() {
    _channel?.sink.close();
    _channel = null;
    _listeners.clear();
  }
}
