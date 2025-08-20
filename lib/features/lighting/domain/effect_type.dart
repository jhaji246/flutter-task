
import 'dart:math' as math;
import 'package:flutter/material.dart';

enum EffectType {
  chaseFlash,
  colorful,
}

class EffectAlgorithms {
  static Color colorFor({
    required EffectType effect,
    required int ledIndex,
    required int tick,
    required int numLeds,
  }) {
    switch (effect) {
      case EffectType.chaseFlash:
        return _chaseFlashColor(ledIndex: ledIndex, tick: tick, numLeds: numLeds);
      case EffectType.colorful:
        return _colorfulColor(ledIndex: ledIndex, tick: tick, numLeds: numLeds);
    }
  }

  static Color _chaseFlashColor({
    required int ledIndex,
    required int tick,
    required int numLeds,
  }) {
    // 31 - Chase Flash: Simple moving white light chase
    const int chaseLength = 5; // chase tail length
    final int head = tick % numLeds; // position of brightest light
    
    // Calculate distance from the chase head
    int distance = (ledIndex - head + numLeds) % numLeds;
    
    if (distance < chaseLength) {
      // Create brightness gradient from head to tail
      final double brightness = 1.0 - (distance / chaseLength);
      return Colors.white.withValues(alpha: brightness);
    }
    
    return const Color(0x00000000); // off
  }

  static Color _colorfulColor({
    required int ledIndex,
    required int tick,
    required int numLeds,
  }) {
    // 32 - Colourful: Simple alternating color pattern
    const List<Color> palette = [
      Color(0xFFFF0000), // red
      Color(0xFF00FF00), // green  
      Color(0xFF0000FF), // blue
      Color(0xFFFFFF00), // yellow
    ];

    // Each LED gets a fixed color based on position
    final Color baseColor = palette[ledIndex % palette.length];
    
    // Simple alternating blink pattern
    final int phase = (tick ~/ 3) % 2; // blink every 3 ticks
    final bool isOn = (ledIndex % 2) == phase;
    
    return isOn ? baseColor : const Color(0x00000000);
  }
}


