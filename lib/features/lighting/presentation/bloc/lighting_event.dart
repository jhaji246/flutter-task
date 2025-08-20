part of 'lighting_bloc.dart';

abstract class LightingEvent extends Equatable {
  const LightingEvent();
}

class StartAnimation extends LightingEvent {
  const StartAnimation();
  @override
  List<Object?> get props => const [];
}

class StopAnimation extends LightingEvent {
  const StopAnimation();
  @override
  List<Object?> get props => const [];
}

class ChangeEffect extends LightingEvent {
  const ChangeEffect(this.effectType);
  final EffectType effectType;

  @override
  List<Object?> get props => [effectType];
}

class ChangeSpeed extends LightingEvent {
  const ChangeSpeed(this.speedMs);
  final int speedMs;

  @override
  List<Object?> get props => [speedMs];
}


