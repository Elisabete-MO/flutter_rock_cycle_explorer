import 'package:flutter/material.dart';
import '../game/rock_cycle_game.dart';
import '../models/game_state.dart';

/// Overlay de resultado da fase de coleta.
///
/// SUCESSO: coletou todas as amostras obrigatórias → confete + XP + continuar
/// FRACASSO: faltam amostras → mensagem + tentar novamente
class CollectionResultOverlay extends StatelessWidget {
  final GameState gameState;
  final RockCycleGame game;

  const CollectionResultOverlay({
    super.key,
    required this.gameState,
    required this.game,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: gameState,
      builder: (context, _) {
        final success = gameState.hasCollectedAllRequired;

        return Scaffold(
          backgroundColor: Colors.black87,
          body: Center(
            child: Container(
              width: 360,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: success
                      ? Colors.greenAccent.withValues(alpha: 0.3)
                      : Colors.redAccent.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Ícone ────────────────────────────────────────
                  Text(
                    success ? '🎉' : '😔',
                    style: const TextStyle(fontSize: 64),
                  ),
                  const SizedBox(height: 16),

                  // ── Título ───────────────────────────────────────
                  Text(
                    success ? 'Coleta Concluída!' : 'Coleta Incompleta',
                    style: TextStyle(
                      color: success ? Colors.greenAccent : Colors.redAccent,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ── Mensagem ─────────────────────────────────────
                  Text(
                    success
                        ? 'Você coletou Basalto e Obsidiana!\n'
                              'Excelente trabalho de campo!'
                        : 'Que pena! Você ainda não coletou '
                              'todas as amostras necessárias.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // ── XP (sucesso) ─────────────────────────────────
                  if (success)
                    Container(
                      margin: const EdgeInsets.only(top: 8, bottom: 16),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 20),
                          const SizedBox(width: 6),
                          Text(
                            '${GameState.collectionXpReward} XP',
                            style: TextStyle(
                              color: Colors.amber.shade200,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 20),

                  // ── Botão ────────────────────────────────────────
                  ElevatedButton(
                    onPressed: () {
                      if (success) {
                        game.returnToLab();
                      } else {
                        gameState.resetCollection();
                        game.closeLabAndStartExploration();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: success
                          ? Colors.green.shade700
                          : Colors.orange.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      success ? 'Voltar ao Laboratório' : 'Tentar Novamente',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
