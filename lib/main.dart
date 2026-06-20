import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'game/rock_cycle_game.dart';
import 'models/game_state.dart';
import 'widgets/analysis_overlay.dart';
import 'widgets/bag_overlay.dart';
import 'widgets/classification_overlay.dart';
import 'widgets/collection_result_overlay.dart';
import 'widgets/dialogue_overlay.dart';
import 'widgets/hud_overlay.dart';
import 'widgets/lab_overlay.dart';
import 'widgets/victory_overlay.dart';
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

  final gameState = GameState();

  runApp(
    GameWidget(
      game: RockCycleGame(gameState: gameState),
      overlayBuilderMap: {
        'hud': (context, game) => HudOverlay(gameState: gameState),
        'dialogue': (context, game) => DialogueOverlay(
          gameState: gameState,
          game: game as RockCycleGame,
        ),
        'lab': (context, game) => LabOverlay(
          gameState: gameState,
          game: game as RockCycleGame,
        ),
        'bag': (context, game) => BagOverlay(
          gameState: gameState,
          game: game as RockCycleGame,
        ),
        'analysis': (context, game) => AnalysisOverlay(
          gameState: gameState,
          game: game as RockCycleGame,
        ),
        'classification': (context, game) => ClassificationOverlay(
          gameState: gameState,
          game: game as RockCycleGame,
        ),
        'collectionResult': (context, game) => CollectionResultOverlay(
          gameState: gameState,
          game: game as RockCycleGame,
        ),
        'victory': (context, game) => VictoryOverlay(
          gameState: gameState,
          game: game as RockCycleGame,
        ),
      },
    ),
  );
}
