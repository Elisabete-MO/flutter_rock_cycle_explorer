import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'game/rock_cycle_game.dart';
import 'models/game_state.dart';
import 'widgets/dialogue_overlay.dart';
import 'widgets/hud_overlay.dart';
import 'package:flutter/foundation.dart';

void main() {
  FlutterError.onError = (details) {
    FlutterError.dumpErrorToConsole(details);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('UNCAUGHT ERROR: $error');
    debugPrint('$stack');
    return true;
  };

  // Instância única do estado global do jogo.
  // Injetada tanto no RockCycleGame quanto nos overlays Flutter.
  final gameState = GameState();

  runApp(
    GameWidget(
      game: RockCycleGame(gameState: gameState),
      // Registra as factories de overlay. Cada overlay recebe o gameState
      // diretamente para acessar dados de progressão do jogador.
      overlayBuilderMap: {
        'hud': (context, game) => HudOverlay(gameState: gameState),
        'dialogue': (context, game) => DialogueOverlay(
          gameState: gameState,
          game: game as RockCycleGame,
        ),
      },
    ),
  );
}
