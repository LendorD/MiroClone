// lib/whiteboard_providers.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miro_prototype/features/whiteboard/domain/entities/path_element.dart';
import 'package:miro_prototype/features/whiteboard/domain/entities/whiteboard_element.dart';
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
