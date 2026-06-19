import 'dart:math' as math;
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/palette.dart';
import 'package:flutter/services.dart';

import '../game/rock_cycle_game.dart';

/// Dra. Sophia — componente do jogador (MVP placeholder visual).
///
/// Responsabilidades (Dia 2 MVP):
///  - Renderização como quadrado azul.
///  - Movimentação suave com WASD e teclas direcionais.
///  - Contenção dentro dos limites visíveis do jogo.
class Player extends RectangleComponent with KeyboardHandler, HasGameReference<RockCycleGame>, CollisionCallbacks {
  // ── Configuração ─────────────────────────────────────────────────────────
  static const double _speed = 200.0; // pixels por segundo

  // ── Estado interno ────────────────────────────────────────────────────────
  final Vector2 _velocity = Vector2.zero();

  // ── Construtor ────────────────────────────────────────────────────────────
  Player()
      : super(
          size: Vector2.all(50),
          paint: BasicPalette.blue.paint(),
          // Anchor.center faz com que `position` aponte para o centro do
          // sprite, simplificando o posicionamento e o cálculo de bordas.
          anchor: Anchor.center,
        );

  // ── Ciclo de vida ─────────────────────────────────────────────────────────

  @override
  Future<void> onLoad() async {
    // Adiciona o hitbox para permitir colisões
    add(RectangleHitbox());
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);

    // Delega a decisão ao game, que centraliza a lógica de interação.
    // O Player não precisa mais conhecer os tipos concretos dos componentes.
    game.onPlayerCollided(other);
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Aplica velocidade × delta time → movimento independente de frame rate.
    position += _velocity * dt;

    // ── Contenção de bordas ───────────────────────────────────────────────
    // Anchor.center → position aponta para o centro do sprite.
    // Logo, o centro pode variar de (halfW, halfH) até
    // (canvasWidth - halfW, canvasHeight - halfH).
    //
    // Guard: quando canvas < size (janela menor que o player), a expressão
    // (canvas - half) < half, tornando min > max no clamp → exceção Dart.
    // Usamos max(min, maxBound) para colapsar o intervalo para um único ponto
    // (o centro do canvas) sem lançar exceção.
    final halfW = size.x / 2;
    final halfH = size.y / 2;
    final canvas = game.canvasSize;

    final minX = halfW;
    final maxX = math.max(minX, canvas.x - halfW);
    final minY = halfH;
    final maxY = math.max(minY, canvas.y - halfH);

    position.x = position.x.clamp(minX, maxX);
    position.y = position.y.clamp(minY, maxY);
  }

  // ── Entrada de teclado ────────────────────────────────────────────────────

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    // Recalcula a velocidade toda vez que o estado das teclas muda.
    // Isso garante que soltar uma tecla pare o eixo correspondente.
    _updateVelocity(keysPressed);
    // Retorna false para não consumir o evento, permitindo que outros
    // componentes também o recebam se necessário.
    return false;
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  void _updateVelocity(Set<LogicalKeyboardKey> keysPressed) {
    double dx = 0;
    double dy = 0;

    // Horizontal
    if (keysPressed.contains(LogicalKeyboardKey.keyA) ||
        keysPressed.contains(LogicalKeyboardKey.arrowLeft)) {
      dx -= _speed;
    }
    if (keysPressed.contains(LogicalKeyboardKey.keyD) ||
        keysPressed.contains(LogicalKeyboardKey.arrowRight)) {
      dx += _speed;
    }

    // Vertical (y cresce para baixo no Flame)
    if (keysPressed.contains(LogicalKeyboardKey.keyW) ||
        keysPressed.contains(LogicalKeyboardKey.arrowUp)) {
      dy -= _speed;
    }
    if (keysPressed.contains(LogicalKeyboardKey.keyS) ||
        keysPressed.contains(LogicalKeyboardKey.arrowDown)) {
      dy += _speed;
    }

    // Normalização diagonal: impede que o jogador se mova ~41% mais rápido
    // ao pressionar dois eixos simultaneamente.
    _velocity.setValues(dx, dy);
    if (_velocity.length > _speed) {
      _velocity.normalize();
      _velocity.scale(_speed);
    }
  }
}