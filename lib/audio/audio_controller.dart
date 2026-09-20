import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

import '../app_state.dart';

class AudioController {
  AudioController._() {
    AppState.instance.musicOn.addListener(_syncMusicSetting);
    AppState.instance.soundOn.addListener(_syncSoundSetting);
  }

  static final AudioController instance = AudioController._();

  final AudioPlayer _musicPlayer = AudioPlayer(playerId: 'music');
  final AudioPlayer _tapPlayer = AudioPlayer(playerId: 'tap');
  final AudioPlayer _lockPlayer = AudioPlayer(playerId: 'lock');
  final AudioPlayer _waterPlayer = AudioPlayer(playerId: 'water');
  static const double _musicVolume = 0.35;
  static const double _tapVolume = 0.30;
  static const double _lockVolume = 1.0;
  static const double _waterVolume = 1.0;
  String? _currentMusic;
  Future<void>? _configureAudioFuture;
  bool _musicPlaying = false;
  bool _waterRequested = false;
  DateTime? _lastTapAt;
  bool _suppressNextTap = false;

  Future<void> playMusic(String assetPath) async {
    await _ensureAudioContexts();
    if (_currentMusic == assetPath &&
        _musicPlaying &&
        AppState.instance.musicOn.value) {
      return;
    }
    _currentMusic = assetPath;
    if (!AppState.instance.musicOn.value) {
      await _musicPlayer.stop();
      _musicPlaying = false;
      return;
    }
    await _musicPlayer.setReleaseMode(ReleaseMode.loop);
    await _musicPlayer.setVolume(_musicVolume);
    await _musicPlayer.play(AssetSource(_assetKey(assetPath)));
    _musicPlaying = true;
  }

  Future<void> stopMusic() async {
    await _musicPlayer.stop();
    _musicPlaying = false;
  }

  Future<void> tap() async {
    if (!_soundEffectsEnabled) return;
    if (_suppressNextTap) {
      _suppressNextTap = false;
      return;
    }
    final now = DateTime.now();
    final lastTapAt = _lastTapAt;
    if (lastTapAt != null &&
        now.difference(lastTapAt) < const Duration(milliseconds: 80)) {
      return;
    }
    _lastTapAt = now;
    await _ensureAudioContexts();
    await _tapPlayer.stop();
    await _tapPlayer.setVolume(_tapVolume);
    await _tapPlayer.play(AssetSource(_assetKey(AppState.tapSound)));
  }

  Future<void> lock() async {
    if (!_soundEffectsEnabled) return;
    await _ensureAudioContexts();
    await _lockPlayer.stop();
    await _lockPlayer.setReleaseMode(ReleaseMode.stop);
    await _lockPlayer.setVolume(_lockVolume);
    await _lockPlayer.play(AssetSource(_assetKey(AppState.lockSound)));
  }

  void suppressNextTap() {
    _suppressNextTap = true;
  }

  Future<void> setWaterLoop(bool enabled) async {
    _waterRequested = enabled;
    if (!enabled || !_soundEffectsEnabled) {
      await _waterPlayer.stop();
      return;
    }
    await _ensureAudioContexts();
    await _waterPlayer.setReleaseMode(ReleaseMode.loop);
    await _waterPlayer.setVolume(_waterVolume);
    await _waterPlayer.play(AssetSource(_assetKey(AppState.waterSound)));
  }

  Future<void> dispose() async {
    AppState.instance.musicOn.removeListener(_syncMusicSetting);
    AppState.instance.soundOn.removeListener(_syncSoundSetting);
    await _musicPlayer.dispose();
    await _tapPlayer.dispose();
    await _lockPlayer.dispose();
    await _waterPlayer.dispose();
  }

  void _syncMusicSetting() {
    final music = _currentMusic;
    if (AppState.instance.musicOn.value && music != null) {
      playMusic(music);
    } else {
      _musicPlayer.stop();
      _musicPlaying = false;
    }
  }

  void _syncSoundSetting() {
    if (_soundEffectsEnabled) {
      if (_waterRequested) {
        setWaterLoop(true);
      }
    } else {
      _tapPlayer.stop();
      _lockPlayer.stop();
      _waterPlayer.stop();
    }
  }

  Future<void> _ensureAudioContexts() {
    return _configureAudioFuture ??= _configureAudioContexts();
  }

  bool get _soundEffectsEnabled => AppState.instance.soundOn.value;

  Future<void> _configureAudioContexts() async {
    final musicContext = AudioContext(
      android: const AudioContextAndroid(
        contentType: AndroidContentType.music,
        usageType: AndroidUsageType.media,
        audioFocus: AndroidAudioFocus.gain,
      ),
      iOS: AudioContextIOS(
        category: AVAudioSessionCategory.playback,
        options: const {AVAudioSessionOptions.mixWithOthers},
      ),
    );
    final effectContext = AudioContext(
      android: const AudioContextAndroid(
        contentType: AndroidContentType.sonification,
        usageType: AndroidUsageType.assistanceSonification,
        audioFocus: AndroidAudioFocus.none,
      ),
      iOS: AudioContextIOS(
        category: AVAudioSessionCategory.playback,
        options: const {AVAudioSessionOptions.mixWithOthers},
      ),
    );

    await _musicPlayer.setAudioContext(musicContext);
    await _tapPlayer.setAudioContext(effectContext);
    await _lockPlayer.setAudioContext(effectContext);
    await _waterPlayer.setAudioContext(effectContext);
  }

  String _assetKey(String path) => path.replaceFirst('assets/', '');
}

Future<void> playTap() => AudioController.instance.tap();

Future<void> playLock() => AudioController.instance.lock();

VoidCallback withTap(VoidCallback action) {
  return () {
    AudioController.instance.tap();
    action();
  };
}
