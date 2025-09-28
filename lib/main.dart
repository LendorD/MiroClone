// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miro_prototype/whiteboard_providers.dart';
import 'features/whiteboard/presentation/widgets/whiteboard_view.dart';
import 'features/whiteboard/presentation/widgets/toolbar.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Miro Clone',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              const WhiteboardView(),
              Positioned(
                top: 16,
                left: 0,
                right: 0,
                child: Center(
                  child: WhiteboardToolbar(
                    onClear: () {
                      // Очистка доски
                      ref.read(elementsProvider.notifier).state = [];
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
