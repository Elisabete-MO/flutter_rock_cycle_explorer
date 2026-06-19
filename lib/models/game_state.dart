import 'package:flutter/foundation.dart';
import 'rock_model.dart';

class GameState extends ChangeNotifier {
  // ── Inventário e Progressão (Dias 1-3) ──────────────────────────────────────
  final List<RockModel> _collectedRocks = [];
  int _xp = 0;
  int _level = 1;
  String? _activeQuest = 'Colete 1 Basalto (Ígnea) no Vulcão e 1 Arenito (Sedimentar) no Cânion';
  bool _isQuestCompleted = false;
  bool _gameWon = false;

  List<RockModel> get collectedRocks => List.unmodifiable(_collectedRocks);
  int get xp => _xp;
  int get level => _level;
  String? get activeQuest => _activeQuest;
  bool get isQuestCompleted => _isQuestCompleted;
  bool get gameWon => _gameWon;

  // ── Estado de Diálogo (Dia 4+) ───────────────────────────────────────────────
  List<String> _dialogueLines = [];
  int _currentDialogueIndex = 0;
  bool _isDialogueActive = false;

  List<String> get dialogueLines => List.unmodifiable(_dialogueLines);
  int get currentDialogueIndex => _currentDialogueIndex;
  bool get isDialogueActive => _isDialogueActive;

  /// Linha de diálogo atual, ou `null` se nenhum diálogo estiver ativo.
  String? get currentDialogueLine {
    if (!_isDialogueActive || _dialogueLines.isEmpty) return null;
    return _dialogueLines[_currentDialogueIndex];
  }

  /// Inicia um novo diálogo com a lista de falas fornecida.
  void startDialogue(List<String> lines) {
    _dialogueLines = List.from(lines);
    _currentDialogueIndex = 0;
    _isDialogueActive = true;
    notifyListeners();
  }

  /// Avança para a próxima fala do diálogo ativo.
  void advanceDialogue() {
    if (_currentDialogueIndex < _dialogueLines.length - 1) {
      _currentDialogueIndex++;
      notifyListeners();
    }
  }

  /// Finaliza o diálogo ativo e limpa o estado.
  void endDialogue() {
    _isDialogueActive = false;
    _dialogueLines = [];
    _currentDialogueIndex = 0;
    notifyListeners();
  }

  /// Adiciona uma rocha coletada e classificada com sucesso
  void collectRock(RockModel rock) {
    if (!_collectedRocks.any((r) => r.id == rock.id)) {
      _collectedRocks.add(rock);
      addXp(50); // 50 XP por classificar uma nova rocha
      _checkQuestProgress();
      notifyListeners();
    }
  }

  /// Adiciona XP e calcula subida de nível
  void addXp(int amount) {
    _xp += amount;
    // Fórmula simples de progressão: cada nível requer 100 * nível XP
    int nextLevelXp = _level * 100;
    while (_xp >= nextLevelXp) {
      _xp -= nextLevelXp;
      _level++;
      nextLevelXp = _level * 100;
    }
    notifyListeners();
  }

  /// Verifica se os critérios da quest ativa foram atendidos
  void _checkQuestProgress() {
    if (_activeQuest != null) {
      // Quest do MVP: Ter coletado Basalto e Arenito
      bool temBasalto = _collectedRocks.any((r) => r.id == 'basalt');
      bool temArenito = _collectedRocks.any((r) => r.id == 'sandstone');

      if (temBasalto && temArenito) {
        _isQuestCompleted = true;
      }
    }
  }

  /// Entrega as rochas para a Dra. Terra e completa a missão
  void completeQuest() {
    if (_isQuestCompleted && !_gameWon) {
      addXp(150); // XP bônus pela missão
      _activeQuest = 'Missão Cumprida! Você mapeou a ilha com sucesso!';
      _gameWon = true;
      notifyListeners();
    }
  }

  /// Reinicia o estado do jogo
  void reset() {
    _collectedRocks.clear();
    _xp = 0;
    _level = 1;
    _activeQuest = 'Colete 1 Basalto (Ígnea) no Vulcão e 1 Arenito (Sedimentar) no Cânion';
    _isQuestCompleted = false;
    _gameWon = false;
    notifyListeners();
  }
}
