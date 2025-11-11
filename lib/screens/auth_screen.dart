import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../providers/auth_service.dart';
import '../utils/dialogs.dart';

class AuthenticationScreen extends ConsumerStatefulWidget {
  const AuthenticationScreen({super.key});
  @override ConsumerState<AuthenticationScreen> createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends ConsumerState<AuthenticationScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLogin = true;

  bool _validateFields() {
    bool ok = true;
    final email = _emailController.text;
    final password = _passwordController.text;
    if (email.isEmpty || !email.contains('@')) {
      ref.read(authEmailErrorProvider.notifier).state = 'Enter a valid email';
      ok = false;
    } else {
      ref.read(authEmailErrorProvider.notifier).state = null;
    }
    if (password.length < 6) {
      ref.read(authPasswordErrorProvider.notifier).state = 'Password ≥ 6 chars';
      ok = false;
    } else {
      ref.read(authPasswordErrorProvider.notifier).state = null;
    }
    return ok;
  }

  Future<void> _submit() async {
    if (!_isLogin && !_validateFields()) return;
    ref.read(authLoadingProvider.notifier).state = true;
    final svc = ref.read(authServiceProvider);
    try {
      if (_isLogin) {
        await svc.signInWithEmail(_emailController.text.trim(), _passwordController.text.trim());
      } else {
        await svc.signUpWithEmail(_emailController.text.trim(), _passwordController.text.trim());
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) showCupertinoErrorDialog(context, e.message ?? 'Auth error');
    } finally {
      if (mounted) ref.read(authLoadingProvider.notifier).state = false;
    }
  }

  Future<void> _google() async {
    ref.read(authLoadingProvider.notifier).state = true;
    try {
      await ref.read(authServiceProvider).signInWithGoogle();
    } catch (e) {
      if (mounted) showCupertinoErrorDialog(context, 'Google Sign-In failed: $e');
    } finally {
      if (mounted) ref.read(authLoadingProvider.notifier).state = false;
    }
  }
  // --- End of logic methods ---

  // --- UI HELPER WIDGET ---
  /// A helper to build modern, consistent text fields
  Widget _buildTextField({
    required TextEditingController controller,
    required String placeholder,
    required IconData icon,
    bool isPassword = false,
    required void Function(String) onChanged,
  }) {
    return CupertinoTextField(
      controller: controller,
      placeholder: placeholder,
      obscureText: isPassword,
      keyboardType: isPassword ? TextInputType.visiblePassword : TextInputType.emailAddress,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      // Modern prefix icon
      prefix: Padding(
        padding: const EdgeInsets.only(left: 12.0),
        child: Icon(icon, color: CupertinoColors.secondaryLabel.resolveFrom(context)),
      ),
      // Modern decoration (subtle bg, border, and radius)
      decoration: BoxDecoration(
        color: CupertinoColors.secondarySystemFill.resolveFrom(context),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: CupertinoColors.separator.resolveFrom(context),
          width: 0.5,
        ),
      ),
      onChanged: onChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    final loading = ref.watch(authLoadingProvider);
    final emailErr = ref.watch(authEmailErrorProvider);
    final pwdErr = ref.watch(authPasswordErrorProvider);
    // Use the theme's background color to ensure it's white in light mode
    final theme = CupertinoTheme.of(context);

    return CupertinoPageScaffold(
      backgroundColor: theme.scaffoldBackgroundColor, // Ensures a white background
      navigationBar: CupertinoNavigationBar(
        middle: Text(_isLogin ? 'Sign In' : 'Sign Up'),
        backgroundColor: theme.scaffoldBackgroundColor.withOpacity(0.7),
        border: null, // No border for a cleaner look
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            const SizedBox(height: 20),
            Text(
              _isLogin ? 'Welcome Back!' : 'Create Account',
              style: theme.textTheme.navLargeTitleTextStyle.copyWith(
                color: theme.textTheme.textStyle.color, // Use theme's label color
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),

            // Modern Email Field
            _buildTextField(
              controller: _emailController,
              placeholder: 'Email',
              icon: CupertinoIcons.mail,
              onChanged: (_) => !_isLogin ? _validateFields() : null,
            ),
            if (emailErr != null && !_isLogin)
              Padding(padding: const EdgeInsets.only(top: 6, left: 10), child: Text(emailErr, style: const TextStyle(color: CupertinoColors.systemRed))),
            
            const SizedBox(height: 15),

            // Modern Password Field
            _buildTextField(
              controller: _passwordController,
              placeholder: 'Password',
              icon: CupertinoIcons.lock,
              isPassword: true,
              onChanged: (_) => !_isLogin ? _validateFields() : null,
            ),
            if (pwdErr != null && !_isLogin)
              Padding(padding: const EdgeInsets.only(top: 6, left: 10), child: Text(pwdErr, style: const TextStyle(color: CupertinoColors.systemRed))),
            
            const SizedBox(height: 25),

            // --- PRIMARY BUTTON (PURPLE) ---
            SizedBox(
              height: 50, // Modern, larger tap target
              child: CupertinoButton.filled(
                borderRadius: BorderRadius.circular(12.0), // Match text fields
                onPressed: loading ? null : _submit,
                child: loading
                    ? const CupertinoActivityIndicator(color: CupertinoColors.white)
                    : Text(
                        _isLogin ? 'Sign In' : 'Sign Up',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
              ),
            ),
            
            // --- "OR" SEPARATOR ---
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Row(
                children: [
                  Expanded(child: Container(height: 1, color: CupertinoColors.separator.resolveFrom(context))),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Text('or', style: TextStyle(color: CupertinoColors.secondaryLabel.resolveFrom(context))),
                  ),
                  Expanded(child: Container(height: 1, color: CupertinoColors.separator.resolveFrom(context))),
                ],
              ),
            ),

            // --- SECONDARY BUTTON (GRAY) ---
            SizedBox(
              height: 50,
              child: CupertinoButton(
                color: CupertinoColors.secondarySystemFill.resolveFrom(context), // Light gray
                borderRadius: BorderRadius.circular(12.0),
                onPressed: loading ? null : _google,
                child: loading
                    ? CupertinoActivityIndicator(color: theme.primaryColor)
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            CupertinoIcons.device_laptop,
                            color: theme.textTheme.textStyle.color, // Use default text color
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Sign in with Google',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: theme.textTheme.textStyle.color, // Use default text color
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            
            // --- TOGGLE BUTTON (TEXT) ---
            CupertinoButton(
              onPressed: loading
                  ? null
                  : () {
                      setState(() => _isLogin = !_isLogin);
                      ref.read(authEmailErrorProvider.notifier).state = null;
                      ref.read(authPasswordErrorProvider.notifier).state = null;
                    },
              child: Text(_isLogin ? 'Need an account? Sign Up' : 'Have an account? Sign In'),
            ),
          ]),
        ),
      ),
    );
  }
}