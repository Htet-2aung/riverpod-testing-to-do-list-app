import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum PomodoroPhase { work, shortBreak, longBreak, stopped }

class PomodoroSettings {
  final int workDuration, shortBreakDuration, longBreakDuration;
  PomodoroSettings({required this.workDuration, required this.shortBreakDuration, required this.longBreakDuration});
  PomodoroSettings copyWith({int? workDuration, int? shortBreakDuration, int? longBreakDuration}) {
    return PomodoroSettings(
      workDuration: workDuration ?? this.workDuration,
      shortBreakDuration: shortBreakDuration ?? this.shortBreakDuration,
      longBreakDuration: longBreakDuration ?? this.longBreakDuration,
    );
  }
}

class SettingsNotifier extends StateNotifier<PomodoroSettings> {
  SettingsNotifier() : super(PomodoroSettings(workDuration: 25 * 60, shortBreakDuration: 5 * 60, longBreakDuration: 15 * 60));
  void setWorkDuration(int s) => state = state.copyWith(workDuration: s);
  void setShortBreakDuration(int s) => state = state.copyWith(shortBreakDuration: s);
  void setLongBreakDuration(int s) => state = state.copyWith(longBreakDuration: s);
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, PomodoroSettings>((ref) => SettingsNotifier());

class PomodoroNotifier extends StateNotifier<int> {
  final Ref _ref;
  Timer? _timer;
  PomodoroPhase _phase = PomodoroPhase.stopped;
  PomodoroPhase get phase => _phase;
  int _rounds = 0;
  PomodoroSettings get s => _ref.read(settingsProvider);

  PomodoroNotifier(this._ref) : super(25 * 60) { state = s.workDuration; }

  void start() {
    if (_phase == PomodoroPhase.stopped) { _phase = PomodoroPhase.work; state = s.workDuration; }
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state > 0) state--; else _next();
    });
  }

  void pause() => _timer?.cancel();
  void reset() { _timer?.cancel(); _phase = PomodoroPhase.stopped; _rounds = 0; state = s.workDuration; }
  void skip() { _timer?.cancel(); _next(); }

  void _next() {
    _timer?.cancel();
    if (_phase == PomodoroPhase.work) {
      _rounds++;
      _phase = _rounds % 4 == 0 ? PomodoroPhase.longBreak : PomodoroPhase.shortBreak;
      state = _phase == PomodoroPhase.longBreak ? s.longBreakDuration : s.shortBreakDuration;
    } else {
      _phase = PomodoroPhase.work;
      state = s.workDuration;
    }
    if (_phase != PomodoroPhase.stopped) _timer = Timer.periodic(const Duration(seconds: 1), (_) { if (state > 0) state--; else _next(); });
  }

  @override void dispose() { _timer?.cancel(); super.dispose(); }
}

final pomodoroProvider = StateNotifierProvider<PomodoroNotifier, int>((ref) => PomodoroNotifier(ref));