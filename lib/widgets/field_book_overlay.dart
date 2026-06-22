import 'package:flutter/material.dart';
import '../game/rock_cycle_game.dart';
import '../models/game_state.dart';
import '../models/rock_model.dart';

/// Overlay do Diário de Campo.
///
/// Exibe o caderno como fundo, com conteúdo limitado a uma área segura
/// interna (margens proporcionais). Três abas (Vulcânicas / Sedimentares /
/// Metamórficas) filtram as rochas registradas em [GameState.analyzedRocks].
///
/// Regras do MVP:
/// - Apenas a aba "Vulcânicas" exibe conteúdo completo (fotos coladas).
/// - As demais abas mostram placeholder "Novas descobertas…".
/// - Nenhuma alteração no fluxo de coleta / análise / XP.
class FieldBookOverlay extends StatefulWidget {
  final GameState gameState;
  final RockCycleGame game;

  const FieldBookOverlay({
    super.key,
    required this.gameState,
    required this.game,
  });

  @override
  State<FieldBookOverlay> createState() => _FieldBookOverlayState();
}

class _FieldBookOverlayState extends State<FieldBookOverlay> {
  int _currentTab = 0;

  static const _tabLabels = ['Vulcânicas', 'Sedimentares', 'Metamórficas'];

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.gameState,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: Colors.black,
          body: LayoutBuilder(
            builder: (context, constraints) {
              // Margens proporcionais da área útil do caderno:
              // - esquerda maior para evitar a encadernação/espiral
              // - demais bordas protegem contra cantos decorativos
              final safeLeft = constraints.maxWidth * 0.115;
              final safeRight = constraints.maxHeight * 0.065;
              final safeTop = constraints.maxHeight * 0.115;
              final safeBottom = constraints.maxHeight * 0.075;

              return Stack(
                fit: StackFit.expand,
                children: [
                  // ── Fundo: caderno ──────────────────────────────
                  Image.asset(
                    'imgs/bcgs/book.png',
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      color: const Color(0xFFF5F0E8),
                      child: const Center(
                        child: Text(
                          'Diário de Campo',
                          style: TextStyle(color: Colors.brown, fontSize: 24),
                        ),
                      ),
                    ),
                  ),

                  // ── Conteúdo com Padding (área útil) ────────────
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      safeLeft,
                      safeTop,
                      safeRight,
                      safeBottom,
                    ),
                    child: _buildContent(),
                  ),

                  // ── Botão fechar ────────────────────────────────
                  Positioned(
                    right: 16,
                    top: MediaQuery.of(context).padding.top + 8,
                    child: IconButton(
                      icon: const Icon(Icons.close),
                      color: Colors.brown.shade600,
                      onPressed: () => widget.game.closeFieldBook(),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        // ── Abas ───────────────────────────────────────────────────
        _buildTabs(),
        const SizedBox(height: 12),
        // ── Conteúdo da aba ativa ───────────────────────────────────
        Expanded(
          child: _buildTabContent(),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  //  ABAS
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildTabs() {
    return Row(
      children: List.generate(_tabLabels.length, (i) {
        final selected = i == _currentTab;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _currentTab = i),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: selected
                        ? const Color(0xFF5D4037)
                        : Colors.transparent,
                    width: 1.5,
                  ),
                ),
              ),
              child: Text(
                _tabLabels[i],
                textAlign: TextAlign.center,
                style: TextStyle(
                  color:
                      selected ? const Color(0xFF3E2723) : const Color(0xFF8D6E63),
                  fontSize: 14,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  //  CONTEÚDO POR ABA
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildTabContent() {
    switch (_currentTab) {
      case 0:
        return _buildIgneousPage();
      case 1:
      case 2:
        return _buildFuturePage();
      default:
        return const SizedBox.shrink();
    }
  }

  /// Placeholder para abas futuras (Sedimentares / Metamórficas).
  Widget _buildFuturePage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Text(
          'Novas descobertas serão registradas em missões futuras.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: const Color(0xFF5D4037).withValues(alpha: 0.7),
            fontSize: 15,
            fontStyle: FontStyle.italic,
            height: 1.5,
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  //  PÁGINA VULCÂNICAS
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildIgneousPage() {
    final igneousRocks = widget.gameState.analyzedRocks
        .where((r) => r.type == RockType.igneous)
        .toList();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Título ───────────────────────────────────────────────
          const Text(
            'VULCÂNICAS',
            style: TextStyle(
              color: Color(0xFF3E2723),
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),

          // ── Texto descritivo ──────────────────────────────────────
          Text(
            'As rochas ígneas vulcânicas se formam quando a lava esfria '
            'e endurece na superfície. Geralmente não possuem fósseis '
            'nem camadas. Algumas têm textura muito fina e poucos '
            'cristais visíveis.',
            style: TextStyle(
              color: const Color(0xFF4E342E).withValues(alpha: 0.85),
              fontSize: 13,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),

          // ── Características ───────────────────────────────────────
          _buildCharacteristics(),
          const SizedBox(height: 16),

          // ── Amostras registradas ──────────────────────────────────
          if (igneousRocks.isNotEmpty) ...[
            Text(
              'Amostras registradas',
              style: TextStyle(
                color: const Color(0xFF3E2723),
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            _buildRockPhotos(igneousRocks),
          ],
        ],
      ),
    );
  }

  Widget _buildCharacteristics() {
    const items = [
      ('Origem', 'resfriamento da lava'),
      ('Fósseis', 'geralmente ausentes'),
      ('Camadas', 'geralmente ausentes'),
      ('Cristais visíveis', 'poucos ou ausentes'),
      ('Textura', 'fina ou vítrea'),
    ];

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF3E2723).withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: const Color(0xFF3E2723).withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items.map((item) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 100,
                  child: Text(
                    '${item.$1}:',
                    style: TextStyle(
                      color: const Color(0xFF3E2723),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    item.$2,
                    style: TextStyle(
                      color: const Color(0xFF4E342E).withValues(alpha: 0.85),
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  //  FOTOS COLADAS
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildRockPhotos(List<RockModel> rocks) {
    return Wrap(
      spacing: 12,
      runSpacing: 14,
      children: rocks.map((rock) => _RockPhotoCard(rock: rock)).toList(),
    );
  }
}

/// Card de foto "colada" com borda clara, sombra e leve rotação.
class _RockPhotoCard extends StatelessWidget {
  final RockModel rock;

  const _RockPhotoCard({required this.rock});

  @override
  Widget build(BuildContext context) {
    // Leve rotação pseudo-aleatória baseada no id para parecer natural
    final rotation = (rock.id.hashCode % 5 - 2) * 0.02; // ~ -0.04 .. +0.04 rad

    return Transform.rotate(
      angle: rotation,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(3),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 5,
              offset: const Offset(1.5, 2.5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Foto ──────────────────────────────────────────────
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: Image.asset(
                _photoPath(rock),
                width: 90,
                height: 90,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  width: 90,
                  height: 90,
                  color: Colors.grey.shade300,
                  child: const Icon(Icons.broken_image,
                      color: Colors.grey, size: 32),
                ),
              ),
            ),
            // ── Nome abaixo da foto ────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(6, 4, 6, 5),
              child: Text(
                rock.name,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF3E2723),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Mapeia o id da rocha para o path da foto "colada".
  /// Para o MVP, apenas basalt/obsidian têm foto específica;
  /// as demais usam o spriteName como fallback.
  static String _photoPath(RockModel rock) {
    if (rock.id == 'basalt') return 'imgs/rocks/basalt_photo.jpeg';
    if (rock.id == 'obsidian') return 'imgs/rocks/obsidian_photo.jpg';
    return rock.spriteName;
  }
}
