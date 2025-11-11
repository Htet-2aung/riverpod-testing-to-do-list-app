import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/pomodoro_provider.dart';

class PomodoroScreen extends ConsumerWidget {
  const PomodoroScreen({super.key});
  @override Widget build(BuildContext context, WidgetRef ref) {
    final seconds = ref.watch(pomodoroProvider);
    final phase = ref.read(pomodoroProvider.notifier).phase;
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Pomodoro Timer')),
      child: SafeArea(child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text('$minutes:$secs', style: const TextStyle(fontSize: 72, fontWeight: FontWeight.bold)),
        Text(phase.name.toUpperCase(), style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 40),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          CupertinoButton.filled(child: const Text('Start'), onPressed: () => ref.read(pomodoroProvider.notifier).start()),
          const SizedBox(width: 16),
          CupertinoButton(child: const Text('Pause'), onPressed: () => ref.read(pomodoroProvider.notifier).pause()),
          const SizedBox(width: 16),
          CupertinoButton(child: const Text('Reset'), onPressed: () => ref.read(pomodoroProvider.notifier).reset()),
        ]),
      ]))),
    );
  }
}