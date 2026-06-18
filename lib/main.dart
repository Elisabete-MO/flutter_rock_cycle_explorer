import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'game/rock_cycle_game.dart';
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

  runApp(
    GameWidget(
      game: RockCycleGame(),
    ),
  );
}
