import 'package:flutter/material.dart';
import '../game/rock_cycle_game.dart';
import '../models/game_state.dart';

/// Overlay de vitória da primeira quest.
///
/// Exibido após a Dra. Terra anunciar a conclusão da missão.
/// Mostra total de XP, mensagem de parabéns e confete.
class VictoryOverlay extends StatelessWidget {
  final GameState gameState;
  final RockCycleGame game;

  const VictoryOverlay({
    super.key,
    required this.gameState,
    required this.game,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            width: 380,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.amber.shade900.withValues(alpha: 0.3),
                  const Color(0xFF1E1E1E),
                  Colors.amber.shade900.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Confete ──────────────────────────────────────
                const Text('🎉🎊✨', style: TextStyle(fontSize: 48)),
                const SizedBox(height: 20),

                // ── Título ─────────────────────────────────────────
                Text(
                  'Missão Cumprida!',
                  style: TextStyle(
                    color: Colors.amberAccent.shade200,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                // ── Mensagem ───────────────────────────────────────
                Text(
                  'Parabéns, Dra. Sophia!\n'
                  'Você catalogou Basalto e Obsidiana\n'
                  'e deu o primeiro passo para desvendar\n'
                  'a história geológica da ilha.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),

                // ── XP Total ───────────────────────────────────────
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.amber.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 28),
                      const SizedBox(width: 12),
                      Text(
                        '${gameState.totalXp} XP',
                        style: TextStyle(
                          color: Colors.amber.shade200,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ── Botão ──────────────────────────────────────────
                ElevatedButton(
                  onPressed: () {
                    game.restartAdventure();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 48,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Reiniciar Aventura',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
