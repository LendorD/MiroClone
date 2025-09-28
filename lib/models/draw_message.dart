// lib/models/draw_message.dart

class DrawMessage {
  final String type;
  final DrawData data;
  final DateTime timestamp;

  DrawMessage({
    required this.type,
    required this.data,
    required this.timestamp,
  });

  factory DrawMessage.fromJson(Map<String, dynamic> json) {
    return DrawMessage(
      type: json['type'],
      data: DrawData.fromJson(json['data']),
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'data': data.toJson(),
      'timestamp': timestamp.toUtc().toIso8601String(),
    };
  }
}

class DrawData {
  final List<Point> path;
  final String color;
  final double strokeWidth;

  DrawData({
    required this.path,
    required this.color,
    required this.strokeWidth,
  });

  factory DrawData.fromJson(Map<String, dynamic> json) {
    final path = (json['path'] as List)
        .map((p) => Point.fromJson(p as Map<String, dynamic>))
        .toList();
    return DrawData(
      path: path,
      color: json['color'],
      strokeWidth: json['strokeWidth'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'path': path.map((p) => p.toJson()).toList(),
      'color': color,
      'strokeWidth': strokeWidth,
    };
  }
}

class Point {
  final double x;
  final double y;

  Point(this.x, this.y);

  factory Point.fromJson(Map<String, dynamic> json) {
    return Point(json['x'].toDouble(), json['y'].toDouble());
  }

  Map<String, dynamic> toJson() {
    return {'x': x, 'y': y};
  }
}
