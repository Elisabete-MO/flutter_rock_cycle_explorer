import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Serviço central de áudio com tratamento defensivo para Flutter Web.
///
/// Responsabilidades:
/// - Gerenciar música de abertura (loop)
/// - Gerenciar ambiência do vulcão (loop)
/// - Tocar SFX (coleta, bag, clique, vitória, falha)
/// - Capturar erros de áudio sem quebrar o jogo
/// - Evitar múltiplas instâncias duplicadas da mesma música/ambiência
///
/// Uso:
/// ```dart
/// final audio = AudioService();
/// await audio.init();
/// await audio.playOpeningTheme();
/// ```
class AudioService {
  // ═══════════════════════════════════════════════════════════════════
  //  VOLUMES (constantes fáceis de ajustar)
  // ═══════════════════════════════════════════════════════════════════
  // Volumes escolhidos para não competir com a narração/gameplay.
  static const double _openingThemeVolume = 0.35;
  static const double _volcanoAmbienceVolume = 0.25;
  static const double _collectVolume = 0.55;
  static const double _bagVolume = 0.45;
  static const double _clickVolume = 0.45;
  static const double _winVolume = 0.55;
  static const double _failVolume = 0.45;

  // ═══════════════════════════════════════════════════════════════════
  //  ASSET PATHS
  // ═══════════════════════════════════════════════════════════════════
  static const String _musicBase = 'audio/music';
  static const String _sfxBase = 'audio/sfx';

  // ═══════════════════════════════════════════════════════════════════
  //  PLAYERS (um por canal)
  // ═══════════════════════════════════════════════════════════════════
  AudioPlayer? _bgmPlayer; // música de fundo (opening theme)
  AudioPlayer? _ambiencePlayer; // ambiência (vulcão)
  AudioPlayer? _sfxPlayer; // efeitos sonoros

  // ═══════════════════════════════════════════════════════════════════
  //  FLAGS DE DISPONIBILIDADE
  //  Marcamos como false quando um áudio falha para não repetir erro.
  // ═══════════════════════════════════════════════════════════════════
  bool _bgmAvailable = true;
  bool _ambienceAvailable = true;

  // ═══════════════════════════════════════════════════════════════════
  //  INICIALIZAÇÃO
  // ═══════════════════════════════════════════════════════════════════

  /// Inicializa os players de áudio.
  /// Chamar uma vez no bootstrap do jogo.
  Future<void> init() async {
    await _safe('init', () async {
      _bgmPlayer = AudioPlayer();
      _ambiencePlayer = AudioPlayer();
      _sfxPlayer = AudioPlayer();
    });
  }

  /// Libera recursos dos players.
  Future<void> dispose() async {
    await Future.wait([
      _bgmPlayer?.dispose() ?? Future.value(),
      _ambiencePlayer?.dispose() ?? Future.value(),
      _sfxPlayer?.dispose() ?? Future.value(),
    ]);
    _bgmPlayer = null;
    _ambiencePlayer = null;
    _sfxPlayer = null;
    _bgmAvailable = true;
    _ambienceAvailable = true;
  }

  // ═══════════════════════════════════════════════════════════════════
  //  WRAPER SEGURO
  // ═══════════════════════════════════════════════════════════════════

  /// Executa [action] com try/catch.
  /// Se falhar, chama [onError] (se fornecido) e faz debugPrint do erro.
  /// NUNCA relança a exceção.
  Future<void> _safe(
    String label,
    Future<void> Function() action, {
    void Function()? onError,
  }) async {
    try {
      await action();
    } catch (e, st) {
      debugPrint('[AudioService] $label failed: $e');
      debugPrint('[AudioService] stack trace: $st');
      onError?.call();
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  //  MÚSICA DE ABERTURA
  // ═══════════════════════════════════════════════════════════════════

  /// Toca a música de abertura em loop.
  /// Se falhar (web: autoplay bloqueado / codec incompatível),
  /// marca como indisponível e não tenta novamente.
  Future<void> playOpeningTheme() async {
    if (!_bgmAvailable || _bgmPlayer == null) return;
    await _safe('OpeningTheme', () async {
      await _bgmPlayer!.stop();
      await _bgmPlayer!.setSource(
        AssetSource('$_musicBase/opening_theme.mp3'),
      );
      await _bgmPlayer!.setVolume(_openingThemeVolume);
      await _bgmPlayer!.setReleaseMode(ReleaseMode.loop);
      await _bgmPlayer!.resume();
    }, onError: () {
      _bgmAvailable = false;
      debugPrint('[AudioService] OpeningTheme marked unavailable');
    });
  }

  /// Para a música de abertura.
  /// Sempre reabilita a flag [bgmAvailable], mesmo se o stop() falhar.
  Future<void> stopOpeningTheme() async {
    await _safe('StopOpeningTheme', () async {
      await _bgmPlayer?.stop();
    });
    _bgmAvailable = true;
  }

  // ═══════════════════════════════════════════════════════════════════
  //  AMBIÊNCIA DO VULCÃO
  // ═══════════════════════════════════════════════════════════════════

  /// Toca a ambiência do vulcão em loop.
  /// Se falhar, marca como indisponível.
  Future<void> playVolcanoAmbience() async {
    if (!_ambienceAvailable || _ambiencePlayer == null) return;
    await _safe('VolcanoAmbience', () async {
      await _ambiencePlayer!.stop();
      await _ambiencePlayer!.setSource(
        AssetSource('$_sfxBase/volcano_ambience.mp3'),
      );
      await _ambiencePlayer!.setVolume(_volcanoAmbienceVolume);
      await _ambiencePlayer!.setReleaseMode(ReleaseMode.loop);
      await _ambiencePlayer!.resume();
    }, onError: () {
      _ambienceAvailable = false;
      debugPrint('[AudioService] VolcanoAmbience marked unavailable');
    });
  }

  /// Para a ambiência do vulcão.
  /// Sempre reabilita a flag, mesmo se o stop() falhar.
  Future<void> stopVolcanoAmbience() async {
    await _safe('StopVolcanoAmbience', () async {
      await _ambiencePlayer?.stop();
    });
    _ambienceAvailable = true;
  }

  // ═══════════════════════════════════════════════════════════════════
  //  SFX
  // ═══════════════════════════════════════════════════════════════════

  /// Toca som de coleta de rocha.
  Future<void> playCollect() async {
    await _safe('Collect', () async {
      await _sfxPlayer?.stop();
      await _sfxPlayer!.setSource(
        AssetSource('$_sfxBase/collect.mp3'),
      );
      await _sfxPlayer!.setVolume(_collectVolume);
      await _sfxPlayer!.resume();
    });
  }

  /// Toca som de abrir bag/diário.
  Future<void> playBag() async {
    await _safe('Bag', () async {
      await _sfxPlayer?.stop();
      await _sfxPlayer!.setSource(AssetSource('$_sfxBase/bag.mp3'));
      await _sfxPlayer!.setVolume(_bagVolume);
      await _sfxPlayer!.resume();
    });
  }

  /// Toca som de clique/seleção (reaproveita bag.mp3).
  Future<void> playClick() async {
    await _safe('Click', () async {
      await _sfxPlayer?.stop();
      await _sfxPlayer!.setSource(AssetSource('$_sfxBase/bag.mp3'));
      await _sfxPlayer!.setVolume(_clickVolume);
      await _sfxPlayer!.resume();
    });
  }

  /// Toca som de vitória.
  Future<void> playWin() async {
    await _safe('Win', () async {
      await _sfxPlayer?.stop();
      await _sfxPlayer!.setSource(AssetSource('$_sfxBase/win.mp3'));
      await _sfxPlayer!.setVolume(_winVolume);
      await _sfxPlayer!.resume();
    });
  }

  /// Toca som de falha.
  Future<void> playFail() async {
    await _safe('Fail', () async {
      await _sfxPlayer?.stop();
      await _sfxPlayer!.setSource(AssetSource('$_sfxBase/fail.mp3'));
      await _sfxPlayer!.setVolume(_failVolume);
      await _sfxPlayer!.resume();
    });
  }

  // ═══════════════════════════════════════════════════════════════════
  //  CONTROLE GLOBAL
  // ═══════════════════════════════════════════════════════════════════

  /// Para todos os sons ativos.
  /// Reabilita flags de disponibilidade.
  Future<void> stopAll() async {
    await Future.wait([
      _bgmPlayer?.stop() ?? Future.value(),
      _ambiencePlayer?.stop() ?? Future.value(),
      _sfxPlayer?.stop() ?? Future.value(),
    ]);
    _bgmAvailable = true;
    _ambienceAvailable = true;
  }
}
