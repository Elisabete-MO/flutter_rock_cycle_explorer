import 'package:flame/events.dart';
import 'package:flame/game.dart';
import '../components/npc_component.dart';
import '../components/player.dart';
import '../components/rock_component.dart';

/// Loop principal do Rock Cycle Explorer.
///
/// Mixins:
///  - [HasKeyboardHandlerComponents] → roteia eventos de teclado do Flutter
///    para todos os componentes que implementam [KeyboardHandler], como o
///    [Player]. Sem este mixin, as teclas nunca chegam ao player.
class RockCycleGame extends FlameGame with HasKeyboardHandlerComponents, HasCollisionDetection {
  late final Player player;

  @override
  Future<void> onLoad() async {
    // Adiciona rochas
    add(RockComponent(rockName: 'Basalto', position: Vector2(100, 100), size: Vector2(40, 40)));
    add(RockComponent(rockName: 'Granito', position: Vector2(size.x - 100, size.y - 100), size: Vector2(40, 40)));

    // Adiciona NPC
    add(NpcComponent(npcName: 'Dra. Terra', position: Vector2(size.x - 100, 100), size: Vector2(50, 50)));

    // `size / 2` posiciona o player no centro da tela.
    // Funciona corretamente porque o Player usa Anchor.center.
    player = Player()..position = size / 2;

    add(player);
  }
}