import 'dart:async';
import 'dart:ui' as ui show Image;

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import '../components/end_level_marker.dart';
import '../components/player.dart';
import '../components/rock_component.dart';
import '../models/game_state.dart';
import '../services/audio_service.dart';

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
  final AudioService audioService;

  late final Player player;

  // ═══════════════════════════════════════════════════════════════════
  //  POSIÇÕES RESPONSIVAS DA FASE DE CORRIDA
  //  Todas as coordenadas usam percentuais do [size] do canvas em vez
  //  de valores fixos, garantindo funcionamento em mobile paisagem.
  // ═══════════════════════════════════════════════════════════════════

  /// Altura do chão para as rochas — percentual do canvas (fixo 0.78).
  /// As rochas não devem ser rebaixadas junto com o player.
  double get runnerGroundY => size.y * 0.78;

  /// Altura do chão para o player — mais baixa que [runnerGroundY] para
  /// alinhar os pés da Sophia com a plataforma rochosa do background.
  double get runnerPlayerGroundY {
    final isCompact = size.x < 900 && size.x > size.y;
    return isCompact ? size.y * 1.02 : size.y * 1.04;
  }

  /// Posição horizontal inicial da Sophia.
  double get runnerPlayerStartX => size.x * 0.10;

  /// Limite direito da fase (quando atingido, a coleta termina).
  double get runnerLevelEndX => size.x - 60;

  /// Posição horizontal do Basalto (no chão).
  double get runnerBasaltX => size.x * 0.35;

  /// Posição horizontal da Obsidiana (elevada, pulo simples).
  double get runnerObsidianX => size.x * 0.65;

  // ═══════════════════════════════════════════════════════════════════
  //  ESTADO INTERNO
  // ═══════════════════════════════════════════════════════════════════

  ui.Image? _vulcanImage;
  Future<ui.Image>? _vulcanFuture;
  ui.Image? _basaltImage;
  ui.Image? _obsidianImage;
  ui.Image? _endMarkerImage;
  Future<ui.Image>? _basaltFuture;
  Future<ui.Image>? _obsidianFuture;
  Future<ui.Image>? _endMarkerFuture;
  SpriteComponent? _background;

  RockCycleGame({required this.gameState, required this.audioService}) {
    // Flame 1.37 adiciona prefixo 'assets/images/' por padrão. Como todos os
    // assets do projeto são declarados sem esse prefixo no pubspec.yaml,
    // limpamos o prefixo para que os paths resolvam direto da raiz do Flutter.
    images.prefix = '';
  }

  @override
  Future<void> onLoad() async {
    // ── Inicializa áudio (defensivo, não bloqueia o jogo) ─────────
    await audioService.init();

    // ── Pré-carrega imagens (em background, não bloqueia o lab) ──────
    _vulcanFuture = images.load('imgs/bcgs/vulcan.png');
    _vulcanFuture!.then((img) => _vulcanImage = img);

    _basaltFuture = images.load('imgs/icons/basalto_icon.png');
    _basaltFuture!.then((img) => _basaltImage = img);

    _obsidianFuture = images.load('imgs/icons/obsidian_icon.png');
    _obsidianFuture!.then((img) => _obsidianImage = img);

    _endMarkerFuture = images.load('imgs/icons/end_level_icon.png');
    _endMarkerFuture!.then((img) => _endMarkerImage = img);

    // ── Jogador ────────────────────────────────────────────────────
    // Posição inicial arbitrária (coberta pelo overlay do lab)
    player = Player()..position = size / 2;
    add(player);

    // ── Inicia na tela inicial ─────────────────────────────────────
    showStartScreen();
  }

  /// Chamado pelo Flame quando o canvas é redimensionado ou a orientação
  /// muda. Recalcula posições para manter a fase responsiva.
  @override
  void onGameResize(Vector2 newSize) {
    super.onGameResize(newSize);

    // Redimensiona o background para cobrir a nova área
    if (_background != null) {
      _background!.size = newSize;
    }

    // Se estiver na fase de exploração, recalcula posições dos elementos
    if (gameState.phase == GamePhase.exploration) {
      _repositionAutoRunElements(newSize);
    }
  }

  /// Recalcula posições do jogador e das rochas após redimensionamento.
  void _repositionAutoRunElements(Vector2 newSize) {
    // Player: usa groundY rebaixado para alinhar com a plataforma
    final isCompact = newSize.x < 900 && newSize.x > newSize.y;
    final gyPlayer = isCompact ? newSize.y * 1.02 : newSize.y * 1.04;
    Player.groundY = gyPlayer;
    player.resetForAutoRun(
      Vector2(newSize.x * 0.10, gyPlayer),
      newSize.x - 60,
    );

    // Rochas: mantêm o groundY original (não rebaixado)
    final gyRocks = newSize.y * 0.78;
    final rocks = children.query<RockComponent>();
    for (final rock in rocks) {
      if (rock.rockId == 'basalt') {
        rock.position = Vector2(newSize.x * 0.35, gyRocks);
      } else if (rock.rockId == 'obsidian') {
        rock.position = Vector2(newSize.x * 0.65, gyRocks - 80);
      }
    }

    // Marco final: reposiciona perto do fim da fase
    final markers = children.query<EndLevelMarker>();
    for (final marker in markers) {
      marker.position = Vector2(newSize.x - 90, gyRocks);
    }
  }

  // ═════════════════════════════════════════════════════════════════
  //  GERENCIAMENTO DE OVERLAYS / FASES
  // ═════════════════════════════════════════════════════════════════

  /// Abre a tela inicial.
  /// O overlay 'start' cobre todo o jogo Flame com o background de abertura.
  /// Tenta tocar a música de abertura (pode falhar no Web se autoplay estiver
  /// bloqueado — o áudio é seguro e não quebra o jogo).
  void showStartScreen() {
    overlays.remove('lab');
    hideHud();
    overlays.add('start');
    unawaited(audioService.playOpeningTheme());
  }

  /// Transiciona da tela inicial para o laboratório e inicia
  /// automaticamente o diálogo inicial da Dra. Terra.
  void startGame() {
    unawaited(audioService.stopOpeningTheme());
    overlays.remove('start');
    showLab();
    gameState.startInitialDialogue();
    showDialogue();
  }

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
    unawaited(audioService.playVolcanoAmbience());
  }

  /// Mostra o overlay de resultado da coleta.
  void showCollectionResult() {
    if (gameState.hasCollectedAllRequired) {
      unawaited(audioService.playWin());
    } else {
      unawaited(audioService.playFail());
    }
    overlays.add('collectionResult');
  }

  /// Volta ao laboratório após a coleta.
  void returnToLab() {
    unawaited(audioService.stopVolcanoAmbience());
    _cleanupAutoRun();
    overlays.remove('collectionResult');
    showLab();
    gameState.startPostCollectionDialogue();
    showDialogue();
  }

  /// Abre a Bag de amostras (dentro do laboratório).
  void showBag() {
    unawaited(audioService.playBag());
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
    unawaited(audioService.playWin());
  }

  /// Abre o Diário de Campo.
  void showFieldBook() {
    unawaited(audioService.playBag());
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

    // Garante que as imagens foram carregadas antes de montar a cena
    if (_vulcanImage == null && _vulcanFuture != null) {
      _vulcanImage = await _vulcanFuture;
    }
    if (_basaltImage == null && _basaltFuture != null) {
      _basaltImage = await _basaltFuture;
    }
    if (_obsidianImage == null && _obsidianFuture != null) {
      _obsidianImage = await _obsidianFuture;
    }
    if (_endMarkerImage == null && _endMarkerFuture != null) {
      _endMarkerImage = await _endMarkerFuture;
    }
    _addBackground();

    _spawnAutoRunRocks();
    _spawnEndMarker();
    Player.groundY = runnerPlayerGroundY;
    player.resetForAutoRun(
      Vector2(runnerPlayerStartX, runnerPlayerGroundY),
      runnerLevelEndX,
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
    final gy = runnerGroundY;

    // Basalto — no chão, sem precisar pular
    if (_basaltImage != null) {
      add(RockComponent(
        rockName: 'Basalto',
        rockId: 'basalt',
        rockImage: _basaltImage!,
        position: Vector2(runnerBasaltX, gy),
        size: Vector2(44, 44),
      )..priority = 5);
    }
    // Obsidiana — acima do chão (alcançável com um pulo), precisa pular
    if (_obsidianImage != null) {
      add(RockComponent(
        rockName: 'Obsidiana',
        rockId: 'obsidian',
        rockImage: _obsidianImage!,
        position: Vector2(runnerObsidianX, gy - 80),
        size: Vector2(44, 44),
      )..priority = 5);
    }
  }

  /// Cria o marco visual de fim de fase próximo ao limite direito.
  void _spawnEndMarker() {
    if (_endMarkerImage == null) return;
    final markerSize = Vector2(size.x * 0.05, size.y * 0.08);
    final markerX = runnerLevelEndX - 30;
    final markerY = runnerGroundY;
    add(EndLevelMarker(
      markerImage: _endMarkerImage!,
      position: Vector2(markerX, markerY),
      size: markerSize,
    ));
  }

  /// Remove componentes da corrida (fundo, rochas, marco final).
  void _cleanupAutoRun() {
    _background?.removeFromParent();
    _background = null;
    final rocks = children.query<RockComponent>();
    for (final rock in rocks) {
      rock.removeFromParent();
    }
    final markers = children.query<EndLevelMarker>();
    for (final marker in markers) {
      marker.removeFromParent();
    }
  }

  /// Reinicia a fase de corrida (usado pelo botão "Tentar Novamente").
  Future<void> retryAutoRun() async {
    unawaited(audioService.stopVolcanoAmbience());
    overlays.remove('collectionResult');
    gameState.resetCollection();
    await _startAutoRun();
    showHud();
    gameState.setPhase(GamePhase.exploration);
    unawaited(audioService.playVolcanoAmbience());
  }

  /// Restaura integralmente o estado e retorna à tela inicial.
  void restartAdventure() {
    unawaited(audioService.stopAll());
    _cleanupAutoRun();
    overlays.remove('victory');
    overlays.remove('dialogue');
    overlays.remove('bag');
    overlays.remove('analysis');
    overlays.remove('classification');
    overlays.remove('collectionResult');
    overlays.remove('lab');
    hideHud();
    gameState.reset();
    player.position = size / 2;
    showStartScreen();
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
    // Coleta a rocha durante a exploração — sem encerrar a fase.
    // O resultado só será exibido quando Sophia atingir o marco final.
    gameState.collectInField(rock.rockId);
    rock.removeFromParent();
    unawaited(audioService.playCollect());
  }

  /// Chamado pelo [Player] quando atinge o fim da pista.
  void onPlayerReachedEnd() {
    if (gameState.phase != GamePhase.exploration) return;
    gameState.finalizeCollection();
    showCollectionResult();
  }
}
