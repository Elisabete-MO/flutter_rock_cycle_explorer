import 'package:flutter/material.dart';
import '../game/rock_cycle_game.dart';
import '../models/game_state.dart';

/// Tela estática do laboratório.
///
/// Exibe o fundo [lab.png] com os personagens Dra. Terra e Dra. Sophia
/// posicionados. A interação ocorre por botões e pelo [DialogueOverlay].
class LabOverlay extends StatefulWidget {
  final GameState gameState;
  final RockCycleGame game;

  const LabOverlay({
    super.key,
    required this.gameState,
    required this.game,
  });

  @override
  State<LabOverlay> createState() => _LabOverlayState();
}

class _LabOverlayState extends State<LabOverlay> {
  bool _dialogueStarted = false;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.gameState,
      builder: (context, _) {
        final gs = widget.gameState;

        // ── Post-feedback finalization ────────────────────────────
        // Após o diálogo de feedback terminar, finaliza a amostra
        // (move de fieldSamples para analyzedRocks) e verifica progresso.
        if (gs.classificationAttempted &&
            gs.feedbackGiven &&
            !gs.hasPendingClassificationFeedback &&
            !gs.isDialogueActive) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              gs.finalizeAfterFeedback();
              if (gs.isQuestCompleted && !gs.gameWon &&
                  mounted) {
                widget.game.startDialogue(GameState.victoryDialogue);
              }
            }
          });
        }

        // ── Auto-start initial dialogue ───────────────────────────
        if (!_dialogueStarted && !gs.gameWon && !gs.isDialogueActive) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!_dialogueStarted && mounted) {
              _startDialogue(GameState.initialDialogue);
            }
          });
        }

        return Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            fit: StackFit.expand,
            children: [
              // ── Fundo do laboratório ─────────────────────────────
              Image.asset(
                'imgs/lab.png',
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  color: const Color(0xFF2C1810),
                  child: const Center(
                    child: Text(
                      'Laboratório',
                      style: TextStyle(color: Colors.white54, fontSize: 24),
                    ),
                  ),
                ),
              ),

              // ── Personagens ───────────────────────────────────────
              Positioned(
                left: 60,
                bottom: 120,
                child: _CharacterSprite(
                  label: 'Dra. Terra',
                  color: Colors.greenAccent,
                ),
              ),
              Positioned(
                right: 60,
                bottom: 120,
                child: _CharacterSprite(
                  label: 'Dra. Sophia',
                  color: Colors.blueAccent,
                ),
              ),

              // ── Botões de ação ───────────────────────────────────
              if (!gs.isDialogueActive && !gs.gameWon)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 40,
                  child: Center(
                    child: _buildActionButton(gs),
                  ),
                ),

              // ── Banner de vitória ────────────────────────────────
              if (gs.isQuestCompleted && gs.gameWon)
                Positioned.fill(
                  child: Container(
                    color: Colors.black54,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('🎉', style: TextStyle(fontSize: 64)),
                          const SizedBox(height: 16),
                          Text(
                            'Missão Cumprida!',
                            style: TextStyle(
                              color: Colors.amberAccent.shade200,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Total de XP: ${gs.xp}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 18,
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
      },
    );
  }

  Widget _buildActionButton(GameState gs) {
    // ── Prioridade 1: Feedback pendente (pós-classificação) ───────
    if (gs.hasPendingClassificationFeedback) {
      return _ActionBtn(
        icon: Icons.chat,
        label: 'Falar com Dra. Terra',
        onTap: () => _startFeedbackDialogue(),
      );
    }

    // ── Prioridade 2: Amostras para analisar (pós-coleta) ─────────
    if (gs.fieldSamples.isNotEmpty) {
      return _ActionBtn(
        icon: Icons.backpack,
        label: 'Abrir Bag (${gs.fieldSamples.length} amostra${gs.fieldSamples.length > 1 ? 's' : ''})',
        onTap: () => widget.game.showBag(),
      );
    }

    // ── Prioridade 3: Após diálogo inicial, pronto para explorar ──
    if (_dialogueStarted) {
      return _ActionBtn(
        icon: Icons.explore,
        label: 'Iniciar Coleta',
        onTap: () => widget.game.closeLabAndStartExploration(),
      );
    }

    // ── Prioridade 4: Primeira vez (antes do diálogo inicial) ─────
    return _ActionBtn(
      icon: Icons.chat,
      label: 'Falar com Dra. Terra',
      onTap: () => _startDialogue(GameState.initialDialogue),
    );
  }

  void _startDialogue(List<String> lines) {
    widget.gameState.startDialogue(lines);
    widget.game.showDialogue();
    _dialogueStarted = true;
  }

  void _startFeedbackDialogue() {
    if (!widget.gameState.hasPendingClassificationFeedback) return;
    final sample = widget.gameState.currentSample;
    if (sample == null) return;

    final lines = widget.gameState.lastClassificationCorrect
        ? widget.gameState.generateCorrectFeedbackDialogue(sample)
        : widget.gameState.generateWrongFeedbackDialogue(sample);

    // Start dialogue FIRST so isDialogueActive=true before feedbackGiven,
    // preventing the post-feedback check from firing prematurely.
    widget.gameState.startDialogue(lines);
    widget.game.showDialogue();
    widget.gameState.markFeedbackGiven();
  }
}

/// Placeholder visual para personagens no laboratório.
class _CharacterSprite extends StatelessWidget {
  final String label;
  final Color color;

  const _CharacterSprite({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: color, width: 2),
          ),
          child: Icon(Icons.person, color: color, size: 36),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            shadows: const [
              Shadow(color: Colors.black87, blurRadius: 4),
            ],
          ),
        ),
      ],
    );
  }
}

/// Botão de ação padronizado do laboratório.
class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon),
      label: Text(label, style: const TextStyle(fontSize: 15)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.brown.shade700,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
