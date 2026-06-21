import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import '../components/player.dart';
import '../components/rock_component.dart';
import '../models/game_state.dart';

/// Loop principal do Rock Cycle Explorer.
///
/// Gerencia três fases via [GamePhase]:
/// - [GamePhase.lab]: tela estática com fundo de laboratório.
///   O jogador vê apenas o overlay Flutter — o mundo Flame fica oculto.
/// - [GamePhase.exploration]: mundo com movimentação, coleta de rochas.
/// - [GamePhase.microscope]: tela estática com fundo de microscópio.
class RockCycleGame extends FlameGame
    with HasKeyboardHandlerComponents, HasCollisionDetection {
  final GameState gameState;

  late final Player player;

  RockCycleGame({required this.gameState});

  @override
  Future<void> onLoad() async {
    _addQuestRocks();

    // ── Jogador ────────────────────────────────────────────────────
    player = Player()..position = size / 2;
    add(player);

    // ── Inicia no laboratório ──────────────────────────────────────
    showLab();
  }

  void _addQuestRocks() {
    add(
      RockComponent(
        rockName: 'Basalto',
        rockId: 'basalt',
        position: Vector2(150, 150),
        size: Vector2(40, 40),
      ),
    );
    add(
      RockComponent(
        rockName: 'Obsidiana',
        rockId: 'obsidian',
        position: Vector2(size.x - 150, size.y - 150),
        size: Vector2(40, 40),
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════
  //  GERENCIAMENTO DE OVERLAYS / FASES
  // ═════════════════════════════════════════════════════════════════

  /// Abre o laboratório (tela estática, sem movimentação).
  /// O overlay 'lab' cobre todo o jogo Flame.
  void showLab() {
    hideHud();
    overlays.add('lab');
    gameState.setPhase(GamePhase.lab);
  }

  /// Fecha o laboratório e inicia a fase de exploração.
  void closeLabAndStartExploration() {
    overlays.remove('lab');
    showHud();
    gameState.setPhase(GamePhase.exploration);
  }

  /// Mostra o overlay de resultado da coleta.
  void showCollectionResult() {
    overlays.add('collectionResult');
  }

  /// Volta ao laboratório após a coleta.
  void returnToLab() {
    overlays.remove('collectionResult');
    showLab();
    gameState.startPostCollectionDialogue();
    showDialogue();
  }

  /// Abre a Bag de amostras (dentro do laboratório).
  void showBag() {
    overlays.add('bag');
  }

  /// Fecha a Bag e abre o microscópio (analysis overlay).
  void openMicroscope() {
    overlays.remove('bag');
    overlays.add('analysis');
    gameState.setPhase(GamePhase.microscope);
  }

  /// Transição: analysis → classification.
  /// Preserva currentSample.
  void transitionToClassification() {
    overlays.remove('analysis');
    overlays.add('classification');
  }

  /// Fecha a classificação e volta ao laboratório.
  void closeClassificationAndReturnToLab() {
    overlays.remove('classification');
    showLab();
    if (gameState.startClassificationFeedbackDialogue()) {
      showDialogue();
    }
  }

  /// Abre o overlay de vitória.
  void showVictory() {
    overlays.remove('lab');
    overlays.remove('dialogue');
    overlays.add('victory');
  }

  /// Restaura integralmente o estado e os componentes da primeira quest.
  void restartAdventure() {
    overlays.remove('victory');
    overlays.remove('dialogue');
    overlays.remove('bag');
    overlays.remove('analysis');
    overlays.remove('classification');
    overlays.remove('collectionResult');
    hideHud();
    gameState.reset();
    _addQuestRocks();
    player.position = size / 2;
    showLab();
  }

  /// HUD
  void showHud() => overlays.add('hud');
  void hideHud() => overlays.remove('hud');

  /// Diálogo
  void startDialogue(List<String> lines) {
    gameState.startDialogue(lines);
    showDialogue();
  }

  void showDialogue() => overlays.add('dialogue');
  void hideDialogue() => overlays.remove('dialogue');

  // ═════════════════════════════════════════════════════════════════
  //  SISTEMA DE INTERAÇÕES
  // ═════════════════════════════════════════════════════════════════

  void onPlayerCollided(PositionComponent other) {
    if (other is RockComponent) {
      _handleRockContact(other);
    }
  }

  void _handleRockContact(RockComponent rock) {
    // Coleta a rocha durante a exploração
    gameState.collectInField(rock.rockId);

    // Remove do mundo (já coletada)
    rock.removeFromParent();

    // Se todas as amostras foram coletadas, exibe resultado
    if (gameState.hasCollectedAllRequired) {
      gameState.finalizeCollection();
      showCollectionResult();
    }
  }
}
