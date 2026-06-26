import 'dart:async';
import 'package:flutter/material.dart';
import '../game/rock_cycle_game.dart';
import '../models/game_state.dart';
import '../models/rock_model.dart';

/// Overlay de classificação científica.
///
/// RESPONSABILIDADE ÚNICA: o jogador escolhe o tipo da rocha.
///
/// NÃO revela nome da rocha.
/// NÃO explica conteúdo científico.
/// A Dra. Terra é responsável por todo o feedback pedagógico.
///
/// Fluxo:
/// 1. Mostra resumo das características + 3 botões
/// 2. Jogador escolhe → avalia → resultado visual
/// 3. Acerto: verde + confete → [Continuar]
///    Erro: vermelho + destaca correta → [Continuar]
/// 4. Ao continuar, volta ao laboratório para feedback da Dra. Terra
class ClassificationOverlay extends StatefulWidget {
  final GameState gameState;
  final RockCycleGame game;

  const ClassificationOverlay({
    super.key,
    required this.gameState,
    required this.game,
  });

  @override
  State<ClassificationOverlay> createState() => _ClassificationOverlayState();
}

enum _ClassificationState { choosing, correct, wrong }

class _ClassificationOverlayState extends State<ClassificationOverlay> {
  _ClassificationState _state = _ClassificationState.choosing;
  RockType? _selectedType;
  bool _showFieldGuide = false;

  @override
  void initState() {
    super.initState();
    _state = _ClassificationState.choosing;
    _selectedType = null;
  }

  void _handleChoice(RockType type) {
    final sample = widget.gameState.currentSample;
    if (sample == null) return;

    final correct = widget.gameState.classifyCurrentSample(type);
    // Toca som de acerto/erro (seguro, não quebra o jogo)
    if (correct) {
      unawaited(widget.game.audioService.playWin());
    } else {
      unawaited(widget.game.audioService.playFail());
    }
    setState(() {
      _selectedType = type;
      _state = correct
          ? _ClassificationState.correct
          : _ClassificationState.wrong;
    });
  }

  void _handleContinue() {
    widget.game.closeClassificationAndReturnToLab();
  }

  @override
  Widget build(BuildContext context) {
    final sample = widget.gameState.currentSample;
    if (sample == null) return const SizedBox.shrink();

    return Scaffold(
      backgroundColor: Colors.black87,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            width: 380,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
            child: _state == _ClassificationState.choosing
                ? _buildChoiceView(sample)
                : _buildResultView(sample),
          ),
        ),
      ),
    );
  }

  Widget _buildChoiceView(RockModel sample) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Classificação da Amostra',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 16),

        // ── Resumo das características ─────────────────────────────
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Características Observadas:',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 12,
                runSpacing: 4,
                children: [
                  _summaryChip('Cristais', sample.hasCrystals),
                  _summaryChip('Camadas', sample.hasLayers),
                  _summaryChip('Fósseis', sample.hasFossils),
                  _summaryChip('Bandas', sample.hasBands),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // ── Pergunta ───────────────────────────────────────────────
        const Center(
          child: Text(
            'Qual o tipo desta rocha?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 20),

        // ── Botões de tipo ─────────────────────────────────────────
        _TypeButton(
          icon: '🌋',
          label: 'Ígnea',
          color: Colors.orange,
          onTap: () => _handleChoice(RockType.igneous),
        ),
        const SizedBox(height: 10),
        _TypeButton(
          icon: '🏜️',
          label: 'Sedimentar',
          color: Colors.amber,
          onTap: () => _handleChoice(RockType.sedimentary),
        ),
        const SizedBox(height: 10),
        _TypeButton(
          icon: '🏔️',
          label: 'Metamórfica',
          color: Colors.teal,
          onTap: () => _handleChoice(RockType.metamorphic),
        ),
        const SizedBox(height: 20),

        // ── Diário de Campo ────────────────────────────────────────
        Center(
          child: TextButton.icon(
            onPressed: () => setState(() => _showFieldGuide = !_showFieldGuide),
            icon: Icon(
              _showFieldGuide ? Icons.expand_less : Icons.book,
              color: Colors.amberAccent,
              size: 18,
            ),
            label: Text(
              _showFieldGuide ? 'Fechar Diário de Campo' : 'Diário de Campo',
              style: const TextStyle(color: Colors.amberAccent, fontSize: 13),
            ),
          ),
        ),

        // ── Guia rápido (expansível) ───────────────────────────────
        if (_showFieldGuide) _buildFieldGuide(),
      ],
    );
  }

  Widget _buildFieldGuide() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.brown.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.amber.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🔍 Guia Rápido',
            style: TextStyle(
              color: Colors.amber.shade200,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Divider(color: Colors.white12, height: 16),
          _guideRow('FÓSSEIS', '→ Quase sempre Sedimentar'),
          _guideRow('CAMADAS', '→ Geralmente Sedimentar'),
          _guideRow('BANDAS', '→ Metamórfica'),
          _guideRow('CRISTAIS', '→ Pode ser Ígnea ou Metamórfica'),
          _guideRow('CRISTAIS + BANDAS', '→ Metamórfica'),
          _guideRow('NENHUM', '→ Provavelmente Ígnea'),
        ],
      ),
    );
  }

  Widget _guideRow(String feature, String mapping) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            feature,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              mapping,
              style: const TextStyle(
                color: Colors.white38,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultView(RockModel sample) {
    final isCorrect = _state == _ClassificationState.correct;

    // Determina o tipo correto para mostrar no erro
    final correctType = sample.type;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Sophia ───────────────────────────────────────────────
        if (isCorrect) ...[
          Image.asset(
            'imgs/characters/mov_sophia/sophia_happy.png',
            height: (MediaQuery.of(context).size.height * 0.22)
                .clamp(80.0, 150.0),
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.greenAccent),
            ),
            child: Text(
              '✅  ${_selectedType?.displayName ?? ''}',
              style: const TextStyle(
                color: Colors.greenAccent,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Classificação correta!',
            style: TextStyle(color: Colors.white70, fontSize: 15),
          ),
        ] else ...[
          Image.asset(
            'imgs/characters/mov_sophia/sophia_sad.png',
            height: (MediaQuery.of(context).size.height * 0.22)
                .clamp(80.0, 150.0),
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.redAccent),
            ),
            child: Text(
              '❌  ${_selectedType?.displayName ?? ''}',
              style: const TextStyle(
                color: Colors.redAccent,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.5)),
            ),
            child: Text(
              '✅  ${correctType.displayName}',
              style: TextStyle(
                color: Colors.greenAccent.shade200,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Vamos observar melhor!',
            style: TextStyle(color: Colors.white70, fontSize: 15),
          ),
        ],
        const SizedBox(height: 24),

        // ── Botão Continuar ────────────────────────────────────────
        ElevatedButton(
          onPressed: _handleContinue,
          style: ElevatedButton.styleFrom(
            backgroundColor: isCorrect ? Colors.green.shade700 : Colors.orange.shade700,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Continuar',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _summaryChip(String label, bool value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: (value ? Colors.green : Colors.red).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '$label: ${value ? "Sim" : "Não"}',
        style: TextStyle(
          color: value ? Colors.greenAccent : Colors.redAccent,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

/// Botão de tipo de rocha (Ígnea / Sedimentar / Metamórfica).
class _TypeButton extends StatelessWidget {
  final String icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _TypeButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: color.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(icon, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
