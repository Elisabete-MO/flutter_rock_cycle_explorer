import 'package:flutter/material.dart';
import '../models/game_state.dart';

/// Overlay de HUD exibido no topo da tela durante o jogo.
///
/// Responsabilidades:
/// - Exibir nível atual, XP atual e missão ativa.
/// - Utilizar [GameState] como fonte única de dados.
/// - Layout discreto preparado para futuras expansões.
class HudOverlay extends StatelessWidget {
  final GameState gameState;

  const HudOverlay({super.key, required this.gameState});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: gameState,
      builder: (context, _) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Linha superior: nível e XP ────────────────────────────
                Row(
                  children: [
                    _Badge(label: 'Nv ${gameState.level}'),
                    const SizedBox(width: 12),
                    _XpBar(xp: gameState.xp, level: gameState.level),
                  ],
                ),
                const SizedBox(height: 4),
                // ── Missão ativa ──────────────────────────────────────────
                if (gameState.activeQuest != null)
                  Text(
                    gameState.activeQuest!,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Pequeno selo arredondado para exibir um valor (ex.: nível).
class _Badge extends StatelessWidget {
  final String label;

  const _Badge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Barra de progresso de XP do nível atual.
class _XpBar extends StatelessWidget {
  final int xp;
  final int level;

  const _XpBar({required this.xp, required this.level});

  @override
  Widget build(BuildContext context) {
    final int nextLevelXp = level * 100;
    final double progress = nextLevelXp > 0 ? (xp / nextLevelXp).clamp(0.0, 1.0) : 0.0;

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'XP: $xp / $nextLevelXp',
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
          const SizedBox(height: 2),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}
