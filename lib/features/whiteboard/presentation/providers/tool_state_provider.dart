// lib/features/whiteboard/presentation/providers/tool_state_provider.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum DrawingTool { hand, brush, text, shape }

class ToolState {
  final DrawingTool currentTool;
  final Color brushColor;
  final double strokeWidth;

  const ToolState({
    this.currentTool = DrawingTool.hand,
    this.brushColor = Colors.black,
    this.strokeWidth = 3.0,
  });

  ToolState copyWith({
    DrawingTool? currentTool,
    Color? brushColor,
    double? strokeWidth,
  }) {
    return ToolState(
      currentTool: currentTool ?? this.currentTool,
      brushColor: brushColor ?? this.brushColor,
      strokeWidth: strokeWidth ?? this.strokeWidth,
    );
  }
}

final toolStateProvider = StateProvider<ToolState>((ref) {
  return const ToolState();
});

// Методы для изменения состояния
extension ToolStateNotifier on StateController<ToolState> {
  void setTool(DrawingTool tool) {
    state = state.copyWith(currentTool: tool);
  }

  void setBrushColor(Color color) {
    state = state.copyWith(brushColor: color);
  }

  void setStrokeWidth(double width) {
    state = state.copyWith(strokeWidth: width);
  }
}
