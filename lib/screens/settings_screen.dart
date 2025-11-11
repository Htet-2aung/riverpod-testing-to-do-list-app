import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../my_app.dart';
import '../providers/auth_service.dart';
import '../utils/dialogs.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});
  @override Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(isDarkModeProvider);
    final userEmail = ref.watch(authStateProvider).asData?.value?.email;
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Settings')),
      backgroundColor: CupertinoColors.systemGroupedBackground,
      child: ListView(children: [
        CupertinoListSection.insetGrouped(header: const Text('APPEARANCE'), children: [CupertinoListTile(title: const Text('Dark Mode'), trailing: CupertinoSwitch(value: isDark, onChanged: (v) => ref.read(isDarkModeProvider.notifier).state = v))]),
        CupertinoListSection.insetGrouped(header: const Text('ACCOUNT'), footer: Text('Logged in as: ${userEmail ?? "Guest"}'), children: [CupertinoListTile(title: const Text('Logout', style: TextStyle(color: CupertinoColors.systemRed)), leading: const Icon(CupertinoIcons.square_arrow_left, color: CupertinoColors.systemRed), onTap: () => showCupertinoConfirmationDialog(context, title: 'Logout?', content: 'Are you sure you want to log out?', onConfirm: () => ref.read(authServiceProvider).signOut()))]),
        CupertinoListSection.insetGrouped(header: const Text('ABOUT'), children: const [CupertinoListTile(title: Text('State Management'), additionalInfo: Text('Riverpod')), CupertinoListTile(title: Text('UI Style'), additionalInfo: Text('Cupertino (iOS)'))]),
      ]),
    );
  }
}