// lib/features/whiteboard/domain/entities/path_element.dart

import 'dart:ui';
import 'package:flutter/foundation.dart'; // ← foundation, не material!
import 'whiteboard_element.dart';

@immutable
class PathElement extends WhiteboardElement {
  final Path path;
  final Color color;
  final double strokeWidth;

  const PathElement({
    required super.id,
    required super.position,
    required this.path,
    this.color = const Color(0xFF000000),
    this.strokeWidth = 3.0,
    super.size = const Size(0, 0),
  });

  // ✅ Обязательная реализация абстрактного метода
  @override
  PathElement copyWith({String? id, Offset? position, Size? size}) {
    return PathElement(
      id: id ?? this.id,
      position: position ?? this.position,
      path: path,
      color: color,
      strokeWidth: strokeWidth,
      size: size ?? this.size,
    );
  }

  // ✅ Дополнительный удобный метод (не override!)
  PathElement copyWithPath({
    String? id,
    Offset? position,
    Path? path,
    Color? color,
    double? strokeWidth,
    Size? size,
  }) {
    return PathElement(
      id: id ?? this.id,
      position: position ?? this.position,
      path: path ?? this.path,
      color: color ?? this.color,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      size: size ?? this.size,
    );
  }
}
