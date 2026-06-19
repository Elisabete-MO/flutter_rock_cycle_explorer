import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import '../components/npc_component.dart';
import '../components/player.dart';
import '../components/rock_component.dart';
import '../models/game_state.dart';

/// Loop principal do Rock Cycle Explorer.
///
/// Mixins:
///  - [HasKeyboardHandlerComponents] → roteia eventos de teclado do Flutter
///    para todos os componentes que implementam [KeyboardHandler], como o
///    [Player]. Sem este mixin, as teclas nunca chegam ao player.
/// O [overlays] property (built-in do [FlameGame]) gerencia overlays do Flutter
/// via [overlays.add] / [overlays.remove]. Necessário para HUD e diálogo.
class RockCycleGame extends FlameGame
    with HasKeyboardHandlerComponents, HasCollisionDetection {
  // ── Dependências injetadas ──────────────────────────────────────────────────
  final GameState gameState;

  // ── Componentes ──────────────────────────────────────────────────────────────
  late final Player player;

  RockCycleGame({required this.gameState});

  @override
  Future<void> onLoad() async {
    // Adiciona rochas
    add(RockComponent(rockName: 'Basalto', position: Vector2(100, 100), size: Vector2(40, 40)));
    add(RockComponent(rockName: 'Granito', position: Vector2(size.x - 100, size.y - 100), size: Vector2(40, 40)));

    // Adiciona NPC com diálogo inicial
    add(NpcComponent(
      npcName: 'Dra. Terra',
      dialogueLines: NpcComponent.draTerraInitialDialogue,
      position: Vector2(size.x - 100, 100),
      size: Vector2(50, 50),
    ));

    // `size / 2` posiciona o player no centro da tela.
    // Funciona corretamente porque o Player usa Anchor.center.
    player = Player()..position = size / 2;

    add(player);

    // Ativa o HUD automaticamente quando o jogo inicia.
    showHud();
  }

  // ── Gerenciamento de Overlays ───────────────────────────────────────────────

  /// Ativa o overlay de HUD (XP, nível, quest ativa).
  void showHud() => overlays.add('hud');

  /// Desativa o overlay de HUD.
  void hideHud() => overlays.remove('hud');

  /// Ativa o overlay de diálogo com as falas fornecidas.
  /// As falas já devem ter sido carregadas no [GameState] antes da chamada.
  void showDialogue() => overlays.add('dialogue');

  /// Desativa o overlay de diálogo.
  void hideDialogue() => overlays.remove('dialogue');

  // ── Sistema Centralizado de Interações ──────────────────────────────────────

  /// Único ponto de entrada para todas as colisões do jogador.
  /// Cada tipo de componente sabe como reagir sem acoplar o Player.
  void onPlayerCollided(PositionComponent other) {
    if (other is NpcComponent) {
      _handleNpcContact(other);
    } else if (other is RockComponent) {
      _handleRockContact(other);
    }
    // Novos tipos de componente são adicionados AQUI, não no Player.
  }

  void _handleNpcContact(NpcComponent npc) {
    gameState.startDialogue(npc.dialogueLines);
    showDialogue();
  }

  void _handleRockContact(RockComponent rock) {
    // Placeholder para Dia 5+: coleta/análise da rocha.
    // Quando implementado, deve chamar gameState.registerFieldSample(...)
    // e/ou abrir o FieldLabOverlay.
  }
}