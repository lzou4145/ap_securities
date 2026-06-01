import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Short UI swoosh when a trade action succeeds (asset: `assets/sounds/trade_success_whoosh.wav`).
///
/// Replace that WAV with MT4's `Ok.wav` from the terminal `Sounds` folder if you
/// want the exact MetaTrader sound — see `assets/sounds/README.md`.
///
/// Uses [AVAudioSessionCategory.soloAmbient] on iOS so the hardware mute switch
/// is respected (no sound when muted).
abstract final class TradeOrderSuccessSound {
  static const _assetPath = 'sounds/trade_success_whoosh.wav';

  static AudioPlayer? _player;
  static var _ready = false;

  static Future<void> _ensureReady() async {
    if (_ready) return;
    _ready = true;
    await AudioPlayer.global.setAudioContext(
      AudioContext(
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.soloAmbient,
        ),
        android: AudioContextAndroid(
          isSpeakerphoneOn: false,
          stayAwake: false,
          contentType: AndroidContentType.sonification,
          usageType: AndroidUsageType.assistanceSonification,
          audioFocus: AndroidAudioFocus.gainTransient,
        ),
      ),
    );
    _player = AudioPlayer();
    await _player!.setReleaseMode(ReleaseMode.stop);
  }

  static Future<void> play() async {
    try {
      await _ensureReady();
      final player = _player!;
      await player.stop();
      await player.play(AssetSource(_assetPath), volume: 1);
    } on Object catch (e, st) {
      if (kDebugMode) {
        debugPrint('TradeOrderSuccessSound failed: $e\n$st');
      }
    }
  }
}
