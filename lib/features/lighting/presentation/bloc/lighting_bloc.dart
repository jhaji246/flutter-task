import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_task/features/lighting/domain/effect_type.dart';

part 'lighting_event.dart';
part 'lighting_state.dart';

class LightingBloc extends Bloc<LightingEvent, LightingState> {
  LightingBloc()
      : super(const LightingState(
          effectType: EffectType.chaseFlash,
          tick: 0,
          isAnimating: true,
          speedMs: 120,
        )) {
    on<StartAnimation>(_onStart);
    on<StopAnimation>(_onStop);
    on<ChangeEffect>(_onChangeEffect);
    on<ChangeSpeed>(_onChangeSpeed);

    _startTicker();
  }

  Timer? _timer;

  void _startTicker() {
    _timer?.cancel();
    if (!state.isAnimating) return;
    _timer = Timer.periodic(Duration(milliseconds: state.speedMs), (timer) {
      add(const _Tick());
    });
  }

  void _onStart(StartAnimation event, Emitter<LightingState> emit) {
    emit(state.copyWith(isAnimating: true));
    _startTicker();
  }

  void _onStop(StopAnimation event, Emitter<LightingState> emit) {
    _timer?.cancel();
    emit(state.copyWith(isAnimating: false));
  }

  void _onChangeEffect(ChangeEffect event, Emitter<LightingState> emit) {
    emit(state.copyWith(effectType: event.effectType));
  }

  void _onChangeSpeed(ChangeSpeed event, Emitter<LightingState> emit) {
    emit(state.copyWith(speedMs: event.speedMs));
    _startTicker();
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}

class _Tick extends LightingEvent {
  const _Tick();

  @override
  List<Object?> get props => const [];
}


