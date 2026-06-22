import 'package:flutter/material.dart';
import '../game/rock_cycle_game.dart';
import '../models/game_state.dart';
import '../models/rock_model.dart';

/// Bag de amostras coletadas.
///
/// Exibe o fundo [bag.png] (bolsa aberta) com botões circulares das rochas
/// posicionados na área interior da bolsa. Sem texto — apenas as fotos.
/// Ao selecionar uma amostra, inicia a análise e abre o microscópio.
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
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              // ── Backdrop escuro ─────────────────────────────────
              Container(color: Colors.black54),

              // ── Cartão central da bolsa ─────────────────────────
              Center(
                child: Container(
                  constraints: const BoxConstraints(
                    maxWidth: 500,
                    maxHeight: 360,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF6B8E4E),
                      width: 2.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.4),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // ── Fundo: bolsa aberta ─────────────────────
                      Image.asset(
                        'imgs/bcgs/bag.png',
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) => Container(
                          color: const Color(0xFF2C1810),
                        ),
                      ),

                      // ── Botão fechar (X) — canto superior direito ──
                      Positioned(
                        top: 20,
                        right: 20,
                        child: Semantics(
                          label: 'Fechar bolsa',
                          button: true,
                          child: SizedBox(
                            width: 44,
                            height: 44,
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => game.overlays.remove('bag'),
                                borderRadius: BorderRadius.circular(22),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.4),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white.withValues(alpha: 0.3),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white70,
                                    size: 22,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // ── Botões das rochas — área da bolsa ──────
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 40),
                          child: Wrap(
                            spacing: 24,
                            runSpacing: 24,
                            alignment: WrapAlignment.center,
                            children: samples.map(
                              (rock) => _SampleCircle(
                                rock: rock,
                                onTap: () {
                                  gameState.startAnalysis(rock);
                                  game.openMicroscope();
                                },
                              ),
                            ).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Botão com formato irregular da rocha (transparência do PNG).
class _SampleCircle extends StatelessWidget {
  final RockModel rock;
  final VoidCallback onTap;

  const _SampleCircle({
    required this.rock,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final iconPath = rock.iconAssetPath;
    return SizedBox(
      width: 110,
      height: 110,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // ── Sombra suave atrás da rocha ──────────────────────
              if (iconPath != null)
                Padding(
                  padding: const EdgeInsets.only(left: 2, top: 2),
                  child: Image.asset(
                    iconPath,
                    width: 96,
                    height: 96,
                    fit: BoxFit.contain,
                    color: Colors.black.withValues(alpha: 0.3),
                    colorBlendMode: BlendMode.srcIn,
                  ),
                ),
              // ── Imagem real com bordas irregulares ────────────────
              Padding(
                padding: const EdgeInsets.all(4),
                child: iconPath != null
                    ? Image.asset(
                        iconPath,
                        width: 96,
                        height: 96,
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) => _fallbackIcon(),
                      )
                    : _fallbackIcon(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fallbackIcon() {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(36),
      ),
      child: const Icon(
        Icons.grain,
        color: Colors.white38,
        size: 40,
      ),
    );
  }
}
