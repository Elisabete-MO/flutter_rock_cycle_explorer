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

  const LabOverlay({super.key, required this.gameState, required this.game});

  @override
  State<LabOverlay> createState() => _LabOverlayState();
}

class _LabOverlayState extends State<LabOverlay> {
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.gameState,
      builder: (context, _) {
        final gs = widget.gameState;

        final screenSize = MediaQuery.of(context).size;
        final screenWidth = screenSize.width;
        final screenHeight = screenSize.height;
        final hasDialogue = gs.isDialogueActive;

        // ── Tela compacta (mobile paisagem) ─────────────────────────
        final isCompactLandscape =
            screenWidth < 900 && screenWidth > screenHeight;

        // ── Posição horizontal ──────────────────────────────────────
        // Mobile:  percentual da largura para aproximar das bordas.
        // Desktop: margem fixa igual à atual (60px).
        final horizontalMargin = isCompactLandscape
            ? screenWidth * 0.045
            : 60.0;

        // ── Posição vertical dos retratos ──────────────────────────
        // Sem diálogo: retratos baixos, agrupados com o botão de ação.
        // Com diálogo:  retratos sobem para não cobrir a caixa de fala.
        final portraitBottom = hasDialogue
            ? screenHeight * 0.33   // acima da caixa de diálogo
            : 60.0;                  // rente ao botão de ação

        return Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            fit: StackFit.expand,
            children: [
              // ── Fundo do laboratório ─────────────────────────────
              Image.asset(
                'imgs/bcgs/lab.png',
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
              AnimatedPositioned(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut,
                left: horizontalMargin,
                bottom: portraitBottom,
                child: _CharacterSprite(
                  label: 'Dra. Sophia',
                  imagePath: 'imgs/characters/sophia_profile.png',
                ),
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut,
                right: horizontalMargin,
                bottom: portraitBottom,
                child: _CharacterSprite(
                  label: 'Dra. Terra',
                  imagePath: 'imgs/characters/dra_terra_profile.png',
                ),
              ),

              // ── Botões de ação ───────────────────────────────────
              if (gs.phase == GamePhase.lab &&
                  !gs.isDialogueActive &&
                  !gs.gameWon)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 40,
                  child: Center(
                    child: _buildActionButton(gs),
                  ),
                ),

              // ── Botão do Diário (ícone) — canto superior direito ──
              if (gs.fieldBookUnlocked &&
                  gs.phase == GamePhase.lab &&
                  !gs.isDialogueActive &&
                  !gs.gameWon)
                Positioned(
                  top: 24,
                  right: 24,
                  child: _DiaryIconButton(
                    key: const Key('diary_button'),
                    onTap: () => widget.game.showFieldBook(),
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
    // ── Prioridade 1: Amostras para analisar ───────────────────────
    if (gs.fieldSamples.isNotEmpty) {
      return _ActionBtn(
        icon: const Icon(Icons.backpack),
        label:
            'Abrir Bag (${gs.fieldSamples.length} amostra${gs.fieldSamples.length > 1 ? 's' : ''})',
        onTap: () => widget.game.showBag(),
      );
    }

    // ── Prioridade 2: Após apresentação, pronto para explorar ─────
    if (gs.initialDialogueCompleted) {
      return _ActionBtn(
        icon: const Icon(Icons.explore),
        label: 'Iniciar Coleta',
        onTap: () => widget.game.closeLabAndStartExploration(),
      );
    }

    // ── Prioridade 3: Primeira vez (antes da apresentação) ─────────
    return _ActionBtn(
      icon: const Icon(Icons.chat),
      label: 'Falar com Dra. Terra',
      onTap: () {
        gs.startInitialDialogue();
        widget.game.showDialogue();
      },
    );
  }

}

/// Botão redondo do Diário de Campo (ícone, canto superior direito).
/// Anima um glow pulsante na borda para dar destaque na tela.
class _DiaryIconButton extends StatefulWidget {
  final VoidCallback onTap;

  const _DiaryIconButton({super.key, required this.onTap});

  @override
  State<_DiaryIconButton> createState() => _DiaryIconButtonState();
}

class _DiaryIconButtonState extends State<_DiaryIconButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _pulse = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Abrir Diário de Campo',
      button: true,
      child: AnimatedBuilder(
        animation: _pulse,
        builder: (context, child) {
          final glowOpacity = 0.3 + (_pulse.value * 0.5);
          final shadowBlur = 6.0 + (_pulse.value * 10.0);
          final borderOpacity = 0.5 + (_pulse.value * 0.5);
          return SizedBox(
            width: 60,
            height: 60,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onTap,
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.brown.shade800.withValues(alpha: 0.92),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.amber.withValues(alpha: borderOpacity),
                      width: 2.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.amber.withValues(alpha: glowOpacity),
                        blurRadius: shadowBlur,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'imgs/icons/diary.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Retrato responsivo dos personagens no laboratório com imagem, moldura e sombra.
///
/// O tamanho é calculado como 35% da altura da tela.
/// Em mobile paisagem (<900px largura) o limite máximo é reduzido para 150px
/// a fim de não ocupar espaço excessivo do laboratório.
class _CharacterSprite extends StatelessWidget {
  final String label;
  final String imagePath;

  const _CharacterSprite({required this.label, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    final isCompactLandscape =
        screenWidth < 900 && screenWidth > screenHeight;
    final avatarSize = isCompactLandscape
        ? (screenHeight * 0.35).clamp(80.0, 150.0)
        : (screenHeight * 0.35).clamp(100.0, 300.0);
    final borderRadius = avatarSize * 0.12;
    final labelFontSize = (avatarSize * 0.14).clamp(11.0, 16.0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: avatarSize,
          height: avatarSize,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            boxShadow: [
              // Sombra grande — destaca do fundo escuro do lab
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.90),
                blurRadius: 48,
                spreadRadius: 12,
                offset: const Offset(0, 10),
              ),
              // Sombra densa — profundidade do card
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.80),
                blurRadius: 20,
                spreadRadius: 6,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(borderRadius),
            child: Image.asset(
              imagePath,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                color: Colors.grey.shade800,
                child: const Icon(Icons.person, color: Colors.white54),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: labelFontSize,
            fontWeight: FontWeight.w600,
            shadows: const [Shadow(color: Colors.black87, blurRadius: 4)],
          ),
        ),
      ],
    );
  }
}

/// Botão de ação padronizado do laboratório.
class _ActionBtn extends StatelessWidget {
  final Widget icon;
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
      icon: icon,
      label: Text(label, style: const TextStyle(fontSize: 15)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.brown.shade700,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
