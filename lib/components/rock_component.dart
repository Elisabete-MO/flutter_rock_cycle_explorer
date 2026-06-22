import 'dart:ui' as ui show Image;

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

/// Rocha na fase de coleta (corrida automática).
///
/// Exibe o ícone recortado da rocha com bordas irregulares (transparência PNG)
/// mantendo a colisão retangular via [RectangleHitbox].
///
/// A imagem deve ser pré-carregada e passada pelo spawning code (ver
/// [RockCycleGame._spawnAutoRunRocks]).
class RockComponent extends PositionComponent {
  final String rockName;
  final String rockId;
  final ui.Image rockImage;

  RockComponent({
    required this.rockName,
    required this.rockId,
    required this.rockImage,
    required super.position,
    required super.size,
  }) : super(anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    final aspect = rockImage.width / rockImage.height;
    final targetH = size.y;
    size.setValues(targetH * aspect, targetH);

    final sprite = SpriteComponent()
      ..sprite = Sprite(rockImage)
      ..size = size
      ..anchor = Anchor.center;
    add(sprite);

    add(RectangleHitbox());
  }
}
