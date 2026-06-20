import 'package:flutter/material.dart';
import '../game/rock_cycle_game.dart';
import '../models/game_state.dart';

/// Bag de amostras coletadas.
///
/// Lista apenas amostras pendentes de análise (fieldSamples).
/// Mostra "Amostra #N" — sem nome, tipo ou descrição.
/// Ao selecionar, inicia a análise e abre o microscópio.
class BagOverlay extends StatelessWidget {
  final GameState gameState;
  final RockCycleGame game;

  const BagOverlay({
    super.key,
    required this.gameState,
    required this.game,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: gameState,
      builder: (context, _) {
        final samples = gameState.fieldSamples;
        if (samples.isEmpty) return const SizedBox.shrink();

        return Scaffold(
          backgroundColor: Colors.black87,
          body: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Container(
                width: 360,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.backpack, color: Colors.amberAccent, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          'Bag de Amostras',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Selecione uma amostra para analisar:',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...samples.asMap().entries.map(
                      (e) => _SampleCard(
                        index: e.key,
                        sampleLabel: 'Amostra #${e.key + 1}',
                        onTap: () {
                          gameState.startAnalysis(e.value);
                          game.openMicroscope();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SampleCard extends StatelessWidget {
  final int index;
  final String sampleLabel;
  final VoidCallback onTap;

  const _SampleCard({
    required this.index,
    required this.sampleLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.15),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.grain,
                  color: Colors.cyan.withValues(alpha: 0.6),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  sampleLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.chevron_right,
                  color: Colors.white.withValues(alpha: 0.4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
