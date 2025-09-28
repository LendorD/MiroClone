// lib/whiteboard_providers.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miro_prototype/features/whiteboard/domain/entities/path_element.dart';
import 'package:miro_prototype/features/whiteboard/domain/entities/whiteboard_element.dart';
import 'package:miro_prototype/models/draw_message.dart';
import 'package:miro_prototype/services/websocket_service.dart';
import 'features/whiteboard/domain/entities/shape_element.dart';
import 'features/whiteboard/domain/entities/text_element.dart';

// --- Элементы ---
final elementsProvider = StateProvider<List<WhiteboardElement>>((ref) {
  return [
    TextElement(
      id: '1',
      position: const Offset(100, 100),
      text: 'Привет, это текст!',
    ),
    ShapeElement(
      id: '2',
      position: const Offset(300, 200),
      color: Colors.green,
    ),
  ];
});

// --- Камера ---
class CameraState {
  final Offset offset;
  final double scale;

  const CameraState({this.offset = Offset.zero, this.scale = 1.0});

  CameraState copyWith({Offset? offset, double? scale}) {
    return CameraState(
      offset: offset ?? this.offset,
      scale: scale ?? this.scale,
    );
  }
}

final cameraProvider = StateProvider<CameraState>((ref) {
  return const CameraState();
});

void addPathElement(WidgetRef ref, Path path, Color color, double strokeWidth) {
  print('Adding path element!'); // Отладка
  final id = DateTime.now().microsecondsSinceEpoch.toString();
  ref.read(elementsProvider.notifier).state = [
    ...ref.read(elementsProvider),
    PathElement(
      id: id,
      position: Offset.zero,
      path: path,
      color: color,
      strokeWidth: strokeWidth,
    ),
  ];
}

// В whiteboard_providers.dart добавь:

final websocketServiceProvider = Provider<WebSocketService>((ref) {
  return WebSocketService(
    ip: 'localhost', // Замени на IP твоего сервера
    onMessage: (message) {
      // Обработка входящих сообщений
      ref.read(elementsProvider.notifier).addRemoteMessage(message);
    },
    onConnect: () {
      print('Connected to WebSocket server');
    },
    onDisconnect: () {
      print('Disconnected from WebSocket server');
    },
  );
});

// Расширение для добавления удалённых сообщений
extension ElementsNotifier on StateController<List<WhiteboardElement>> {
  void addRemoteMessage(dynamic message) {
    print('📥 Processing remote message: $message'); // ← ДЛЯ ОТЛАДКИ

    if (message is Map<String, dynamic>) {
      final type = message['type'] as String?;

      if (type == 'draw') {
        final data = message['data'] as Map<String, dynamic>?;
        if (data != null) {
          try {
            final drawData = DrawData.fromJson(data);

            // Создаём Path из точек
            final path = Path();
            if (drawData.path.isNotEmpty) {
              path.moveTo(drawData.path[0].x, drawData.path[0].y);
              for (var i = 1; i < drawData.path.length; i++) {
                path.lineTo(drawData.path[i].x, drawData.path[i].y);
              }
            }

            state = [
              ...state,
              PathElement(
                id: DateTime.now().microsecondsSinceEpoch.toString(),
                position: Offset.zero,
                path: path,
                color: _colorFromString(drawData.color),
                strokeWidth: drawData.strokeWidth,
              ),
            ];

            print('✅ Added remote path with ${drawData.path.length} points');
          } catch (e) {
            print('❌ Error processing draw message: $e');
          }
        }
      } else if (type == 'clear') {
        state = [];
      }
    }
  }
}

Color _colorFromString(String colorStr) {
  try {
    if (colorStr.startsWith('#')) {
      return Color(int.parse(colorStr.substring(1), radix: 16));
    }
    // Fallback для именованных цветов
    if (colorStr == 'black') return Colors.black;
    if (colorStr == 'blue') return Colors.blue;
    if (colorStr == 'red') return Colors.red;
    if (colorStr == 'green') return Colors.green;
    return Colors.black;
  } catch (e) {
    print('Error parsing color $colorStr: $e');
    return Colors.black;
  }
}
