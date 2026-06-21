import 'package:flutter_test/flutter_test.dart';
import 'package:rock_cycle_explorer/models/game_state.dart';
import 'package:rock_cycle_explorer/models/rock_model.dart';

void main() {
  group('fluxo da primeira quest', () {
    test('apresentacao inicial acontece uma vez e volta apos reset', () {
      final state = GameState();

      expect(state.initialDialogueCompleted, isFalse);
      state.startInitialDialogue();
      expect(state.dialoguePurpose, DialoguePurpose.initial);
      expect(state.endDialogue(), DialoguePurpose.initial);
      expect(state.initialDialogueCompleted, isTrue);

      state.reset();

      expect(state.initialDialogueCompleted, isFalse);
      expect(state.dialoguePurpose, DialoguePurpose.none);
      expect(state.isDialogueActive, isFalse);
    });

    test('retorno da coleta usa dialogo de parabenizacao', () {
      final state = GameState();

      state.startPostCollectionDialogue();

      expect(state.dialoguePurpose, DialoguePurpose.postCollection);
      expect(state.dialogueLines, GameState.postCollectionDialogue);
      expect(
        state.currentDialogueLine,
        'Ótimas amostras, Dra. Sophia! Vamos analisá-las no laboratório.',
      );
    });

    test('feedback automatico correto cataloga e limpa a amostra', () {
      final state = GameState();
      final basalt = RockModel.byId('basalt')!;
      state.registerFieldSample(basalt);
      state.startAnalysis(basalt);
      expect(state.classifyCurrentSample(RockType.igneous), isTrue);

      expect(state.startClassificationFeedbackDialogue(), isTrue);
      expect(state.feedbackGiven, isTrue);
      expect(state.dialoguePurpose, DialoguePurpose.classificationFeedback);
      expect(state.endDialogue(), DialoguePurpose.classificationFeedback);

      expect(state.fieldSamples, isEmpty);
      expect(state.analyzedRocks, contains(basalt));
      expect(state.currentSample, isNull);
      expect(state.classificationAttempted, isFalse);
      expect(state.feedbackGiven, isFalse);
    });

    test('feedback automatico de correcao tambem cataloga a amostra', () {
      final state = GameState();
      final obsidian = RockModel.byId('obsidian')!;
      state.registerFieldSample(obsidian);
      state.startAnalysis(obsidian);
      expect(state.classifyCurrentSample(RockType.sedimentary), isFalse);

      expect(state.startClassificationFeedbackDialogue(), isTrue);
      expect(
        state.currentDialogueLine,
        'Não foi dessa vez, Dra. Sophia. Vamos observar com calma.',
      );
      state.endDialogue();

      expect(state.fieldSamples, isEmpty);
      expect(state.analyzedRocks, contains(obsidian));
      expect(state.currentSample, isNull);
    });

    test('XP final soma coleta e conclusao da quest', () {
      final state = GameState();
      state.collectInField('basalt');
      state.collectInField('obsidian');

      state.finalizeCollection();

      expect(state.totalXp, GameState.collectionXpReward);

      for (final sample in List<RockModel>.from(state.fieldSamples)) {
        state.startAnalysis(sample);
        state.classifyCurrentSample(sample.type);
        state.startClassificationFeedbackDialogue();
        state.endDialogue();
      }
      expect(state.isQuestCompleted, isTrue);

      state.completeQuest();

      expect(
        state.totalXp,
        GameState.collectionXpReward + GameState.questXpReward,
      );
      expect(state.totalXp, 850);
    });

    test('reset limpa integralmente estado temporario e progresso', () {
      final state = GameState();
      final basalt = RockModel.byId('basalt')!;
      state.startInitialDialogue();
      state.endDialogue();
      state.collectInField('basalt');
      state.collectInField('obsidian');
      state.finalizeCollection();
      state.startAnalysis(basalt);
      state.classifyCurrentSample(RockType.igneous);
      state.startClassificationFeedbackDialogue();

      state.reset();

      expect(state.xp, 0);
      expect(state.totalXp, 0);
      expect(state.level, 1);
      expect(state.fieldSamples, isEmpty);
      expect(state.analyzedRocks, isEmpty);
      expect(state.currentSample, isNull);
      expect(state.collectedInField, isEmpty);
      expect(state.classificationAttempted, isFalse);
      expect(state.feedbackGiven, isFalse);
      expect(state.isQuestCompleted, isFalse);
      expect(state.gameWon, isFalse);
      expect(state.initialDialogueCompleted, isFalse);
      expect(state.isDialogueActive, isFalse);
    });
  });
}
