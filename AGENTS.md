# Rock Cycle Explorer

**Generated:** 2026-06-18
**Stack:** Flutter + Flame Engine (Dart)

## OVERVIEW

Educational RPG 2D top-down game teaching rock cycle classification. Player explores, collects rock samples, classifies them via quiz, and completes quests for XP.

## STRUCTURE

```
lib/
├── main.dart               # Entry: GameWidget wrapping RockCycleGame
├── game/
│   └── rock_cycle_game.dart  # FlameGame loop (onLoad, update)
├── components/               # Flame entities (Player, Rocks, NPCs)
│   ├── player.dart
│   ├── rock_component.dart
│   └── npc_component.dart
└── models/                   # Data layer (ChangeNotifier state + rock DB)
    ├── game_state.dart
    └── rock_model.dart
```

## WHERE TO LOOK

| Task                            | Location                                                               |
| ------------------------------- | ---------------------------------------------------------------------- |
| Add new rock type               | `lib/models/rock_model.dart` → add to `defaultRocks`                   |
| Add new quest logic             | `lib/models/game_state.dart` → `_checkQuestProgress()`                 |
| Change player movement/speed    | `lib/components/player.dart` → `_speed`, `_updateVelocity`             |
| Add new game entity             | `lib/components/` → extend `RectangleComponent` or `PositionComponent` |
| Modify game loop / add overlay  | `lib/main.dart` + `lib/game/rock_cycle_game.dart`                      |
| Change UI (HUD, quiz, dialogue) | Create `lib/widgets/` → Flutter Overlay widgets (MVP has none yet)     |

## CODE MAP

| Symbol          | Kind     | File                                   | Role                                                                     |
| --------------- | -------- | -------------------------------------- | ------------------------------------------------------------------------ |
| `main()`        | function | `lib/main.dart:6`                      | Entry: wraps `RockCycleGame` in `GameWidget`                             |
| `RockCycleGame` | class    | `lib/game/rock_cycle_game.dart:13`     | `FlameGame` with `HasKeyboardHandlerComponents`, `HasCollisionDetection` |
| `Player`        | class    | `lib/components/player.dart:17`        | Blue square, WASD/arrow movement, collision callbacks                    |
| `RockComponent` | class    | `lib/components/rock_component.dart:5` | Gray square, hitbox for collision                                        |
| `NpcComponent`  | class    | `lib/components/npc_component.dart:5`  | Green square, hitbox for collision                                       |
| `GameState`     | class    | `lib/models/game_state.dart:4`         | `ChangeNotifier`: XP, level, inventory, quest progress                   |
| `RockModel`     | class    | `lib/models/rock_model.dart:18`        | Rock data (id, name, type, clues, sprite)                                |
| `RockType`      | enum     | `lib/models/rock_model.dart:1`         | `igneous`, `sedimentary`, `metamorphic`                                  |

## CONVENTIONS

- **Portuguese UI strings** — all user-facing text in Brazilian Portuguese
- **ChangeNotifier for state** — `GameState` extends `ChangeNotifier`, Flutter widgets listen
- **MVP placeholders** — colored `RectangleComponent` (Player=blue, NPC=green, Rock=gray)
- **Anchor.center** — all components use `Anchor.center` for positioning
- **Flame + Flutter hybrid** — Flame renders game world; Flutter Overlays handle quiz/HUD UI
- **Analysis** — `package:flutter_lints/flutter.yaml` (standard Flutter lint set)

## ANTI-PATTERNS (THIS PROJECT)

- **Do NOT** mix game logic in widgets or UI logic in components
- **Do NOT** use `print()` in production code (MVP uses it for debug only; replace with logger)
- **Do NOT** add rocks without corresponding `RockModel` entry and `RockComponent`
- **Do NOT** hardcode positions in `onLoad()` — move to a map/level data structure when adding biomes
