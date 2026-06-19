
# 🪨 Rock Cycle Explorer — AGENTS.md (Optimized)

## STACK

Flutter + Flame (Dart)

## PURPOSE

2D educational RPG where players explore environments, collect rock samples, classify them, and progress via XP-based quests.

----------

## CORE ARCHITECTURE

-   `FlameGame` handles world simulation
-   Flutter handles UI overlays (HUD, dialogue, quiz)
-   `GameState (ChangeNotifier)` manages:
    -   XP / Level
    -   Inventory (collected rocks)
    -   Quest state
-   `RockModel` is the source of truth for all rock data

----------

## GAME LOOP

Explore → Collect Rock → Return to Base → Analyze → Register → Gain XP → Next Quest

----------

## KEY FILES

-   `main.dart` → Game bootstrap (GameWidget)
-   `rock_cycle_game.dart` → Flame game loop
-   `player.dart` → movement + collisions
-   `rock_component.dart` → collectible rocks
-   `npc_component.dart` → base interactions
-   `game_state.dart` → XP, quests, inventory
-   `rock_model.dart` → rock database

----------

## RULES

-   All gameplay state must live in `GameState`
-   All rock definitions must exist in `RockModel`
-   UI must never contain game logic
-   Flame components must not manage progression logic
-   Flutter overlays must not modify world state directly (only via GameState)

----------

## DATA RULES

Rock definitions:

-   id (unique)
-   name
-   type (igneous / sedimentary / metamorphic)
-   clues (used in analysis UI)
-   sprite reference

----------

## GAME CONSTRAINTS (MVP)

-   No procedural generation
-   No persistent save system
-   No external APIs
-   No dynamic level loading
-   No complex AI behavior

----------

## ANTI-PATTERNS

-   Do not duplicate logic between GameState and components
-   Do not hardcode quest logic inside UI
-   Do not create new rock types without RockModel entry
-   Do not mix rendering logic with progression logic

CRITICAL:
Only read files explicitly required for the current task.
Do not scan or load the full repository unless asked.