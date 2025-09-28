// lib/features/whiteboard/presentation/widgets/whiteboard_view.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miro_prototype/features/whiteboard/presentation/providers/tool_state_provider.dart';
import 'package:miro_prototype/whiteboard_providers.dart';
import 'package:miro_prototype/features/whiteboard/domain/entities/whiteboard_element.dart';
import 'package:miro_prototype/features/whiteboard/domain/entities/text_element.dart';
import 'package:miro_prototype/features/whiteboard/domain/entities/shape_element.dart';
import 'package:miro_prototype/features/whiteboard/domain/entities/path_element.dart';

class WhiteboardView extends ConsumerStatefulWidget {
  const WhiteboardView({super.key});

  @override
  ConsumerState<WhiteboardView> createState() => _WhiteboardViewState();
}

class _WhiteboardViewState extends ConsumerState<WhiteboardView> {
  late Offset _lastFocalPoint;
  late Path _currentPath;
  late Offset _lastPoint;
  bool _isDrawing = false;

  final GlobalKey _boardKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _currentPath = Path();
  }

  @override
  Widget build(BuildContext context) {
    final camera = ref.watch(cameraProvider);
    final elements = ref.watch(elementsProvider);
    final toolState = ref.watch(toolStateProvider);

    return GestureDetector(
      key: _boardKey,
      onScaleStart: (details) {
        _lastFocalPoint = details.focalPoint;

        if (toolState.currentTool == DrawingTool.brush) {
          if (details.pointerCount == 1 && !_isDrawing) {
            _isDrawing = true;
            final localPos = _getLocalPosition(details.focalPoint, camera);
            _lastPoint = localPos;
            _currentPath = Path();
            _currentPath.moveTo(localPos.dx, localPos.dy);
            setState(() {});
          }
        }
      },
      onScaleUpdate: (details) {
        if (toolState.currentTool == DrawingTool.brush && _isDrawing) {
          final localPos = _getLocalPosition(details.focalPoint, camera);

          if (localPos.dx.isFinite && localPos.dy.isFinite) {
            _currentPath.quadraticBezierTo(
              _lastPoint.dx,
              _lastPoint.dy,
              (localPos.dx + _lastPoint.dx) / 2,
              (localPos.dy + _lastPoint.dy) / 2,
            );
            _lastPoint = localPos;
            setState(() {});
          }
        } else if (toolState.currentTool == DrawingTool.hand) {
          // Режим перемещения/масштабирования
          final newFocalPoint = details.focalPoint;
          final deltaScale = details.scale;

          final delta = (newFocalPoint - _lastFocalPoint) / camera.scale;
          final newScale = (camera.scale * deltaScale).clamp(0.2, 5.0);
          final focal = newFocalPoint;
          final oldOffset = camera.offset;
          final newOffset =
              focal - (focal - (oldOffset + delta)) * (newScale / camera.scale);

          ref.read(cameraProvider.notifier).state = CameraState(
            offset: newOffset,
            scale: newScale,
          );
        }

        _lastFocalPoint = details.focalPoint;
      },
      onScaleEnd: (details) {
        if (toolState.currentTool == DrawingTool.brush && _isDrawing) {
          if (_currentPath != Path()) {
            final metrics = _currentPath.computeMetrics();
            if (metrics.isNotEmpty) {
              addPathElement(
                ref,
                _currentPath,
                toolState.brushColor,
                toolState.strokeWidth,
              );
            }
          }
          _currentPath = Path();
          _isDrawing = false;
          setState(() {});
        }
      },
      child: CustomPaint(
        painter: _WhiteboardPainter(
          elements: elements,
          offset: camera.offset,
          scale: camera.scale,
          currentPath: Path.from(_currentPath),
          currentPathColor: toolState.brushColor,
          currentPathStrokeWidth: toolState.strokeWidth,
        ),
        size: Size.infinite,
      ),
    );
  }

  Offset _getLocalPosition(Offset globalPosition, CameraState camera) {
    final renderBox =
        _boardKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) {
      return Offset.zero;
    }

    final localPosition = renderBox.globalToLocal(globalPosition);
    final boardX = (localPosition.dx - camera.offset.dx) / camera.scale;
    final boardY = (localPosition.dy - camera.offset.dy) / camera.scale;

    return Offset(boardX, boardY);
  }
}

class _WhiteboardPainter extends CustomPainter {
  final List<WhiteboardElement> elements;
  final Offset offset;
  final double scale;
  final Path currentPath;
  final Color currentPathColor;
  final double currentPathStrokeWidth;

  _WhiteboardPainter({
    required this.elements,
    required this.offset,
    required this.scale,
    required this.currentPath,
    this.currentPathColor = Colors.black,
    this.currentPathStrokeWidth = 3.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    canvas.scale(scale);

    // 🔷 Рисуем клеточный фон
    _drawGrid(canvas, size, offset, scale);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Рисуем сохранённые элементы
    for (final element in elements) {
      if (element is TextElement) {
        _drawText(canvas, element);
      } else if (element is ShapeElement) {
        paint.color = element.color;
        paint.strokeWidth = 2.0;
        canvas.drawRect(
          Rect.fromLTWH(
            element.position.dx,
            element.position.dy,
            element.size.width,
            element.size.height,
          ),
          paint,
        );
      } else if (element is PathElement) {
        paint.color = element.color;
        paint.strokeWidth = element.strokeWidth;
        canvas.drawPath(element.path, paint);
      }
    }

    // Рисуем текущий путь (временная линия)
    if (currentPath != Path()) {
      paint.color = currentPathColor;
      paint.strokeWidth = currentPathStrokeWidth;
      canvas.drawPath(currentPath, paint);
    }

    canvas.restore();
  }

  void _drawGrid(Canvas canvas, Size size, Offset offset, double scale) {
    // Фон доски
    final backgroundPaint = Paint()..color = const Color(0xFFF8F9FA);
    canvas.drawRect(
      Rect.fromLTWH(
        -offset.dx / scale,
        -offset.dy / scale,
        size.width / scale,
        size.height / scale,
      ),
      backgroundPaint,
    );

    final gridPaint = Paint();
    const baseGridSize = 50.0;
    final gridSize = baseGridSize;

    final visibleLeft = -offset.dx / scale;
    final visibleTop = -offset.dy / scale;
    final visibleRight = visibleLeft + size.width / scale;
    final visibleBottom = visibleTop + size.height / scale;

    final startCol = (visibleLeft / gridSize).floor();
    final endCol = (visibleRight / gridSize).ceil();
    final startRow = (visibleTop / gridSize).floor();
    final endRow = (visibleBottom / gridSize).ceil();

    // Рисуем только вспомогательные линии (более субтильный стиль)
    gridPaint.color = const Color(0xFFECEFF1); // Очень светлый серо-голубой
    gridPaint.strokeWidth = 0.5;

    for (var col = startCol; col <= endCol; col++) {
      final x = col * gridSize;
      canvas.drawLine(
        Offset(x, visibleTop),
        Offset(x, visibleBottom),
        gridPaint,
      );
    }

    for (var row = startRow; row <= endRow; row++) {
      final y = row * gridSize;
      canvas.drawLine(
        Offset(visibleLeft, y),
        Offset(visibleRight, y),
        gridPaint,
      );
    }

    // Добавляем точку в центре (0,0) для ориентации
    if (visibleLeft <= 0 &&
        visibleRight >= 0 &&
        visibleTop <= 0 &&
        visibleBottom >= 0) {
      final centerPaint = Paint()..color = const Color(0xFFCFD8DC);
      canvas.drawCircle(const Offset(0, 0), 2.0, centerPaint);
    }
  }

  void _drawText(Canvas canvas, TextElement element) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: element.text,
        style: TextStyle(color: element.color, fontSize: 16),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, element.position);
  }

  @override
  bool shouldRepaint(covariant _WhiteboardPainter oldDelegate) {
    return elements != oldDelegate.elements ||
        offset != oldDelegate.offset ||
        scale != oldDelegate.scale ||
        currentPath != oldDelegate.currentPath;
  }
}
