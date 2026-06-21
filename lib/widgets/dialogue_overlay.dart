import 'package:flutter/material.dart';
import '../game/rock_cycle_game.dart';
import '../models/game_state.dart';

/// Overlay de diálogo exibido na parte inferior da tela durante interações
/// com a Dra. Terra.
///
/// Consome exclusivamente a API pública de [GameState]:
/// - Exibe [GameState.currentDialogueLine]
/// - "Continuar" → [GameState.advanceDialogue]
/// - Última fala → [GameState.endDialogue] + remove o overlay
class DialogueOverlay extends StatelessWidget {
  final GameState gameState;
  final RockCycleGame game;

  const DialogueOverlay({
    super.key,
    required this.gameState,
    required this.game,
  });

  void _handleContinue() {
    final isLastLine =
        gameState.currentDialogueIndex >= gameState.dialogueLines.length - 1;

    if (isLastLine) {
      final completedPurpose = gameState.endDialogue();

      if (completedPurpose == DialoguePurpose.classificationFeedback &&
          gameState.isQuestCompleted) {
        gameState.startVictoryDialogue();
      } else if (completedPurpose == DialoguePurpose.victory) {
        gameState.completeQuest();
        game.showVictory();
      } else {
        game.hideDialogue();
      }
    } else {
      gameState.advanceDialogue();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: gameState,
      builder: (context, _) {
        final line = gameState.currentDialogueLine;
        if (line == null) return const SizedBox.shrink();

        return Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Nome da personagem ─────────────────────────
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Dra. Terra',
                      style: TextStyle(
                        color: Colors.greenAccent.shade200,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    line,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: _handleContinue,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.amberAccent,
                    ),
                    child: Text(
                      gameState.currentDialogueIndex >=
                              gameState.dialogueLines.length - 1
                          ? 'Concluir'
                          : 'Continuar',
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
