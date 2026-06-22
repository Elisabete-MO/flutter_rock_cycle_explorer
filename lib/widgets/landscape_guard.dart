import 'package:flutter/material.dart';

/// Proteção visual que bloqueia o jogo em modo retrato.
///
/// Enquanto a largura da tela for menor que a altura (modo retrato),
/// exibe uma tela de aviso solicitando que o usuário gire o dispositivo.
/// Quando em paisagem (largura >= altura), renderiza o [child] normalmente.
class LandscapeGuard extends StatelessWidget {
  final Widget child;

  const LandscapeGuard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        final isPortrait = orientation == Orientation.portrait;
        if (isPortrait) {
          return const _PortraitWarning();
        }
        return child;
      },
    );
  }
}

class _PortraitWarning extends StatelessWidget {
  const _PortraitWarning();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF0D0D0D),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.screen_rotation,
                size: 80,
                color: Colors.white54,
              ),
              SizedBox(height: 24),
              Text(
                'Gire o dispositivo para o\nmodo paisagem para jogar.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Landscape mode required',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
