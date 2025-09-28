// lib/config/app_config.dart

class AppConfig {
  static const String websocketHost = String.fromEnvironment(
    'WEBSOCKET_HOST',
    defaultValue: '192.168.0.2', // IP по умолчанию
  );

  static const int websocketPort = int.fromEnvironment(
    'WEBSOCKET_PORT',
    defaultValue: 8080,
  );

  static String get websocketUrl => 'ws://$websocketHost:$websocketPort/ws';
}
