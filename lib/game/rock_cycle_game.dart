import 'package:flame/events.dart';
import 'package:flame/game.dart';
import '../components/player.dart';

/// Loop principal do Rock Cycle Explorer.
///
/// Mixins:
///  - [HasKeyboardHandlerComponents] → roteia eventos de teclado do Flutter
///    para todos os componentes que implementam [KeyboardHandler], como o
///    [Player]. Sem este mixin, as teclas nunca chegam ao player.
class RockCycleGame extends FlameGame with HasKeyboardHandlerComponents {
  late final Player player;

  @override
  Future<void> onLoad() async {
    // `size / 2` posiciona o player no centro da tela.
    // Funciona corretamente porque o Player usa Anchor.center.
    player = Player()..position = size / 2;

    add(player);
  }
}