import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/palette.dart';

class RockComponent extends RectangleComponent {
  final String rockName;

  RockComponent({
    required this.rockName,
    required super.position,
    required super.size,
  }) : super(
          paint: BasicPalette.gray.paint(),
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    // Adiciona a caixa de colisão do tamanho do componente
    add(RectangleHitbox());
  }
}
