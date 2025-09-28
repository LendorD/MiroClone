// lib/services/websocket_service.dart

import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService {
  late WebSocketChannel _channel;
  final String _serverUrl;
  final Function(dynamic message) onMessage;
  final Function() onConnect;
  final Function() onDisconnect;

  WebSocketService({
    required String ip,
    required this.onMessage,
    required this.onConnect,
    required this.onDisconnect,
  }) : _serverUrl = 'ws://192.168.0.2:8080/ws';

  void connect() {
    try {
      _channel = WebSocketChannel.connect(Uri.parse(_serverUrl));

      _channel.stream.listen(
        (message) {
          print('📡 Received from server: $message');
          final decoded = jsonDecode(message);
          onMessage(decoded);
        },
        onDone: () {
          onDisconnect();
        },
        onError: (error) {
          print('WebSocket error: $error');
          onDisconnect();
        },
      );

      onConnect();
    } catch (e) {
      print('Connection error: $e');
      onDisconnect();
    }
  }

  void sendMessage(dynamic message) {
    print('📤 Sending to server: $message');
    if (_channel != null) {
      _channel.sink.add(jsonEncode(message));
    }
  }

  void disconnect() {
    _channel.sink.close();
  }
}
