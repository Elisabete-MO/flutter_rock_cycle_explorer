import 'dart:async';
import 'package:flutter/material.dart';
import '../game/rock_cycle_game.dart';

/// Tela inicial do jogo.
///
/// Exibe o background [imgs/bcgs/inicio.png] e um botão "Iniciar"
/// personalizado com a imagem [imgs/buttons/init.png].
/// Ao clicar em "Iniciar", o jogo transiciona para o laboratório e
/// inicia automaticamente o diálogo inicial da Dra. Terra.
class StartOverlay extends StatelessWidget {
  final RockCycleGame game;

  const StartOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Largura responsiva do botão: proporcional à tela com limites
    // confortáveis para desktop e mobile paisagem.
    final buttonWidth = (screenWidth * 0.22).clamp(180.0, 320.0);

    // Altura derivada da proporção do asset (400×209 ≈ 1.914:1).
    final buttonHeight = buttonWidth * (209.0 / 400.0);

    // Posição vertical: percentual da altura para alinhar o centro do
    // botão dentro da área clara de pedra na parte inferior da tela.
    // O valor 0.55 significa 55% do centro para baixo
    // (centro da tela + 55% do semi-eixo vertical).
    final buttonAlignment = Alignment(0, 0.55);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Background ─────────────────────────────────────────────
          Image.asset(
            'imgs/bcgs/inicio.png',
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Container(
              color: const Color(0xFF1A1A2E),
              child: const Center(
                child: Text(
                  'Rock Cycle Explorer',
                  style: TextStyle(color: Colors.white54, fontSize: 24),
                ),
              ),
            ),
          ),

          // ── Botão Iniciar (com animação hover/press) ───────────────
          Align(
            alignment: buttonAlignment,
            child: Semantics(
              label: 'Iniciar jogo',
              button: true,
              child: _AnimatedStartButton(
                key: const Key('start_button'),
                width: buttonWidth,
                height: buttonHeight,
                onTap: () {
                  unawaited(game.audioService.playClick());
                  game.startGame();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Botão "Iniciar" com animação de hover (desktop) e press (mobile/desktop).
///
/// - Hover: escala 1.04 com duração de 150ms (easeOut)
/// - Press: escala 0.96
/// - Normal: escala 1.0
/// - Não há animação infinita ou pulsação constante.
class _AnimatedStartButton extends StatefulWidget {
  final double width;
  final double height;
  final VoidCallback onTap;

  const _AnimatedStartButton({
    super.key,
    required this.width,
    required this.height,
    required this.onTap,
  });

  @override
  State<_AnimatedStartButton> createState() => _AnimatedStartButtonState();
}

class _AnimatedStartButtonState extends State<_AnimatedStartButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  static const Duration _kDuration = Duration(milliseconds: 150);
  static const Curve _kCurve = Curves.easeOut;

  double get _scale {
    if (_isPressed) return 0.96;
    if (_isHovered) return 1.04;
    return 1.0;
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        behavior: HitTestBehavior.opaque,
        child: AnimatedScale(
          scale: _scale,
          duration: _kDuration,
          curve: _kCurve,
          child: SizedBox(
            width: widget.width,
            height: widget.height,
            child: Image.asset(
              'imgs/buttons/init.png',
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => Container(
                decoration: BoxDecoration(
                  color: Colors.brown.shade700,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Text(
                    'Iniciar',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
