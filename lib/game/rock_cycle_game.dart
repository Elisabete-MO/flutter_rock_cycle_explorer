import 'dart:ui' as ui show Image;

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
/// - [GamePhase.exploration]: corrida automática no bioma do vulcão.
///   Sophia corre para a direita; o jogador controla apenas o pulo.
/// - [GamePhase.microscope]: tela estática com fundo de microscópio.
class RockCycleGame extends FlameGame
    with HasKeyboardHandlerComponents, HasCollisionDetection {
  final GameState gameState;

  late final Player player;

  // ═══════════════════════════════════════════════════════════════════
  //  CONSTANTES DA FASE DE CORRIDA
  // ═══════════════════════════════════════════════════════════════════

  /// Altura do chão — alinha a base (pés) de Sophia à plataforma
  /// principal do background vulcânico (imgs/bcgs/vulcan.png).
  /// O player usa [Anchor.bottomCenter], portanto position.y desta
  /// constante equivale diretamente à linha do chão.
  static const double groundY = 500;

  /// Posição horizontal inicial da Sophia (canto inferior do player
  /// alinhado a este X, já que o anchor é bottomCenter).
  static const double playerStartX = 80;

  // ═══════════════════════════════════════════════════════════════════
  //  ESTADO INTERNO
  // ═══════════════════════════════════════════════════════════════════

  ui.Image? _vulcanImage;
  Future<ui.Image>? _vulcanFuture;
  SpriteComponent? _background;

  RockCycleGame({required this.gameState});

  @override
  Future<void> onLoad() async {
    // ── Pré-carrega imagem de fundo (em background, não bloqueia o lab) ──
    _vulcanFuture = images.load('imgs/bcgs/vulcan.png');
    _vulcanFuture!.then((img) => _vulcanImage = img);

    // ── Jogador ────────────────────────────────────────────────────
    // Posição inicial arbitrária (coberta pelo overlay do lab)
    player = Player()..position = size / 2;
    add(player);

    // ── Inicia no laboratório ──────────────────────────────────────
    showLab();
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

  /// Fecha o laboratório e inicia a fase de corrida automática.
  Future<void> closeLabAndStartExploration() async {
    overlays.remove('lab');
    await _startAutoRun();
    showHud();
    gameState.setPhase(GamePhase.exploration);
  }

  /// Mostra o overlay de resultado da coleta.
  void showCollectionResult() {
    overlays.add('collectionResult');
  }

  /// Volta ao laboratório após a coleta.
  void returnToLab() {
    _cleanupAutoRun();
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

  /// Abre o Diário de Campo.
  void showFieldBook() {
    overlays.add('fieldBook');
  }

  /// Fecha o Diário de Campo (retorna ao laboratório).
  void closeFieldBook() {
    overlays.remove('fieldBook');
  }

  // ═════════════════════════════════════════════════════════════════
  //  FASE DE CORRIDA AUTOMÁTICA
  // ═════════════════════════════════════════════════════════════════

  /// Monta o cenário da corrida: fundo, chão, rochas, jogador.
  Future<void> _startAutoRun() async {
    _cleanupAutoRun();

    // Garante que o fundo foi carregado antes de montar a cena
    if (_vulcanImage == null && _vulcanFuture != null) {
      _vulcanImage = await _vulcanFuture;
    }
    _addBackground();

    _spawnAutoRunRocks();
    Player.groundY = groundY;
    player.resetForAutoRun(
      Vector2(playerStartX, groundY),
      size.x - 60, // levelEndX dinâmico = largura do canvas - margem
    );
  }

  void _addBackground() {
    if (_vulcanImage == null) return;
    _background = SpriteComponent()
      ..priority = -100 // atrás de tudo
      ..sprite = Sprite(_vulcanImage!)
      ..size = size
      ..position = Vector2.zero();
    add(_background!);
  }

  void _spawnAutoRunRocks() {
    // Basalto — no chão, sem precisar pular
    add(RockComponent(
      rockName: 'Basalto',
      rockId: 'basalt',
      position: Vector2(300, groundY),
      size: Vector2(30, 30),
    )..priority = 5);
    // Obsidiana — acima do chão (alcançável com um pulo), precisa pular
    add(RockComponent(
      rockName: 'Obsidiana',
      rockId: 'obsidian',
      position: Vector2(600, groundY - 80),
      size: Vector2(30, 30),
    )..priority = 5);
  }

  /// Remove componentes da corrida (fundo, rochas restantes).
  void _cleanupAutoRun() {
    _background?.removeFromParent();
    _background = null;
    final rocks = children.query<RockComponent>();
    for (final rock in rocks) {
      rock.removeFromParent();
    }
  }

  /// Reinicia a fase de corrida (usado pelo botão "Tentar Novamente").
  Future<void> retryAutoRun() async {
    overlays.remove('collectionResult');
    gameState.resetCollection();
    await _startAutoRun();
    showHud();
    gameState.setPhase(GamePhase.exploration);
  }

  /// Restaura integralmente o estado e os componentes da primeira quest.
  void restartAdventure() {
    _cleanupAutoRun();
    overlays.remove('victory');
    overlays.remove('dialogue');
    overlays.remove('bag');
    overlays.remove('analysis');
    overlays.remove('classification');
    overlays.remove('collectionResult');
    hideHud();
    gameState.reset();
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

    // Se todas as amostras foram coletadas, encerra a fase
    if (gameState.hasCollectedAllRequired) {
      player.stop();
      gameState.finalizeCollection();
      showCollectionResult();
    }
  }

  /// Chamado pelo [Player] quando atinge o fim da pista.
  void onPlayerReachedEnd() {
    if (gameState.phase != GamePhase.exploration) return;
    gameState.finalizeCollection();
    showCollectionResult();
  }
}
