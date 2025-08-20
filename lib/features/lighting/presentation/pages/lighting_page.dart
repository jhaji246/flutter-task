import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_task/features/lighting/domain/effect_type.dart';
import 'package:flutter_task/features/lighting/presentation/bloc/lighting_bloc.dart';
import 'package:flutter_task/features/lighting/presentation/widgets/house_with_lights.dart';

class LightingPage extends StatelessWidget {
  const LightingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LightingBloc(),
      child: const _LightingScaffold(),
    );
  }
}

class _LightingScaffold extends StatelessWidget {
  const _LightingScaffold();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Roof LED Effects'),
        actions: [
          IconButton(
            onPressed: () {
              final isAnimating = context.read<LightingBloc>().state.isAnimating;
              if (isAnimating) {
                context.read<LightingBloc>().add(const StopAnimation());
              } else {
                context.read<LightingBloc>().add(const StartAnimation());
              }
            },
            icon: BlocBuilder<LightingBloc, LightingState>(
              buildWhen: (a, b) => a.isAnimating != b.isAnimating,
              builder: (context, state) => Icon(state.isAnimating ? Icons.pause : Icons.play_arrow),
            ),
            tooltip: 'Play/Pause',
          )
        ],
      ),
      body: const _Body(),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: AspectRatio(
              aspectRatio: 3 / 2,
              child: DecoratedBox(
                decoration: const BoxDecoration(color: Color(0xFFF6F7FB)),
                child: BlocBuilder<LightingBloc, LightingState>(
                  builder: (context, state) {
                    return HouseWithLights(
                      effectType: state.effectType,
                      tick: state.tick,
                      imageAsset: 'assets/house.png',
                    );
                  },
                ),
              ),
            ),
          ),
        ),
        const _Controls(),
      ],
    );
  }
}

class _Controls extends StatelessWidget {
  const _Controls();

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<LightingBloc>();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      child: Column(
        children: [
          Row(
            children: [
              const Text('Effect:'),
              const SizedBox(width: 12),
              Expanded(
                child: BlocBuilder<LightingBloc, LightingState>(
                  buildWhen: (a, b) => a.effectType != b.effectType,
                  builder: (context, state) {
                    return DropdownButton<EffectType>(
                      isExpanded: true,
                      value: state.effectType,
                      items: const [
                        DropdownMenuItem(value: EffectType.chaseFlash, child: Text('31 - Chase Flash')),
                        DropdownMenuItem(value: EffectType.colorful, child: Text('32 - Colourful')),
                      ],
                      onChanged: (v) => v == null ? null : bloc.add(ChangeEffect(v)),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          BlocBuilder<LightingBloc, LightingState>(
            buildWhen: (a, b) => a.speedMs != b.speedMs,
            builder: (context, state) {
              return Row(
                children: [
                  const Text('Speed'),
                  Expanded(
                    child: Slider(
                      value: state.speedMs.toDouble(),
                      min: 60,
                      max: 300,
                      divisions: 24,
                      label: '${state.speedMs} ms',
                      onChanged: (v) => bloc.add(ChangeSpeed(v.toInt())),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}


