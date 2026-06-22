import 'package:flutter/material.dart';
import '../game/rock_cycle_game.dart';
import '../models/game_state.dart';
import '../models/rock_model.dart';

/// Overlay do microscópio — apenas observação visual.
///
/// Mostra:
/// - Imagem/sprite ampliado da amostra
/// - Características observadas (Cristais, Camadas, Fósseis, Bandas)
/// - Pistas observacionais
/// - Botão [Classificar] que abre o [ClassificationOverlay]
///
/// O microscópio NÃO ensina — apenas mostra evidências.
/// A Dra. Terra é responsável por todo o conteúdo pedagógico.
class AnalysisOverlay extends StatelessWidget {
  final GameState gameState;
  final RockCycleGame game;

  const AnalysisOverlay({
    super.key,
    required this.gameState,
    required this.game,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: gameState,
      builder: (context, _) {
        final sample = gameState.currentSample;
        // Se não há amostra selecionada, não renderiza nada
        // (a seleção é feita pela Bag, que abre analysis com startAnalysis)
        if (sample == null) return const SizedBox.shrink();
        return _MicroscopeView(
          sample: sample,
          onClassify: () => game.transitionToClassification(),
        );
      },
    );
  }
}
/// Tela do microscópio com a amostra em observação.
class _MicroscopeView extends StatelessWidget {
  final RockModel sample;
  final VoidCallback onClassify;

  const _MicroscopeView({
    required this.sample,
    required this.onClassify,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Fundo do microscópio ─────────────────────────────────
          Image.asset(
            'imgs/bcgs/mic.png',
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Container(
              color: const Color(0xFF1A1A2E),
            ),
          ),

          // ── Card de análise central ──────────────────────────────
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Container(
                width: 360,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E).withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Cabeçalho ──────────────────────────────────
                    Text(
                      'Análise da Amostra',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Imagem da amostra ──────────────────────────
                    Center(
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(
                            color: Colors.cyan.withValues(alpha: 0.3),
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          Icons.grain,
                          color: Colors.cyan.withValues(alpha: 0.6),
                          size: 48,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Características Observadas ─────────────────
                    _SectionHeader(title: 'Características Observadas'),
                    const SizedBox(height: 8),
                    _CharacteristicItem(
                      label: 'Cristais',
                      observed: sample.hasCrystals,
                    ),
                    _CharacteristicItem(
                      label: 'Camadas',
                      observed: sample.hasLayers,
                    ),
                    _CharacteristicItem(
                      label: 'Fósseis',
                      observed: sample.hasFossils,
                    ),
                    _CharacteristicItem(
                      label: 'Bandas',
                      observed: sample.hasBands,
                    ),
                    const SizedBox(height: 20),

                    // ── Pistas ─────────────────────────────────────
                    _SectionHeader(title: 'Pistas'),
                    const SizedBox(height: 8),
                    ...sample.clues.map(_buildClueItem),
                    const SizedBox(height: 24),

                    // ── Botão Classificar ──────────────────────────
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: onClassify,
                        icon: const Icon(Icons.biotech),
                        label: const Text(
                          'Classificar',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber.shade700,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClueItem(String clue) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 13,
            ),
          ),
          Expanded(
            child: Text(
              clue,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.75),
                fontSize: 13,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Item de característica observada.
class _CharacteristicItem extends StatelessWidget {
  final String label;
  final bool observed;

  const _CharacteristicItem({
    required this.label,
    required this.observed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            observed ? Icons.check_circle : Icons.cancel,
            size: 18,
            color: observed ? Colors.greenAccent : Colors.redAccent,
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            observed ? 'Sim' : 'Não',
            style: TextStyle(
              color: observed ? Colors.greenAccent : Colors.redAccent,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Cabeçalho de seção.
class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.5),
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
      ),
    );
  }
}
