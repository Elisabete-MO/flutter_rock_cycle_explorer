<div align="center">
  <h1>🪨 Rock Cycle Explorer</h1>
  <p><em>Explore, colete e descubra os segredos geológicos da Terra em um RPG lúdico de aprendizagem.</em></p>
</div>

---

## 📖 Sobre o Projeto

**Rock Cycle Explorer** é um jogo educacional focado em ensinar os processos de formação e transformação das rochas. Desenvolvido com **Flutter** e **Flame Engine**, o jogo combina o dinamismo visual de um RPG top-down clássico de exploração com mecânicas interativas de aprendizado.

**Objetivo Educacional:** Proporcionar uma compreensão intuitiva do ciclo das rochas, diferenciando rochas ígneas, sedimentares e metamórficas através de pistas textuais e visuais.
**Público-alvo:** Estudantes do ensino básico ao médio (11 a 15 anos) e qualquer entusiasta de ciências naturais.

---

## 🎮 Gameplay

O núcleo do jogo baseia-se em um ciclo viciante e educativo (Core Loop):

1. **Exploração:** O jogador (um geólogo de campo) navega por um mapa 2D top-down renderizado de forma fluida pela Flame Engine.
2. **Coleta:** Interação com "nós geológicos" espalhados por biomas distintos (vulcão, cânion, cavernas).
3. **Classificação:** Ao inspecionar uma rocha, o jogo entra na interface do "Laboratório de Campo". Através de um sistema de quiz interativo, o jogador analisa dicas físicas/visuais e classifica a amostra geológica.
4. **Progresso:** Entregar as rochas classificadas corretamente aos NPCs gera Pontos de Experiência (XP) e completa missões (Quests) de mapeamento.

> **O papel da Flame Engine:** A Flame é responsável pela lógica do mundo físico (renderização contínua, movimentação do jogador, colisões com paredes e NPCs), enquanto o Flutter cuida da interface gráfica interativa (overlays de quizzes, HUD, diálogos).

---

## ⚙️ Funcionalidades

### 🔴 MVP (Disponível)
- Movimentação 2D top-down (teclado/joystick).
- Interação com nós de rocha e NPCs de missão (Dra. Terra).
- Sistema de classificação (Quiz Geológico via Flutter Overlays).
- Gerenciamento reativo de estado (Inventário e Quests).
- Dados base estruturados (Basalto, Granito, Arenito, Calcário, Gneisse, Mármore).

### 🟢 Futuro (Planejado)
- Suporte a mapas avançados em `.tmx` (Tiled).
- Enciclopédia Interativa ("Caderno do Geólogo") desbloqueável.
- Ciclo de dia/noite e efeitos climáticos.
- Minijogo físico de fusão e metamorfismo (submeter rochas a alta pressão in-game).

---

## 🛠️ Tecnologias e Arquitetura

- **[Flutter](https://flutter.dev/):** Utilizado para todo o envelopamento do jogo, gerenciamento de estado nativo (`ChangeNotifier`) e construção das interfaces de usuário sobrepostas (Overlays de HUD, Quizzes e Diálogos).
- **[Flame Engine](https://flame-engine.org/):** Game engine modular baseada em Flutter. Gerencia o `FlameGame` loop, Component System (FCS), física básica e inputs de movimentação.
- **Dart:** Linguagem primária.

A arquitetura do projeto segue o padrão híbrido **Flame-First**, onde a engine processa o mundo, e o Flutter sobrepõe a UI de negócios educacionais.

---

## 📁 Estrutura do Projeto

O código está organizado de forma clara para separar a lógica da engine 2D das regras de negócio do aplicativo móvel:

```
lib/
├── main.dart               # Ponto de entrada e configuração do GameWidget / Overlays
├── game/                   # Domínio restrito à Flame Engine
│   ├── rock_cycle_game.dart# Classe principal do loop do jogo
│   └── components/         # Entidades do jogo (Player, Rochas, NPCs, Obstáculos)
├── models/                 # Regras de negócio e dados do Flutter
│   ├── rock_model.dart     # Banco de dados de dicas geológicas
│   └── game_state.dart     # Estado global (Inventário, XP, Quests) usando ChangeNotifier
└── widgets/                # Interfaces de UI interativas (Overlays Flutter)
    ├── hud_overlay.dart    # Inventário rápido
    ├── dialogue_overlay.dart
    └── quiz_overlay.dart   # Formulário de classificação da rocha
```

---

## 🚀 Como Executar Localmente

O projeto é multiplataforma e suporta execução em Linux, Web, Android, iOS, macOS e Windows.

**Pré-requisitos:**
Ter o [Flutter SDK](https://docs.flutter.dev/get-started/install) atualizado instalado na sua máquina.

1. Clone o repositório:
```bash
git clone https://github.com/SEU_USUARIO/rock_cycle_explorer.git
cd rock_cycle_explorer
```

2. Instale as dependências (incluindo a Flame Engine):
```bash
flutter pub get
```

3. Execute o projeto (no Linux, por exemplo):
```bash
flutter run -d linux
# Para rodar no navegador: flutter run -d chrome
```

---

## 🎨 Estilo e Proposta Visual

O jogo foge do clichê de "aplicativos educacionais estáticos" adotando uma estética de **expedição científica premium**.
- **Cores:** Tons terrosos, minerais ricos (cinza ardósia, basalto), laranjas vulcânicos e ocres sedimentares.
- **Identidade:** Interfaces limpas, textos didáticos legíveis e um clima pacífico focado em curiosidade e descoberta ambiental, reminiscente de explorações de laboratório de campo.

---

## 🤝 Como Contribuir

Contribuições são muito bem-vindas, especialmente para adicionar novas rochas ao catálogo ou aprimorar os assets visuais!

1. Faça o Fork deste repositório.
2. Crie sua branch de funcionalidade (`git checkout -b feat/nova-rocha-obsidiana`).
3. Commit suas alterações (`git commit -m 'feat: adiciona rocha obsidiana e dicas'`).
4. Envie para a branch origin (`git push origin feat/nova-rocha-obsidiana`).
5. Abra um Pull Request detalhando sua adição.

---
*Feito com propósito educacional acadêmico por um dev em constante evolução de Flutter e Flame.*
