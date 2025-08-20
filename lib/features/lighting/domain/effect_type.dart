
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
    // Chase Flash: moving segments of bright white lights with flash effect
    const int groupSize = 5; // size of each chasing group
    const int numGroups = 3; // number of groups chasing around
    final int spacing = numLeds ~/ numGroups; // space between groups
    
    // Flash every other tick for strobe effect
    final bool isFlashTick = (tick % 2) == 0;
    
    for (int group = 0; group < numGroups; group++) {
      final int groupStart = (tick + group * spacing) % numLeds;
      
      // Check if this LED is in the current group
      for (int i = 0; i < groupSize; i++) {
        if ((groupStart + i) % numLeds == ledIndex) {
          // Bright white with flash strobe effect
          return isFlashTick ? const Color(0xFFFFFFFF) : const Color(0xFFE6E6E6);
        }
      }
    }
    
    return const Color(0x00000000); // fully off for others
  }

  static Color _colorfulColor({
    required int ledIndex,
    required int tick,
    required int numLeds,
  }) {
    // Colourful effect: RGBY repeating pattern with alternating blink
    const List<Color> palette = [
      Color(0xFFFF1515), // bright red
      Color(0xFF15FF15), // bright green  
      Color(0xFF1515FF), // bright blue
      Color(0xFFFFFF15), // bright yellow
    ];

    // Each LED has a fixed color based on its position
    final Color baseColor = palette[ledIndex % palette.length];
    
    // Simple alternating blink: even/odd LEDs alternate every few ticks
    final int phase = (tick ~/ 2) % 2; // adjust blink speed
    final bool isOn = (ledIndex % 2) == phase;
    
    return isOn ? baseColor : const Color(0x00000000);
  }
}


