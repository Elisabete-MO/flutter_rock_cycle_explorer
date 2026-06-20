import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/palette.dart';

class NpcComponent extends RectangleComponent {
  final String npcName;

  NpcComponent({
    required this.npcName,
    required super.position,
    required super.size,
  }) : super(
          paint: BasicPalette.green.paint(),
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox());
  }
}
