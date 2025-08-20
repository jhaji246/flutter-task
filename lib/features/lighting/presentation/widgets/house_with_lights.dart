import 'dart:ui' as ui;
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_task/features/lighting/domain/effect_type.dart';

class HouseWithLights extends StatefulWidget {
  const HouseWithLights({super.key, required this.effectType, required this.tick, this.imageAsset = 'assets/house.png'});

  final EffectType effectType;
  final int tick;
  final String imageAsset;

  @override
  State<HouseWithLights> createState() => _HouseWithLightsState();
}

class _HouseWithLightsState extends State<HouseWithLights> {
  ui.Image? _image;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void didUpdateWidget(covariant HouseWithLights oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageAsset != widget.imageAsset) {
      _loadImage();
    }
  }

  Future<void> _loadImage() async {
    try {
      final data = await rootBundle.load(widget.imageAsset);
      final bytes = data.buffer.asUint8List();
      final completer = Completer<ui.Image>();
      ui.decodeImageFromList(bytes, (img) => completer.complete(img));
      final img = await completer.future;
      if (mounted) {
        setState(() {
          _image = img;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _image = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _HousePainter(effectType: widget.effectType, tick: widget.tick, image: _image),
      child: const SizedBox.expand(),
    );
  }
}

class _HousePainter extends CustomPainter {
  _HousePainter({required this.effectType, required this.tick, required this.image});

  final EffectType effectType;
  final int tick;
  final ui.Image? image;

  @override
  void paint(Canvas canvas, Size size) {
    // Draw the background house image with BoxFit.contain and compute its rect.
    Rect destRect = Offset.zero & size;
    if (image != null) {
      final fitted = applyBoxFit(BoxFit.contain, Size(image!.width.toDouble(), image!.height.toDouble()), size);
      final outputSize = fitted.destination;
      final dx = (size.width - outputSize.width) / 2;
      final dy = (size.height - outputSize.height) / 2;
      destRect = Rect.fromLTWH(dx, dy, outputSize.width, outputSize.height);
      paintImage(canvas: canvas, rect: destRect, image: image!, fit: BoxFit.contain, filterQuality: FilterQuality.high);
      

    }

    // Complete roof outline following the actual house fascia edge precisely
    final List<Offset> roofPoints = [
      // Left gable start (far left) - adjust to roof edge
      const Offset(0.142, 0.355),
      // Horizontal section under left roof - balcony area
      const Offset(0.305, 0.355),
      // Small gable up - adjust peak position
      const Offset(0.340, 0.285),
      // Small gable down - adjust to eave level
      const Offset(0.375, 0.355),
      // Long horizontal eave across middle
      const Offset(0.590, 0.355),
      // Up to main gable start
      const Offset(0.635, 0.305),
      // Main gable peak - adjust height
      const Offset(0.700, 0.245),
      // Down right side of main gable
      const Offset(0.765, 0.305),
      // Continue horizontal eave right
      const Offset(0.855, 0.355),
      // Right eave end
      const Offset(0.915, 0.355),
    ].map((e) => Offset(destRect.left + e.dx * destRect.width, destRect.top + e.dy * destRect.height)).toList();

    final roof = Path()..moveTo(roofPoints.first.dx, roofPoints.first.dy);
    for (int i = 1; i < roofPoints.length; i++) {
      roof.lineTo(roofPoints[i].dx, roofPoints[i].dy);
    }

    // Optional: debug stroke for alignment (commented out in prod)
    // final roofStroke = Paint()
    //   ..style = PaintingStyle.stroke
    //   ..strokeWidth = size.shortestSide * 0.004
    //   ..color = const Color(0x88FF0000);
    // canvas.drawPath(roof, roofStroke);

    // Sample points along the roof where bulbs will be placed
    final metrics = roof.computeMetrics().toList();
    final double spacing = destRect.width * 0.020; // wider spacing for better visibility
    final double totalLen = metrics.fold(0.0, (p, m) => p + m.length);
    final int numLeds = (totalLen / spacing).floor();

    final bulbRadius = size.shortestSide * 0.010; // smaller bulbs
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

        // Draw all bulbs - both on and off for clear strand visibility
        // connector from eave to bulb base - hang directly from fascia
        final Offset baseCenter = baseAnchor + nUnit * (bulbRadius * 0.3);
        final Offset tip = baseAnchor + nUnit * (bulbRadius * 1.5);

        final Paint connector = Paint()
          ..color = const Color(0xFF333333)
          ..strokeWidth = size.shortestSide * 0.006
          ..style = PaintingStyle.stroke;
        canvas.drawLine(baseAnchor, tip, connector);

        // Simple bulb rendering for clear animation
        final Color displayColor = color.alpha > 0 ? color : const Color(0x22FFFFFF);
        
        // Main bulb circle
        final Paint bulbPaint = Paint()..color = displayColor;
        canvas.drawCircle(tip, bulbRadius, bulbPaint);
        
        // Simple outline for definition
        final Paint outline = Paint()
          ..color = const Color(0xFF333333)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0;
        canvas.drawCircle(tip, bulbRadius, outline);

        // Small highlight when bulb is on
        if (color.alpha > 50) {
          final Paint highlight = Paint()..color = Colors.white.withValues(alpha: 0.6);
          canvas.drawCircle(tip + Offset(-bulbRadius * 0.3, -bulbRadius * 0.3), bulbRadius * 0.3, highlight);
        }

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


