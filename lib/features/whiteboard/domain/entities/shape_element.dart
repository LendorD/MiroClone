// lib/features/whiteboard/domain/entities/shape_element.dart
import 'package:flutter/material.dart';
import 'package:miro_prototype/features/whiteboard/domain/entities/whiteboard_element.dart';

@immutable
class ShapeElement extends WhiteboardElement {
  final Color color;

  const ShapeElement({
    required super.id,
    required super.position,
    this.color = Colors.blue,
    super.size = const Size(120, 80),
  });

  @override
  ShapeElement copyWith({
    String? id,
    Offset? position,
    Size? size,
    Color? color,
  }) {
    return ShapeElement(
      id: id ?? this.id,
      position: position ?? this.position,
      color: color ?? this.color,
      size: size ?? this.size,
    );
  }
}
