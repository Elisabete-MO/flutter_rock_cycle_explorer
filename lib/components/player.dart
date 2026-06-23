import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/services.dart';

import '../game/rock_cycle_game.dart';
import '../models/game_state.dart';

/// Dra. Sophia — componente do jogador no modo corrida automática.
///
/// Na fase [GamePhase.exploration]:
/// - Sophia corre automaticamente para a direita.
/// - O jogador controla apenas o pulo (espaço / seta p/ cima / W).
/// - Gravidade puxa Sophia para baixo; o chão invisível a segura em [groundY].
/// - Colisões com [RockComponent] são delegadas ao jogo via [onPlayerCollided].
///
/// Renderiza sprites de acordo com o estado:
/// - `sophia_walking.png` no chão (com bobbing visual leve e inclinação)
/// - `sophia_jumping.png` no ar
///
/// Fora da fase exploration o componente fica inerte (não se move).
class Player extends PositionComponent
    with KeyboardHandler, HasGameReference<RockCycleGame>, CollisionCallbacks {
  // ═══════════════════════════════════════════════════════════════════
  //  CONSTANTES CONFIGURÁVEIS
  // ═══════════════════════════════════════════════════════════════════

  /// Velocidade horizontal automática da corrida (px/s).
  static const double autoRunSpeed = 120.0;

  /// Velocidade vertical inicial do pulo (negativo = para cima).
  static const double jumpVelocity = -420.0;

  /// Aceleração gravitacional (px/s²).
  static const double gravity = 800.0;

  /// Posição Y do chão — pés da Sophia. Trocado dinamicamente pelo game.
  static double groundY = 500.0;

  /// Limite direito da fase.
  static double endX = 0;

  // ═══════════════════════════════════════════════════════════════════
  //  TAMANHO RESPONSIVO
  // ═══════════════════════════════════════════════════════════════════

  /// Compacto (mobile paisagem): mantém o tamanho atual.
  static const double _compactHeightFactor = 0.24;
  static const double _compactMinHeight = 80.0;
  static const double _compactMaxHeight = 100.0;

  /// Desktop / telas largas: ≈12% maior que o compacto.
  static const double _desktopHeightFactor = 0.27;
  static const double _desktopMinHeight = 90.0;
  static const double _desktopMaxHeight = 160.0;

  static const double _spriteAspect = 1024.0 / 1536.0;
  static const double _compactWidthThreshold = 900.0;

  // ═══════════════════════════════════════════════════════════════════
  //  SPRITES
  // ═══════════════════════════════════════════════════════════════════

  static const String _walkingSpritePath =
      'imgs/characters/mov_sophia/sophia_walking.png';
  static const String _jumpingSpritePath =
      'imgs/characters/mov_sophia/sophia_jumping.png';

  Sprite? _walkingSprite;
  Sprite? _jumpingSprite;
  late final SpriteComponent _spriteVisual;
  bool _spritesReady = false;

  // ═══════════════════════════════════════════════════════════════════
  //  BOBBING / TILT (visual apenas — sem impacto na física)
  // ═══════════════════════════════════════════════════════════════════

  double _bobTime = 0;
  static const double _bobFrequency = 10.0;
  static const double _bobAmplitude = 3.0;
  static const double _tiltAngle = 0.07;

  // ═══════════════════════════════════════════════════════════════════
  //  ESTADO INTERNO
  // ═══════════════════════════════════════════════════════════════════

  final Vector2 _velocity = Vector2.zero();
  bool _isOnGround = false;
  bool _endReached = false;

  // ═══════════════════════════════════════════════════════════════════
  //  CONSTRUTOR
  // ═══════════════════════════════════════════════════════════════════

  Player()
      : super(
          size: Vector2(32, 48),
          anchor: Anchor.bottomCenter,
          priority: 10,
        );

  // ═══════════════════════════════════════════════════════════════════
  //  CICLO DE VIDA
  // ═══════════════════════════════════════════════════════════════════

  @override
  Future<void> onLoad() async {
    // Tamanho responsivo conforme canvas
    _updateSizeFromGame();

    // Carrega sprites (com fallback seguro)
    try {
      final results = await Future.wait([
        Sprite.load(_walkingSpritePath),
        Sprite.load(_jumpingSpritePath),
      ]);
      _walkingSprite = results[0];
      _jumpingSprite = results[1];
      _spritesReady = true;
    } catch (_) {
      _walkingSprite = Sprite(await _createFallbackImage());
      _jumpingSprite = _walkingSprite;
    }

    _spriteVisual = SpriteComponent(
      sprite: _walkingSprite,
      size: size,
      anchor: Anchor.bottomCenter,
    );
    add(_spriteVisual);

    add(RectangleHitbox());
  }

  void _updateSizeFromGame() {
    final gs = game.size;
    if (gs.x <= 0 || gs.y <= 0) return;

    final isCompact = gs.x < _compactWidthThreshold && gs.x > gs.y;

    final targetHeight = isCompact
        ? (gs.y * _compactHeightFactor).clamp(_compactMinHeight, _compactMaxHeight)
        : (gs.y * _desktopHeightFactor).clamp(_desktopMinHeight, _desktopMaxHeight);

    size = Vector2(targetHeight * _spriteAspect, targetHeight);
  }

  Future<ui.Image> _createFallbackImage() async {
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(
      recorder,
      ui.Rect.fromLTWH(0, 0, size.x, size.y),
    );
    canvas.drawRect(
      ui.Rect.fromLTWH(0, 0, size.x, size.y),
      ui.Paint()..color = const ui.Color(0xFF4488FF),
    );
    final picture = recorder.endRecording();
    return picture.toImage(size.x.toInt(), size.y.toInt());
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    game.onPlayerCollided(other);
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (game.gameState.phase != GamePhase.exploration) return;
    if (_endReached) return;

    // ── Gravidade ──────────────────────────────────────────────────
    if (!_isOnGround) {
      _velocity.y += gravity * dt;
    }

    // ── Corrida automática ─────────────────────────────────────────
    _velocity.x = autoRunSpeed;

    // ── Aplica velocidade (física real) ────────────────────────────
    position += _velocity * dt;

    // ── Colisão com o chão ─────────────────────────────────────────
    if (position.y >= groundY) {
      position.y = groundY;
      _velocity.y = 0;
      _isOnGround = true;
    }

    // ── Limite esquerdo ────────────────────────────────────────────
    final halfW = size.x / 2;
    if (position.x < halfW) {
      position.x = halfW;
      _velocity.x = math.max(0, _velocity.x);
    }

    // ── Limite direito (fim da fase) ────────────────────────────────
    if (endX > 0 && position.x >= endX) {
      position.x = endX;
      _velocity.x = 0;
      _velocity.y = 0;
      if (!_endReached) {
        _endReached = true;
        game.onPlayerReachedEnd();
      }
    }

    // ── Visual: sprite + bobbing (só no child, não afeta hitbox) ──
    _updateVisual(dt);
  }

  void _updateVisual(double dt) {
    if (!_spritesReady) return;

    if (_isOnGround) {
      // Correndo no chão
      if (_spriteVisual.sprite != _walkingSprite) {
        _spriteVisual.sprite = _walkingSprite;
      }
      _bobTime += dt;
      final bob = math.sin(_bobTime * _bobFrequency) * _bobAmplitude;
      _spriteVisual.position.y = -bob;
      _spriteVisual.angle = _tiltAngle;
    } else {
      // Pulando / no ar
      if (_spriteVisual.sprite != _jumpingSprite) {
        _spriteVisual.sprite = _jumpingSprite;
      }
      _spriteVisual.position.y = 0;
      _spriteVisual.angle = 0;
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  //  ENTRADA DE TECLADO
  // ═══════════════════════════════════════════════════════════════════

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (event is KeyDownEvent) {
      if (keysPressed.contains(LogicalKeyboardKey.space) ||
          keysPressed.contains(LogicalKeyboardKey.arrowUp) ||
          keysPressed.contains(LogicalKeyboardKey.keyW)) {
        _jump();
      }
    }
    return false;
  }

  // ═══════════════════════════════════════════════════════════════════
  //  HELPERS
  // ═══════════════════════════════════════════════════════════════════

  void _jump() {
    if (_isOnGround && game.gameState.phase == GamePhase.exploration) {
      _velocity.y = jumpVelocity;
      _isOnGround = false;
    }
  }

  /// Prepara o jogador para uma nova corrida.
  void resetForAutoRun(Vector2 startPosition, double levelEndX) {
    position = startPosition;
    _velocity.setValues(autoRunSpeed, 0);
    _isOnGround = true;
    _endReached = false;
    endX = levelEndX;
    _bobTime = 0;
  }

  /// Para o jogador imediatamente.
  void stop() {
    _velocity.setValues(0, 0);
    _endReached = true;
  }
}