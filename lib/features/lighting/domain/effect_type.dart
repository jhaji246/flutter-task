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
    // Group size determines how many bulbs make a chasing segment
    const int groupSize = 4;
    final int phase = tick % (groupSize * 2);

    // Flash every alternate tick for strobing effect
    final bool isFlashTick = (tick % 2) == 0;

    final int groupIndex = ledIndex % (groupSize * 3);
    // Create three groups offset by phase for a chasing feel
    final bool isActiveGroup = groupIndex >= phase && groupIndex < phase + groupSize;

    if (isActiveGroup) {
      return isFlashTick ? Colors.white : const Color(0xFFFFF59D); // warm white flash
    }

    // Dim rest to simulate bulbs being off but faintly visible
    return const Color(0x44FFFFFF);
  }

  static Color _colorfulColor({
    required int ledIndex,
    required int tick,
    required int numLeds,
  }) {
    // Fixed repeating palette and alternating parity blink to match reference
    const palette = <Color>[
      Color(0xFFE53935), // red
      Color(0xFF43A047), // green
      Color(0xFF1E88E5), // blue
      Color(0xFFFDD835), // yellow
    ];

    final Color base = palette[ledIndex % palette.length];

    // Two-phase blink: toggle even/odd LEDs every few ticks for clarity
    final int phase = (tick ~/ 2) % 2; // adjust divisor for blink tempo
    final bool isOn = (ledIndex % 2) == phase;

    return isOn ? base : base.withValues(alpha: 0.15);
  }
}


