import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:miro_prototype/features/whiteboard/domain/entities/shape_element.dart';
import 'package:miro_prototype/features/whiteboard/domain/entities/text_element.dart';

class WhiteboardPainter extends CustomPainter {
  final List<Element> elements;
  final Offset offset;
  final double scale;

  WhiteboardPainter({
    required this.elements,
    required this.offset,
    required this.scale,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    // Применяем трансформацию: перемещение + масштаб
    canvas.translate(offset.dx, offset.dy);
    canvas.scale(scale);

    for (final element in elements) {
      if (element is TextElement) {
        _drawText(canvas, element as TextElement, paint);
      } else if (element is ShapeElement) {
        _drawShape(canvas, element as ShapeElement, paint);
      }
    }
  }

  void _drawText(Canvas canvas, TextElement element, Paint paint) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: element.text,
        style: TextStyle(
          color: element.color,
          fontSize: 16,
          backgroundColor: Colors.transparent,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, element.position);
  }

  void _drawShape(Canvas canvas, ShapeElement element, Paint paint) {
    paint.color = element.color;
    canvas.drawRect(
      Rect.fromLTWH(
        element.position.dx,
        element.position.dy,
        element.size.width,
        element.size.height,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
