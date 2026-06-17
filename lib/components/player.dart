import 'package:flame/components.dart';
import 'package:flame/palette.dart';

class Player extends RectangleComponent {
  Player()
      : super(
          size: Vector2.all(50),
          paint: BasicPalette.blue.paint(),
        );
}