import 'package:flutter/cupertino.dart';
import 'home_screen.dart';
import 'calendar_screen.dart';
import 'notes_list_screen.dart';
import 'pomodoro_screen.dart';
import 'settings_screen.dart';

class MainTabbedScreen extends StatelessWidget {
  const MainTabbedScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        backgroundColor: CupertinoColors.systemBackground.withOpacity(0.9),
        items: const [
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.list_bullet), label: 'Tasks'),
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.calendar), label: 'Calendar'),
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.doc_text_fill), label: 'Notes'),
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.timer_fill), label: 'Timer'),
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.settings_solid), label: 'Settings'),
        ],
      ),
      tabBuilder: (_, i) => CupertinoTabView(builder: (_) => switch (i) {
            0 => const HomeScreen(),
            1 => const CalendarScreen(),
            2 => const NotesListScreen(),
            3 => const PomodoroScreen(),
            4 => const SettingsScreen(),
            _ => const HomeScreen(),
          }),
    );
  }
}