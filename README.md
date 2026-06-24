# 🪨 The Rock Keeper

The Rock Keeper é um jogo educacional 2D sobre rochas e observação científica. A experiência combina exploração, coleta de amostras, análise visual e classificação para apresentar conceitos de geologia de forma interativa.

> O nome público do jogo é **The Rock Keeper**. Alguns identificadores internos do projeto ainda usam o nome legado `rock_cycle_explorer`.

## 📖 Objetivo pedagógico

O jogo introduz conceitos básicos sobre rochas ígneas e vulcânicas por meio de um processo inspirado no trabalho científico: observar o ambiente, coletar amostras, analisar características, formular uma classificação e receber feedback.

No arco atual, o jogador aprende a reconhecer Basalto e Obsidiana a partir de evidências como textura, cristais, camadas, fósseis, bandas e brilho vítreo.

## ⚙️ Status do MVP

O MVP implementa a primeira quest de The Rock Keeper, ambientada no bioma do Vulcão. A missão acompanha a Dra. Sophia 👩‍🏫 na coleta, análise e catalogação de duas rochas vulcânicas:

- Basalto
- Obsidiana

O fluxo inclui tela inicial, laboratório, diálogos com a Dra. Terra, Diário de Campo, fase de coleta em formato auto-runner, microscópio, classificação, feedback pedagógico, progressão por XP e tela de vitória.

## 🎮 Fluxo de jogo

1. 🖥️ **Tela inicial:** o jogador inicia a aventura.
2. 🔬 **Laboratório:** a Dra. Terra apresenta a missão à Dra. Sophia e libera o Diário de Campo.
3. 🌋 **Coleta no Vulcão:** Sophia corre automaticamente pelo cenário; o jogador controla o pulo para coletar Basalto e Obsidiana antes do marco final.
4. 🪨 **Resultado da coleta:** uma coleta completa concede XP e permite retornar ao laboratório; se faltar uma amostra, a fase pode ser repetida.
5. 🎒 **Seleção da amostra:** no laboratório, a bolsa reúne as amostras disponíveis para análise.
6. 🔍 **Microscópio:** o jogador observa a imagem, as características e as pistas da amostra selecionada.
7. ⭐⭐⭐ **Classificação:** a amostra é classificada como ígnea, sedimentar ou metamórfica.
8. 🎓 **Feedback:** a Dra. Terra explica o resultado e registra a descoberta no Diário de Campo.
9. 📕 **Diário de Campo:** a seção de rochas vulcânicas reúne as amostras já analisadas; as demais categorias permanecem reservadas para missões futuras.
10. 🎉 **Vitória:** após catalogar Basalto e Obsidiana, a quest é concluída, o jogador recebe XP e pode reiniciar a aventura pela tela de vitória.

## 🛠️ Tecnologias e arquitetura

- **Flutter:** aplicação, telas e overlays de interface.
- **Flame:** loop do jogo, auto-runner, componentes, colisões e coleta.
- **Dart:** linguagem do projeto.
- **ChangeNotifier:** estado de inventário, XP, quest, diálogos e progresso em `GameState`.

O MVP tem como alvos principais a Web e dispositivos móveis Android/iOS. A interface exige orientação paisagem: em telas móveis, o aplicativo solicita essa orientação e bloqueia o gameplay enquanto o dispositivo estiver em modo retrato.

## 🚀 Como executar

Pré-requisitos:

- Flutter SDK compatível com o projeto.
- Chrome para execução Web ou um dispositivo/emulador móvel configurado.

Instale as dependências:

```bash
flutter pub get
```

Execute no Chrome:

```bash
flutter run -d chrome
```

Para executar em um dispositivo móvel conectado, consulte os dispositivos disponíveis e use o identificador desejado:

```bash
flutter devices
flutter run -d <device_id>
```

## 🧪 Como testar

Execute a análise estática e os testes automatizados:

```bash
flutter analyze --no-fatal-infos
flutter test
```

## 📁 Estrutura do projeto

```text
lib/
├── main.dart       # Bootstrap do aplicativo e registro dos overlays
├── game/           # Loop principal e transições entre fases
├── components/     # Sophia, rochas coletáveis e marco de fim da fase
├── models/         # Estado do jogo e catálogo de rochas
└── widgets/        # Tela inicial, laboratório, diálogos, diário e demais overlays
imgs/               # Assets visuais do jogo
test/               # Testes de estado e widgets
```

## 🎨 Assets

Os assets principais estão organizados em `imgs/` e incluem:

- backgrounds da tela inicial, laboratório, Vulcão, microscópio, bolsa e diário;
- personagens e animações da Dra. Sophia, além do retrato da Dra. Terra;
- imagens e ícones de Basalto e Obsidiana;
- botões, ícone do Diário de Campo e marcador de fim da fase.

## 🧭 Escopo atual

- O MVP cobre somente a primeira quest, com o Vulcão como primeiro arco jogável.
- Basalto e Obsidiana são as amostras efetivamente usadas nessa quest.
- O Diário de Campo já apresenta as categorias vulcânicas, sedimentares e metamórficas, mas somente a seção vulcânica possui conteúdo jogável no arco atual.
- A progressão completa por múltiplos biomas e novas quests é uma evolução futura, não uma funcionalidade já disponível.
