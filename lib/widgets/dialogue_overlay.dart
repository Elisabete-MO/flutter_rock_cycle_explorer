import 'package:flutter/material.dart';
import '../game/rock_cycle_game.dart';
import '../models/game_state.dart';

/// Overlay de diálogo exibido na parte inferior da tela durante interações
/// com NPCs.
///
/// Consome exclusivamente a API pública de [GameState]:
/// - Exibe [GameState.currentDialogueLine]
/// - "Continuar" → [GameState.advanceDialogue]
/// - Última fala → [GameState.endDialogue] + remove o overlay
///
/// Não cria sistema de escolhas, missões ou animações.
class DialogueOverlay extends StatelessWidget {
  final GameState gameState;
  final RockCycleGame game;

  const DialogueOverlay({
    super.key,
    required this.gameState,
    required this.game,
  });

  /// Avança ou encerra o diálogo conforme o estado atual.
  void _handleContinue() {
    final bool isLastLine =
        gameState.currentDialogueIndex >= gameState.dialogueLines.length - 1;

    if (isLastLine) {
      gameState.endDialogue();
      game.hideDialogue();
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
        // Proteção extra: se o diálogo foi encerrado externamente,
        // não renderiza nada (o overlay será removido em breve).
        if (line == null) return const SizedBox.shrink();

        return Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    line,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: _handleContinue,
                    child: const Text('Continuar'),
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
