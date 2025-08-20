import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_task/features/lighting/domain/effect_type.dart';

class HouseWithLights extends StatelessWidget {
  const HouseWithLights({super.key, required this.effectType, required this.tick, this.imageAsset = 'assets/house.png'});

  final EffectType effectType;
  final int tick;
  final String imageAsset;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          fit: StackFit.expand,
          children: [
            // House background image (user-provided asset). If missing, nothing will show.
            Image.asset(
              imageAsset,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
            CustomPaint(
              painter: _HousePainter(effectType: effectType, tick: tick),
              child: const SizedBox.expand(),
            ),
          ],
        );
      },
    );
  }
}

class _HousePainter extends CustomPainter {
  _HousePainter({required this.effectType, required this.tick});

  final EffectType effectType;
  final int tick;

  @override
  void paint(Canvas canvas, Size size) {
    // If the house image is used as background, we only draw the LED stroke and bulbs.
    // Otherwise, the area is empty and you will only see LEDs.

    // Normalized path traced to match the provided house image's eaves.
    final List<Offset> points = [
      const Offset(0.140, 0.355), // far left start of left eave
      const Offset(0.425, 0.355), // end of left eave
      const Offset(0.545, 0.305), // small ramp
      const Offset(0.610, 0.265), // up to apex
      const Offset(0.695, 0.335), // down right gable
      const Offset(0.855, 0.335), // short right eave
    ].map((e) => Offset(e.dx * size.width, e.dy * size.height)).toList();

    final roof = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      roof.lineTo(points[i].dx, points[i].dy);
    }

    final roofStroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.shortestSide * 0.008
      ..color = const Color(0xFF2D2D2D);
    canvas.drawPath(roof, roofStroke);

    // Sample points along the roof where bulbs will be placed
    final metrics = roof.computeMetrics().toList();
    final double spacing = size.width * 0.020; // slightly denser spacing
    final double totalLen = metrics.fold(0.0, (p, m) => p + m.length);
    final int numLeds = (totalLen / spacing).floor();

    final bulbRadius = size.shortestSide * 0.008;
    double traversed = 0.0;
    int ledIndex = 0;

    for (final metric in metrics) {
      while (traversed < metric.length) {
        final tangent = metric.getTangentForOffset(traversed);
        if (tangent == null) break;
        // Use path tangent to orient bulbs perpendicular to the roof
        final Offset baseAnchor = tangent.position;
        Offset tVec = tangent.vector;
        final double tLen = tVec.distance == 0 ? 1.0 : tVec.distance;
        final Offset tUnit = Offset(tVec.dx / tLen, tVec.dy / tLen);
        Offset nUnit = Offset(-tUnit.dy, tUnit.dx); // 90° left normal
        if (nUnit.dy < 0) {
          nUnit = Offset(-nUnit.dx, -nUnit.dy); // ensure normal points downward
        }

        final color = EffectAlgorithms.colorFor(
          effect: effectType,
          ledIndex: ledIndex,
          tick: tick,
          numLeds: numLeds,
        );

        // Draw a small dangling triangular bulb oriented with roof normal
        final paint = Paint()..color = color;

        // connector from eave to bulb base
        final Offset baseCenter = baseAnchor + nUnit * (bulbRadius * 1.0);
        final Offset baseLeft = baseCenter - tUnit * (bulbRadius * 0.9);
        final Offset baseRight = baseCenter + tUnit * (bulbRadius * 0.9);
        final Offset tip = baseAnchor + nUnit * (bulbRadius * 2.3);

        final Paint connector = Paint()
          ..color = const Color(0xFF444444)
          ..strokeWidth = size.shortestSide * 0.003
          ..style = PaintingStyle.stroke;
        canvas.drawLine(baseAnchor, baseCenter, connector);

        final Path tri = Path()
          ..moveTo(baseLeft.dx, baseLeft.dy)
          ..lineTo(baseRight.dx, baseRight.dy)
          ..lineTo(tip.dx, tip.dy)
          ..close();
        canvas.drawPath(tri, paint);

        // Small glow under the bulb
        final glow = Paint()
          ..color = color.withValues(alpha: 0.25)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
        canvas.drawCircle(tip, bulbRadius * 1.6, glow);

        ledIndex += 1;
        traversed += spacing;
      }
      traversed -= metric.length;
      if (traversed < 0) traversed = 0;
    }
  }

  @override
  bool shouldRepaint(covariant _HousePainter oldDelegate) {
    return oldDelegate.tick != tick || oldDelegate.effectType != effectType;
  }
}


