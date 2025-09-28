// lib/features/whiteboard/presentation/widgets/toolbar.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miro_prototype/features/whiteboard/presentation/providers/tool_state_provider.dart';

class WhiteboardToolbar extends ConsumerWidget {
  final VoidCallback onClear;

  const WhiteboardToolbar({super.key, required this.onClear});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final toolState = ref.watch(toolStateProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Инструменты
          _ToolButton(
            icon: Icons.pan_tool_outlined,
            tooltip: 'Перемещать',
            isActive: toolState.currentTool == DrawingTool.hand,
            onPressed: () =>
                ref.read(toolStateProvider.notifier).setTool(DrawingTool.hand),
          ),
          const SizedBox(width: 8),
          _ToolButton(
            icon: Icons.brush_outlined,
            tooltip: 'Кисть',
            isActive: toolState.currentTool == DrawingTool.brush,
            onPressed: () =>
                ref.read(toolStateProvider.notifier).setTool(DrawingTool.brush),
          ),
          const SizedBox(width: 8),
          _ToolButton(
            icon: Icons.text_fields,
            tooltip: 'Текст',
            isActive: toolState.currentTool == DrawingTool.text,
            onPressed: () =>
                ref.read(toolStateProvider.notifier).setTool(DrawingTool.text),
          ),
          const SizedBox(width: 8),
          _ToolButton(
            icon: Icons.rectangle_outlined,
            tooltip: 'Фигура',
            isActive: toolState.currentTool == DrawingTool.shape,
            onPressed: () =>
                ref.read(toolStateProvider.notifier).setTool(DrawingTool.shape),
          ),
          const SizedBox(width: 24),

          // Цвет кисти
          _ColorSelector(ref: ref),
          const SizedBox(width: 16),

          // Толщина кисти
          _StrokeWidthSelector(ref: ref),
          const SizedBox(width: 24),

          // Кнопка очистки
          _ClearButton(onClear: onClear),
        ],
      ),
    );
  }
}

class _ToolButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final bool isActive;
  final VoidCallback onPressed;

  const _ToolButton({
    required this.icon,
    required this.tooltip,
    required this.isActive,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onPressed,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isActive
                  ? Colors.blue.withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: isActive ? Colors.blue : Colors.grey[600],
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}

class _ColorSelector extends ConsumerWidget {
  final WidgetRef ref;

  const _ColorSelector({required this.ref});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentColor = ref.watch(
      toolStateProvider.select((state) => state.brushColor),
    );

    return Row(
      children: [
        const Text('Цвет:', style: TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(width: 8),
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: currentColor,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.grey.withOpacity(0.3), width: 1),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: () => _showColorPicker(context, ref),
          icon: const Icon(Icons.arrow_drop_down, size: 20, color: Colors.grey),
        ),
      ],
    );
  }

  void _showColorPicker(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return _ColorPickerSheet(ref: ref);
      },
    );
  }
}

class _ColorPickerSheet extends ConsumerWidget {
  final WidgetRef ref;

  const _ColorPickerSheet({required this.ref});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentColor = ref.watch(
      toolStateProvider.select((state) => state.brushColor),
    );

    final colors = [
      Colors.black,
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.purple,
      Colors.orange,
      Colors.pink,
      Colors.brown,
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Выберите цвет',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final color in colors)
                GestureDetector(
                  onTap: () {
                    ref.read(toolStateProvider.notifier).setBrushColor(color);
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: color == currentColor
                            ? Colors.blue
                            : Colors.transparent,
                        width: color == currentColor ? 2 : 0,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Готово'),
          ),
        ],
      ),
    );
  }
}

class _StrokeWidthSelector extends ConsumerWidget {
  final WidgetRef ref;

  const _StrokeWidthSelector({required this.ref});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strokeWidth = ref.watch(
      toolStateProvider.select((state) => state.strokeWidth),
    );

    return Row(
      children: [
        const Text(
          'Толщина:',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(width: 8),
        Container(
          width: 40,
          height: 24,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.withOpacity(0.3), width: 1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Center(
            child: Text(
              strokeWidth.toInt().toString(),
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: () => _showStrokeWidthPicker(context, ref),
          icon: const Icon(Icons.arrow_drop_down, size: 20, color: Colors.grey),
        ),
      ],
    );
  }

  void _showStrokeWidthPicker(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return _StrokeWidthPickerSheet(ref: ref);
      },
    );
  }
}

class _StrokeWidthPickerSheet extends ConsumerWidget {
  final WidgetRef ref;

  const _StrokeWidthPickerSheet({required this.ref});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentWidth = ref.watch(
      toolStateProvider.select((state) => state.strokeWidth),
    );

    final widths = [1.0, 2.0, 3.0, 5.0, 8.0, 12.0];

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Толщина линии',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final width in widths)
                GestureDetector(
                  onTap: () {
                    ref.read(toolStateProvider.notifier).setStrokeWidth(width);
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: 50,
                    height: 30,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: width == currentWidth
                            ? Colors.blue
                            : Colors.grey.withOpacity(0.3),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Center(
                      child: Text(
                        width.toInt().toString(),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Готово'),
          ),
        ],
      ),
    );
  }
}

class _ClearButton extends StatelessWidget {
  final VoidCallback onClear;

  const _ClearButton({required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Очистить доску',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onClear,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.delete_outline,
              color: Colors.red,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}
