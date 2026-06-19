import 'package:flame/game.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rock_cycle_explorer/game/rock_cycle_game.dart';
import 'package:rock_cycle_explorer/models/game_state.dart';

void main() {
  testWidgets('RockCycleGame smoke test', (WidgetTester tester) async {
    final gameState = GameState();
    final game = RockCycleGame(gameState: gameState);
    await tester.pumpWidget(GameWidget(game: game));
    expect(find.byType(GameWidget<RockCycleGame>), findsOneWidget);
  });
}
