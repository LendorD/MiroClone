// lib/features/whiteboard/domain/entities/text_element.dart
import 'package:flutter/material.dart';
import 'package:miro_prototype/features/whiteboard/domain/entities/whiteboard_element.dart';

@immutable
class TextElement extends WhiteboardElement {
  final String text;
  final Color color;

  const TextElement({
    required super.id,
    required super.position,
    this.text = 'Text',
    this.color = Colors.black,
    super.size,
  });

  @override
  TextElement copyWith({
    String? id,
    Offset? position,
    Size? size,
    String? text,
    Color? color,
  }) {
    return TextElement(
      id: id ?? this.id,
      position: position ?? this.position,
      text: text ?? this.text,
      color: color ?? this.color,
      size: size ?? this.size,
    );
  }
}
