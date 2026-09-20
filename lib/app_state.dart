import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppState {
  AppState._();

  static final AppState instance = AppState._();

  static const dashboardMusic = 'assets/music/dashboard.mp3';
  static const stageMusic = 'assets/music/stage.mp3';
  static const stage4Music = 'assets/music/4.mp3';
  static const tapSound = 'assets/music/tap.mp3';
  static const lockSound = 'assets/music/lock.mp3';
  static const waterSound = 'assets/music/water.mp3';

  static const _musicKey = 'settings.musicOn';
  static const _soundKey = 'settings.soundOn';
  static const _hintKey = 'settings.hintOn';
  static const _progressKey = 'progress.maxStage';
  static const _introSeenKey = 'progress.appIntroSeen';
  static const _currentStageKey = 'progress.currentStage';
  static const _hintDateKey = 'hints.date';
  static const _hintCountKey = 'hints.count';
  static const _hintIdsKey = 'hints.ids';

  final ValueNotifier<bool> musicOn = ValueNotifier<bool>(true);
  final ValueNotifier<bool> soundOn = ValueNotifier<bool>(true);
  final ValueNotifier<bool> hintOn = ValueNotifier<bool>(true);
  final ValueNotifier<int> maxStage = ValueNotifier<int>(1);
  final ValueNotifier<int> hintUsageVersion = ValueNotifier<int>(0);

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    musicOn.value = _prefs?.getBool(_musicKey) ?? true;
    soundOn.value = _prefs?.getBool(_soundKey) ?? true;
    hintOn.value = _prefs?.getBool(_hintKey) ?? true;
    maxStage.value = (_prefs?.getInt(_progressKey) ?? 1).clamp(1, 5);
  }

  bool get appIntroSeen => _prefs?.getBool(_introSeenKey) ?? false;

  Future<void> setAppIntroSeen(bool value) async {
    await _prefs?.setBool(_introSeenKey, value);
  }

  int get currentStage => _prefs?.getInt(_currentStageKey) ?? 0;

  Future<void> setCurrentStage(int stage) async {
    await _prefs?.setInt(_currentStageKey, stage);
  }

  Future<void> setMusicOn(bool value) async {
    musicOn.value = value;
    await _prefs?.setBool(_musicKey, value);
  }

  Future<void> setSoundOn(bool value) async {
    soundOn.value = value;
    await _prefs?.setBool(_soundKey, value);
  }

  Future<void> setHintOn(bool value) async {
    hintOn.value = value;
    await _prefs?.setBool(_hintKey, value);
  }

  Future<void> unlockStage(int stage) async {
    final next = stage.clamp(1, 5);
    if (next <= maxStage.value) return;
    maxStage.value = next;
    await _prefs?.setInt(_progressKey, next);
  }

  Future<void> resetAll() async {
    final prefs = _prefs;
    if (prefs == null) return;
    await prefs.clear();
    musicOn.value = true;
    soundOn.value = true;
    hintOn.value = true;
    maxStage.value = 1;
  }

  Future<void> resetCurrentLevel() async {
    final stage = currentStage;
    if (stage <= 0) return;
    await _prefs?.remove('stage$stage.introSeen');
    await _prefs?.remove('stage$stage.postIntroDialogShown');
  }

  bool stageIntroSeen(int stage) =>
      _prefs?.getBool('stage$stage.introSeen') ?? false;

  Future<void> setStageIntroSeen(int stage, bool value) async {
    await _prefs?.setBool('stage$stage.introSeen', value);
  }

  bool stagePostIntroDialogShown(int stage) =>
      _prefs?.getBool('stage$stage.postIntroDialogShown') ?? false;

  Future<void> setStagePostIntroDialogShown(int stage, bool value) async {
    await _prefs?.setBool('stage$stage.postIntroDialogShown', value);
  }

  bool isHintUnlockedToday(String id) {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final savedDate = _prefs?.getString(_hintDateKey);
    if (savedDate != today) return false;
    return _prefs?.getStringList(_hintIdsKey)?.contains(id) ?? false;
  }

  Future<bool> useHint(String id) async {
    final prefs = _prefs;
    if (prefs == null) return false;
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final savedDate = prefs.getString(_hintDateKey);
    if (savedDate != today) {
      await prefs.setString(_hintDateKey, today);
      await prefs.setInt(_hintCountKey, 0);
      await prefs.setStringList(_hintIdsKey, const []);
      hintUsageVersion.value++;
    }
    final ids = prefs.getStringList(_hintIdsKey) ?? [];
    if (ids.contains(id)) return true;
    var count = savedDate == today ? prefs.getInt(_hintCountKey) ?? 0 : 0;
    if (count >= 2) return false;
    count++;
    await prefs.setString(_hintDateKey, today);
    await prefs.setInt(_hintCountKey, count);
    await prefs.setStringList(_hintIdsKey, [...ids, id]);
    hintUsageVersion.value++;
    return true;
  }

  int get remainingHintsToday {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final savedDate = _prefs?.getString(_hintDateKey);
    final count = savedDate == today ? _prefs?.getInt(_hintCountKey) ?? 0 : 0;
    return (2 - count).clamp(0, 2);
  }
}
