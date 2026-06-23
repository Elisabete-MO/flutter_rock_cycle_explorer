import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flame/components.dart';

/// Marco visual de fim de fase na coleta do vulcão.
///
/// Aparece próximo ao [RockCycleGame.runnerLevelEndX] para indicar
/// visualmente o ponto de chegada. Quando Sophia o alcança (via colisão
/// com o limite [Player.endX]), o resultado da coleta é exibido.
///
/// Possui dois destaques visuais:
/// - **Glow pulsante**: círculo dourado atrás do ícone que pulsa em
///   intensidade (opacidade oscila entre 15% e 40%).
/// - **Bobbing vertical**: o conjunto glow + ícone flutua suavemente
///   para dar sensação de "vitalidade" ao marco.
///
/// ### Estrutura interna (tudo relativo à origem do pai)
///
/// O pai usa [Anchor.bottomCenter], portanto a origem `(0, 0)` é o
/// canto inferior-central do marcador. Ambos os filhos compartilham
/// o centro visual em `(0, -size.y / 2)`:
///
///    ┌──────────────────┐
///    │                  │
///    │   ╭────(0,-h/2)──╮  ← glow (Anchor.center) posicionado aqui
///    │   │     🏁       │  ← ícone centro visual aqui
///    │   ╰──────────────╯
///    │                  │
///    └───────●(0,0)─────┘  ← origem = bottom-center, ícone bottom aqui
///
/// Prioridade global: 6 (acima das rochas = 5, abaixo do player = 10).
class EndLevelMarker extends PositionComponent {
  final ui.Image markerImage;

  double _animTime = 0;
  late final SpriteComponent _sprite;
  late final CircleComponent _glow;

  /// Centro visual do pai no sistema de coordenadas local.
  /// Como o pai usa [Anchor.bottomCenter], o centro está a meia altura
  /// acima da origem: `(0, -size.y / 2)`.
  Vector2 get _visualCenter => Vector2(0, -size.y / 2);

  EndLevelMarker({
    required this.markerImage,
    required super.position,
    required super.size,
  }) : super(anchor: Anchor.bottomCenter, priority: 6);

  @override
  Future<void> onLoad() async {
    // ── Glow ────────────────────────────────────────────────────────
    // Círculo dourado com borrão, centrado atrás do ícone.
    final glowRadius = size.x * 0.65;
    _glow = CircleComponent(
      radius: glowRadius,
      paint: ui.Paint()
        ..color = const ui.Color(0xFFFFD700).withValues(alpha: 0.25)
        ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 10),
      anchor: Anchor.center,
      priority: -1, // atrás do ícone
    );
    _glow.position = _visualCenter; // centro alinhado com o ícone
    add(_glow);

    // ── Ícone ───────────────────────────────────────────────────────
    _sprite = SpriteComponent()
      ..sprite = Sprite(markerImage)
      ..size = size
      ..anchor = Anchor.bottomCenter;
    add(_sprite);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _animTime += dt;

    final centerY = _visualCenter.y;
    final bobY = math.sin(_animTime * 3.0) * 3.0;

    // Opacidade pulsante (glow)
    final pulse = 0.15 + 0.25 * (0.5 + 0.5 * math.sin(_animTime * 2.5));
    _glow.paint.color = const ui.Color(0xFFFFD700).withValues(alpha: pulse);

    // Bobbing sincronizado: glow e sprite sobem/descem juntos
    _sprite.position.y = bobY;
    _glow.position.y = centerY + bobY;
  }
}
