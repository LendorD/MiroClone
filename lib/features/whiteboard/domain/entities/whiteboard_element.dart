// lib/features/whiteboard/domain/entities/whiteboard_element.dart
import 'dart:ui';

import 'package:flutter/foundation.dart';

@immutable
abstract class WhiteboardElement {
  final String id;
  final Offset position;
  final Size size;

  const WhiteboardElement({
    required this.id,
    required this.position,
    this.size = const Size(100, 100),
  });

  WhiteboardElement copyWith({String? id, Offset? position, Size? size});
}
