import 'package:flutter/foundation.dart';
import 'rock_model.dart';

/// Fases do jogo no MVP.
/// Apenas a fase [exploration] tem movimentação do jogador.
enum GamePhase { lab, exploration, microscope, bag }

enum DialoguePurpose {
  none,
  initial,
  postCollection,
  classificationFeedback,
  victory,
}

class GameState extends ChangeNotifier {
  static const int collectionXpReward = 100;
  static const int questXpReward = 750;

  // ── Fase Atual ──────────────────────────────────────────────────────────────
  GamePhase _phase = GamePhase.lab;
  GamePhase get phase => _phase;

  void setPhase(GamePhase phase) {
    _phase = phase;
    notifyListeners();
  }

  // ── Inventário e Progressão ─────────────────────────────────────────────────
  final List<RockModel> _collectedRocks = [];
  int _xp = 0;
  int _totalXp = 0;
  int _level = 1;
  String? _activeQuest = 'Colete 1 Basalto e 1 Obsidiana no Vulcão!';
  bool _isQuestCompleted = false;
  bool _gameWon = false;
  bool _collectionRewardGranted = false;

  List<RockModel> get collectedRocks => List.unmodifiable(_collectedRocks);
  int get xp => _xp;
  int get totalXp => _totalXp;
  int get level => _level;
  String? get activeQuest => _activeQuest;
  bool get isQuestCompleted => _isQuestCompleted;
  bool get gameWon => _gameWon;

  // ── Fluxo de Análise ────────────────────────────────────────────────────────
  final List<RockModel> _fieldSamples = [];
  final List<RockModel> _analyzedRocks = [];
  RockModel? _currentSample;

  /// Amostras coletadas em campo que ainda não passaram pela análise.
  List<RockModel> get fieldSamples => List.unmodifiable(_fieldSamples);

  /// Amostras que completaram o ciclo coleta → análise → registro.
  List<RockModel> get analyzedRocks => List.unmodifiable(_analyzedRocks);

  /// Amostra atualmente no microscópio, ou `null`.
  RockModel? get currentSample => _currentSample;

  // ── Estado de Coleta (Exploração) ───────────────────────────────────────────
  final Set<String> _collectedInField = {};

  /// Amostras que o jogador coletou durante a fase de exploração.
  Set<String> get collectedInField => Set.unmodifiable(_collectedInField);

  /// Registra a coleta de uma amostra na fase de exploração.
  void collectInField(String rockId) {
    _collectedInField.add(rockId);
    notifyListeners();
  }

  /// Retorna true se todas as amostras obrigatórias foram coletadas.
  bool get hasCollectedAllRequired {
    return _collectedInField.contains('basalt') &&
        _collectedInField.contains('obsidian');
  }

  /// Finaliza a coleta e move as amostras para fieldSamples.
  void finalizeCollection() {
    for (final id in _collectedInField) {
      final model = RockModel.byId(id);
      if (model != null && !_fieldSamples.any((r) => r.id == id)) {
        _fieldSamples.add(model);
      }
    }
    if (hasCollectedAllRequired && !_collectionRewardGranted) {
      _collectionRewardGranted = true;
      _grantXp(collectionXpReward);
    }
    notifyListeners();
  }

  /// Limpa o estado de coleta (para tentar novamente).
  void resetCollection() {
    _collectedInField.clear();
    notifyListeners();
  }

  // ── Estado de Classificação ─────────────────────────────────────────────────
  bool _classificationAttempted = false;
  bool _lastClassificationCorrect = false;
  bool _feedbackGiven = false;

  /// True após o ClassificationOverlay ser fechado (acerto ou erro).
  bool get classificationAttempted => _classificationAttempted;

  /// True se a última classificação foi correta.
  bool get lastClassificationCorrect => _lastClassificationCorrect;

  /// True se a Dra. Terra já deu feedback sobre a última classificação.
  bool get feedbackGiven => _feedbackGiven;

  /// True quando há classificação pendente de feedback da Dra. Terra.
  bool get hasPendingClassificationFeedback =>
      _classificationAttempted && !_feedbackGiven && _currentSample != null;

  /// Avalia o palpite do jogador.
  /// Se correto, marca a amostra como pending para feedback.
  /// Retorna true se acertou, false se errou.
  bool classifyCurrentSample(RockType guess) {
    final sample = _currentSample;
    if (sample == null) return false;
    _classificationAttempted = true;
    _lastClassificationCorrect = sample.type == guess;
    notifyListeners();
    return _lastClassificationCorrect;
  }

  /// Inicia o feedback correspondente à última classificação.
  /// Retorna false quando não há uma classificação válida pendente.
  bool startClassificationFeedbackDialogue() {
    final sample = _currentSample;
    if (!hasPendingClassificationFeedback || sample == null) return false;

    _feedbackGiven = true;
    startDialogue(
      _lastClassificationCorrect
          ? generateCorrectFeedbackDialogue(sample)
          : generateWrongFeedbackDialogue(sample),
      purpose: DialoguePurpose.classificationFeedback,
    );
    return true;
  }

  /// Finaliza a amostra após feedback da Dra. Terra.
  /// Move de fieldSamples para analyzedRocks (0 XP — XP vem da quest).
  /// Tanto acerto quanto erro movem a amostra (não há segunda tentativa).
  void finalizeAfterFeedback() {
    _finalizeAfterFeedback();
    notifyListeners();
  }

  void _finalizeAfterFeedback() {
    final sample = _currentSample;
    if (sample == null) return;
    _fieldSamples.removeWhere((r) => r.id == sample.id);
    if (!_analyzedRocks.any((r) => r.id == sample.id)) {
      _analyzedRocks.add(sample);
    }
    _currentSample = null;
    _classificationAttempted = false;
    _lastClassificationCorrect = false;
    _feedbackGiven = false;
    _checkQuestProgress();
  }

  /// Marca que a Dra. Terra deu o feedback.
  void markFeedbackGiven() {
    _feedbackGiven = true;
    notifyListeners();
  }

  /// Limpa o estado de classificação pós-feedback.
  void clearPostClassificationState() {
    _classificationAttempted = false;
    _lastClassificationCorrect = false;
    _feedbackGiven = false;
    notifyListeners();
  }

  // ── Estado de Diálogo ───────────────────────────────────────────────────────
  List<String> _dialogueLines = [];
  int _currentDialogueIndex = 0;
  bool _isDialogueActive = false;
  bool _initialDialogueCompleted = false;
  DialoguePurpose _dialoguePurpose = DialoguePurpose.none;

  List<String> get dialogueLines => List.unmodifiable(_dialogueLines);
  int get currentDialogueIndex => _currentDialogueIndex;
  bool get isDialogueActive => _isDialogueActive;
  bool get initialDialogueCompleted => _initialDialogueCompleted;
  DialoguePurpose get dialoguePurpose => _dialoguePurpose;

  String? get currentDialogueLine {
    if (!_isDialogueActive || _dialogueLines.isEmpty) return null;
    return _dialogueLines[_currentDialogueIndex];
  }

  void startDialogue(
    List<String> lines, {
    DialoguePurpose purpose = DialoguePurpose.none,
  }) {
    _dialogueLines = List.from(lines);
    _currentDialogueIndex = 0;
    _isDialogueActive = true;
    _dialoguePurpose = purpose;
    notifyListeners();
  }

  void startInitialDialogue() {
    startDialogue(initialDialogue, purpose: DialoguePurpose.initial);
  }

  void startPostCollectionDialogue() {
    startDialogue(
      postCollectionDialogue,
      purpose: DialoguePurpose.postCollection,
    );
  }

  void startVictoryDialogue() {
    startDialogue(victoryDialogue, purpose: DialoguePurpose.victory);
  }

  void advanceDialogue() {
    if (_currentDialogueIndex < _dialogueLines.length - 1) {
      _currentDialogueIndex++;
      notifyListeners();
    }
  }

  DialoguePurpose endDialogue() {
    final completedPurpose = _dialoguePurpose;
    _isDialogueActive = false;
    _dialogueLines = [];
    _currentDialogueIndex = 0;
    _dialoguePurpose = DialoguePurpose.none;

    if (completedPurpose == DialoguePurpose.initial) {
      _initialDialogueCompleted = true;
    } else if (completedPurpose == DialoguePurpose.classificationFeedback) {
      _finalizeAfterFeedback();
    }

    notifyListeners();
    return completedPurpose;
  }

  // ── Geração de Diálogos da Dra. Terra ───────────────────────────────────────

  /// Diálogo inicial da Dra. Terra (primeiro contato).
  static const List<String> initialDialogue = [
    'Bem-vinda, Dra. Sophia! A expedição está pronta.',
    'Precisamos catalogar as rochas da ilha para entender '
        'sua história geológica.',
    'Explore os biomas: Vulcão, Cânion, Caverna e Montanha.',
    'Cada amostra coletada deve ser trazida à base para análise.',
    'Leve este Diário de Campo com você.',
    'Nele você poderá registrar detalhes das amostras coletadas '
        'e consultar informações importantes.',
    'Sua primeira missão: vá até o Vulcão e encontre '
        'Basalto e Obsidiana!',
  ];

  /// Diálogo quando retorna ao laboratório com amostras coletadas.
  static const List<String> postCollectionDialogue = [
    'Ótimas amostras, Dra. Sophia! Vamos analisá-las no laboratório.',
    'Selecione uma amostra para começarmos a classificação.',
  ];

  /// Gera diálogo de feedback para classificação CORRETA.
  List<String> generateCorrectFeedbackDialogue(RockModel sample) {
    switch (sample.id) {
      case 'basalt':
        return [
          'Excelente, Dra. Sophia! Classificação correta!',
          'Esta amostra é Basalto — uma rocha Ígnea.',
          'A textura fina e a cor escura são típicas de rochas '
              'formadas pelo resfriamento rápido da lava.',
          'Vou registrar essa descoberta no Diário de Campo.',
        ];
      case 'obsidian':
        return [
          'Excelente, Dra. Sophia! Classificação correta!',
          'Esta amostra é Obsidiana — uma rocha Ígnea.',
          'O brilho vítreo indica que ela se formou quando a lava '
              'esfriou muito rapidamente.',
          'Vou registrar essa descoberta no Diário de Campo.',
        ];
      default:
        return [
          'Excelente, Dra. Sophia! Classificação correta!',
          'Esta amostra é ${sample.name} — uma rocha ${sample.type.displayName}.',
          'Vou registrar essa descoberta no Diário de Campo.',
        ];
    }
  }

  /// Gera diálogo de feedback para classificação ERRADA.
  List<String> generateWrongFeedbackDialogue(RockModel sample) {
    switch (sample.id) {
      case 'basalt':
        return [
          'Não foi dessa vez, Dra. Sophia. Vamos observar com calma.',
          'Esta amostra era Basalto — uma rocha Ígnea.',
          'A ausência de camadas, fósseis e bandas ajuda a diferenciar '
              'essa rocha de outros tipos.',
          'Vou registrar essa descoberta no Diário de Campo.',
        ];
      case 'obsidian':
        return [
          'Não foi dessa vez, Dra. Sophia. Vamos observar com calma.',
          'Esta amostra era Obsidiana — uma rocha Ígnea.',
          'O brilho vítreo e a ausência de camadas, fósseis e bandas '
              'são pistas importantes.',
          'Vou registrar essa descoberta no Diário de Campo.',
        ];
      default:
        return [
          'Não foi dessa vez, Dra. Sophia. Vamos observar com calma.',
          'Esta amostra era ${sample.name} — uma rocha ${sample.type.displayName}.',
          'Vou registrar essa descoberta no Diário de Campo.',
        ];
    }
  }

  /// Diálogo de vitória da quest.
  static const List<String> victoryDialogue = [
    'Parabéns, Dra. Sophia! Missão cumprida!',
    'Com Basalto e Obsidiana catalogados, começamos a desvendar '
        'a história geológica da ilha.',
    'Você recebe 750 XP pelo excelente trabalho de campo!',
    'A ilha ainda guarda muitos segredos — mas por hoje, '
        'nossa missão está completa.',
  ];

  // ── Registro de Coleta (legado) ─────────────────────────────────────────────
  void collectRock(RockModel rock) {
    if (!_collectedRocks.any((r) => r.id == rock.id)) {
      _collectedRocks.add(rock);
      addXp(50);
      _checkQuestProgress();
      notifyListeners();
    }
  }

  void registerFieldSample(RockModel sample) {
    if (!_fieldSamples.any((r) => r.id == sample.id)) {
      _fieldSamples.add(sample);
      notifyListeners();
    }
  }

  // ── Análise ─────────────────────────────────────────────────────────────────
  void startAnalysis(RockModel sample) {
    _currentSample = sample;
    _classificationAttempted = false;
    _lastClassificationCorrect = false;
    _feedbackGiven = false;
    notifyListeners();
  }

  void cancelAnalysis() {
    _currentSample = null;
    _classificationAttempted = false;
    _lastClassificationCorrect = false;
    _feedbackGiven = false;
    notifyListeners();
  }

  // ── XP e Progressão ─────────────────────────────────────────────────────────
  void addXp(int amount) {
    _grantXp(amount);
    notifyListeners();
  }

  void _grantXp(int amount) {
    _totalXp += amount;
    _xp += amount;
    int nextLevelXp = _level * 100;
    while (_xp >= nextLevelXp) {
      _xp -= nextLevelXp;
      _level++;
      nextLevelXp = _level * 100;
    }
  }

  void _checkQuestProgress() {
    if (_activeQuest != null) {
      bool temBasalto = _analyzedRocks.any((r) => r.id == 'basalt');
      bool temObsidiana = _analyzedRocks.any((r) => r.id == 'obsidian');
      if (temBasalto && temObsidiana) {
        _isQuestCompleted = true;
      }
    }
  }

  void completeQuest() {
    if (_isQuestCompleted && !_gameWon) {
      _grantXp(questXpReward);
      _activeQuest = 'Missão Cumprida! Você catalogou Basalto e Obsidiana!';
      _gameWon = true;
      notifyListeners();
    }
  }

  /// Reinicia o jogo.
  void reset() {
    _collectedRocks.clear();
    _fieldSamples.clear();
    _analyzedRocks.clear();
    _currentSample = null;
    _collectedInField.clear();
    _classificationAttempted = false;
    _lastClassificationCorrect = false;
    _feedbackGiven = false;
    _xp = 0;
    _totalXp = 0;
    _level = 1;
    _activeQuest = 'Colete 1 Basalto e 1 Obsidiana no Vulcão!';
    _isQuestCompleted = false;
    _gameWon = false;
    _collectionRewardGranted = false;
    _phase = GamePhase.lab;
    _dialogueLines = [];
    _currentDialogueIndex = 0;
    _isDialogueActive = false;
    _initialDialogueCompleted = false;
    _dialoguePurpose = DialoguePurpose.none;
    notifyListeners();
  }
}
