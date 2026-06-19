import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/palette.dart';

class NpcComponent extends RectangleComponent {
  final String npcName;

  /// Linhas de diálogo deste NPC. O [RockCycleGame] lê estas linhas
  /// quando o jogador colide com o NPC e as repassa ao [GameState].
  final List<String> dialogueLines;

  /// Diálogo inicial da Dra. Terra para o MVP.
  static const List<String> draTerraInitialDialogue = [
    'Bem-vinda, Dra. Sophia! A expedição está pronta.',
    'Precisamos catalogar as rochas da ilha para entender '
        'sua história geológica.',
    'Explore os biomas: Vulcão, Cânion, Caverna e Montanha.',
    'Cada amostra coletada deve ser trazida à base para análise.',
    'Sua primeira missão: vá até o Vulcão e encontre Basalto!',
  ];

  NpcComponent({
    required this.npcName,
    required this.dialogueLines,
    required super.position,
    required super.size,
  }) : super(
          paint: BasicPalette.green.paint(), // Cor diferente para o NPC
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    // Adiciona a caixa de colisão do tamanho do componente
    add(RectangleHitbox());
  }
}
