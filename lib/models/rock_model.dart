enum RockType {
  igneous,
  sedimentary,
  metamorphic;

  String get displayName {
    switch (this) {
      case RockType.igneous:
        return 'Ignea';
      case RockType.sedimentary:
        return 'Sedimentar';
      case RockType.metamorphic:
        return 'Metamorfica';
    }
  }
}

class RockModel {
  final String id;
  final String name;
  final RockType type;
  final String description;
  final List<String> clues;
  final String spriteName;
  final bool hasCrystals;
  final bool hasLayers;
  final bool hasFossils;
  final bool hasBands;

  const RockModel({
    required this.id,
    required this.name,
    required this.type,
    required this.description,
    required this.clues,
    required this.spriteName,
    required this.hasCrystals,
    required this.hasLayers,
    required this.hasFossils,
    required this.hasBands,
  });

  /// Busca um [RockModel] pelo [id] na lista [defaultRocks].
  /// Retorna `null` se nenhuma rocha com o ID fornecido for encontrada.
  static RockModel? byId(String id) {
    for (final rock in defaultRocks) {
      if (rock.id == id) return rock;
    }
    return null;
  }

  /// Lista padrão de rochas do ciclo para o MVP
  static List<RockModel> get defaultRocks => const [
        RockModel(
          id: 'basalt',
          name: 'Basalto',
          type: RockType.igneous,
          description: 'Formado pelo resfriamento rápido da lava na superfície terrestre.',
          hasCrystals: false,
          hasLayers: false,
          hasFossils: false,
          hasBands: false,
          clues: [
            'Cor muito escura (cinza escuro a preto).',
            'Textura mineral extremamente fina (grãos não visíveis a olho nu).',
            'Comum em regiões de vulcanismo ativo.',
          ],
          spriteName: 'imgs/rocks/basalt.jpeg',
        ),
        RockModel(
          id: 'granite',
          name: 'Granito',
          type: RockType.igneous,
          description: 'Formado pelo resfriamento lento do magma sob a crosta terrestre, permitindo o crescimento de cristais.',
          hasCrystals: true,
          hasLayers: false,
          hasFossils: false,
          hasBands: false,
          clues: [
            'Textura grossa com cristais visíveis a olho nu.',
            'Padrão salpicado com tons de rosa, branco e preto.',
            'Contém minerais como quartzo, feldspato e mica.',
          ],
          spriteName: 'imgs/rocks/granite.png',
        ),
        RockModel(
          id: 'sandstone',
          name: 'Arenito',
          type: RockType.sedimentary,
          description: 'Formado pelo acúmulo, compactação e cimentação de grãos de areia ao longo de milhares de anos.',
          hasCrystals: false,
          hasLayers: true,
          hasFossils: false,
          hasBands: false,
          clues: [
            'Textura arenosa e áspera ao toque.',
            'Presença de camadas visíveis de deposição de sedimentos.',
            'Composto principalmente de grãos de quartzo.',
          ],
          spriteName: 'imgs/rocks/sandstone.png',
        ),
        RockModel(
          id: 'limestone',
          name: 'Calcário',
          type: RockType.sedimentary,
          description: 'Formado pelo acúmulo de fragmentos de carbonato de cálcio, frequentemente originados de conchas e esqueletos de organismos marinhos.',
          hasCrystals: false,
          hasLayers: true,
          hasFossils: true,
          hasBands: false,
          clues: [
            'Pode conter fósseis minúsculos ou impressões de conchas.',
            'Cor geralmente clara (cinza claro, branco ou bege).',
            'Reage quimicamente com ácidos suaves liberando bolhas.',
          ],
          spriteName: 'imgs/rocks/limestone.png',
        ),
        RockModel(
          id: 'gneiss',
          name: 'Gneisse',
          type: RockType.metamorphic,
          description: 'Uma rocha que sofreu intensa pressão e calor, gerando uma segregação de minerais em bandas claras e escuras.',
          hasCrystals: true,
          hasLayers: false,
          hasFossils: false,
          hasBands: true,
          clues: [
            'Textura foliada com bandas paralelas alternadas de cores claras e escuras.',
            'Formada a partir da transformação física de rochas como o Granito.',
            'Cristais alinhados perpendicularmente à direção da pressão sofrida.',
          ],
          spriteName: 'imgs/rocks/gneiss.png',
        ),
        RockModel(
          id: 'marble',
          name: 'Mármore',
          type: RockType.metamorphic,
          description: 'Formado pela recristalização do Calcário sob condições de alta temperatura e pressão moderada.',
          hasCrystals: true,
          hasLayers: false,
          hasFossils: false,
          hasBands: false,
          clues: [
            'Textura cristalina e homogênea.',
            'Cores variadas, frequentemente branca com veios cinzas ou coloridos.',
            'Textura macia o suficiente para ser esculpida facilmente.',
          ],
          spriteName: 'imgs/rocks/marble.png',
        ),
        RockModel(
          id: 'obsidian',
          name: 'Obsidiana',
          type: RockType.igneous,
          description: 'Rocha ígnea vulcânica de textura vítrea, formada pelo resfriamento muito rápido da lava.',
          hasCrystals: false,
          hasLayers: false,
          hasFossils: false,
          hasBands: false,
          clues: [
            'Amostra escura com brilho vítreo.',
            'Superfície lisa, parecida com vidro natural.',
            'Não apresenta camadas, fósseis ou bandas.',
          ],
          spriteName: 'imgs/rocks/obsidian.jpg',
        ),
      ];
}
