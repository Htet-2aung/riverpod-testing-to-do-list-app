import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/auth_service.dart';
import 'screens/auth_screen.dart';
import 'screens/main_tabs_screen.dart';

// Global App Settings Provider
final isDarkModeProvider = StateProvider<bool>((ref) => false);

class MyApp extends ConsumerWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dark = ref.watch(isDarkModeProvider);
    final auth = ref.watch(authStateProvider);
    return CupertinoApp(
      debugShowCheckedModeBanner: false,
      theme: CupertinoThemeData(brightness: dark ? Brightness.dark : Brightness.light, primaryColor: CupertinoColors.systemIndigo),
      home: auth.when(
        data: (u) => u != null ? const MainTabbedScreen() : const AuthenticationScreen(),
        loading: () => const Center(child: CupertinoActivityIndicator()),
        error: (_, __) => const Center(child: Text('Auth error')),
      ),
    );
  }
}