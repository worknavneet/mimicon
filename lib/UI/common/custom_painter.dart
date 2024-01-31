import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class MyCustomPainter extends CustomPainter {
  final Point<int> pointToColor;
  final Color color;
  final double circleRadius;


  MyCustomPainter({required this.pointToColor, required this.color,required this.circleRadius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    canvas.drawCircle(Offset(pointToColor.x.toDouble(), pointToColor.y.toDouble()), circleRadius, paint);
  }

  @override
  bool shouldRepaint(MyCustomPainter oldDelegate) =>
      oldDelegate.pointToColor != pointToColor || oldDelegate.color != color;
}

class MouthPainter extends CustomPainter {
  final Point<int> pointToColor;
  final Color color;
  final double circleRadius;

  MouthPainter({required this.pointToColor, required this.color,required this.circleRadius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    canvas.drawOval(Rect.fromCenter(center: Offset(pointToColor.x.toDouble(), pointToColor.y.toDouble()), width: circleRadius*4,height: 40), paint);
  }

  @override
  bool shouldRepaint(MouthPainter oldDelegate) =>
      oldDelegate.pointToColor != pointToColor || oldDelegate.color != color;
}


