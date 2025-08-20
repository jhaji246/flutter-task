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
    // Enhanced chase effect with smooth transitions and trail
    final int head = tick % (numLeds == 0 ? 1 : numLeds);
    final int delta = (ledIndex - head + numLeds) % numLeds;
    
    // Create a smooth falloff for the chase effect
    if (delta > 8) return const Color(0x00000000);
    
    // Brightness decreases with distance from head
    final double brightness = 1.0 - (delta / 8);
    // Use a bright cyan color for better visibility
    return const Color(0xFF00FFFF).withOpacity(brightness * 0.95);
  }

  static Color _colorfulColor({
    required int ledIndex,
    required int tick,
    required int numLeds,
  }) {
    // Enhanced colorful effect with smooth color transitions and patterns
    final List<Color> palette = [
      const Color(0xFFFF1C1C), // vivid red
      const Color(0xFF2BD92B), // vivid green
      const Color(0xFF2B6BFF), // vivid blue
      const Color(0xFFFFF42B), // vivid yellow
      const Color(0xFFFF6BFF), // pink
      const Color(0xFF00FFFF), // cyan
    ];

    // Create a moving wave pattern with colors
    final double progress = (tick % 100) / 100.0; // 0.0 to 1.0
    final int colorOffset = (tick ~/ 15) % palette.length;
    
    // Calculate position in the wave (0.0 to 1.0)
    final double ledPos = ledIndex / numLeds;
    final double wavePos = (ledPos - progress + 1.0) % 1.0;
    
    // Create a wave with smooth falloff
    final double intensity = 0.5 + 0.5 * math.sin(wavePos * 3.1416 * 2);
    
    // Select color based on position and time
    final int colorIndex = ((ledIndex + colorOffset) % palette.length).toInt();
    return palette[colorIndex].withOpacity(intensity * 0.9);
  }
}


