import 'dart:math' as math;
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/palette.dart';
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
/// Fora da fase exploration o componente fica inerte (não se move).
class Player extends RectangleComponent
    with KeyboardHandler, HasGameReference<RockCycleGame>, CollisionCallbacks {
  // ═══════════════════════════════════════════════════════════════════
  //  CONSTANTES CONFIGURÁVEIS
  // ═══════════════════════════════════════════════════════════════════

  /// Velocidade horizontal automática da corrida (px/s).
  /// Ajuste este valor para controlar a duração da fase.
  static const double autoRunSpeed = 120.0;

  /// Velocidade vertical inicial do pulo (negativo = para cima).
  static const double jumpVelocity = -420.0;

  /// Aceleração gravitacional (px/s²).
  static const double gravity = 800.0;

  /// Posição Y do chão — alinhar a "base" (pés) de Sophia à plataforma
  /// principal do background vulcânico. Como o anchor é [Anchor.bottomCenter],
  /// a position.y corresponde diretamente à linha do chão.
  static double groundY = 500.0;

  /// Limite direito da fase (quando atingido, a coleta termina).
  static double endX = 0;

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
          size: Vector2.all(40),
          paint: BasicPalette.blue.paint(),
          anchor: Anchor.bottomCenter,
          priority: 10,
        );

  // ═══════════════════════════════════════════════════════════════════
  //  CICLO DE VIDA
  // ═══════════════════════════════════════════════════════════════════

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox());
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

    // Só se move durante a exploração
    if (game.gameState.phase != GamePhase.exploration) return;

    // ── Já atingiu o fim da fase? ───────────────────────────────────
    if (_endReached) return;

    // ── Gravidade ──────────────────────────────────────────────────
    if (!_isOnGround) {
      _velocity.y += gravity * dt;
    }

    // ── Corrida automática ─────────────────────────────────────────
    _velocity.x = autoRunSpeed;

    // ── Aplica velocidade ──────────────────────────────────────────
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
  }

  /// Para o jogador imediatamente (usado quando a coleta é concluída).
  void stop() {
    _velocity.setValues(0, 0);
    _endReached = true;
  }
}