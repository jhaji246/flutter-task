part of 'lighting_bloc.dart';

class LightingState extends Equatable {
  const LightingState({
    required this.effectType,
    required this.tick,
    required this.isAnimating,
    required this.speedMs,
  });

  final EffectType effectType;
  final int tick;
  final bool isAnimating;
  final int speedMs;

  LightingState copyWith({
    EffectType? effectType,
    int? tick,
    bool? isAnimating,
    int? speedMs,
  }) {
    return LightingState(
      effectType: effectType ?? this.effectType,
      tick: tick ?? this.tick + 1,
      isAnimating: isAnimating ?? this.isAnimating,
      speedMs: speedMs ?? this.speedMs,
    );
  }

  @override
  List<Object?> get props => [effectType, tick, isAnimating, speedMs];
}


