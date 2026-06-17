import 'package:flame/game.dart';
import '../components/player.dart';

class RockCycleGame extends FlameGame {
  late final Player player;

  @override
  Future<void> onLoad() async {
    player = Player()
      ..position = size / 2;

    add(player);
  }
}