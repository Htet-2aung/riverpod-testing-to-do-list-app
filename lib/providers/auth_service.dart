import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart' as GoogleCalendar;

import '../config.dart';
import 'todo_provider.dart';
import 'calendar_provider.dart';
import 'pomodoro_provider.dart';
import 'notes_provider.dart';

// -------------------------------------------------------------------
// PROVIDERS
// -------------------------------------------------------------------
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(firebaseAuthProvider).authStateChanges();
});

final isGoogleConnectedProvider = Provider<bool>((ref) {
  final user = ref.watch(authStateProvider).asData?.value;
  return user?.providerData.any((p) => p.providerId == 'google.com') ?? false;
});

class AuthService {
  final Ref _ref;
  AuthService(this._ref);

  FirebaseAuth get _auth => _ref.read(firebaseAuthProvider);

  // Helper – creates a GoogleSignIn instance with the required scopes
  GoogleSignIn _googleSignIn() => GoogleSignIn(
        clientId: googleWebClientId,
        scopes: [GoogleCalendar.CalendarApi.calendarReadonlyScope],
      );

  // ---------------------------------------------------------------
  // GOOGLE SIGN-IN (web) – uses serverAuthCode → token endpoint
  // ---------------------------------------------------------------
  Future<void> signInWithGoogle() async {
    final gsi = _googleSignIn();
    final googleUser = await gsi.signIn();
    if (googleUser == null) throw Exception('Google Sign-In aborted');

    final googleAuth = await googleUser.authentication;
    final serverAuthCode = googleAuth.serverAuthCode;
    if (serverAuthCode == null) throw Exception('No serverAuthCode');

    // Exchange serverAuthCode for access/id tokens
    final tokenResponse = await http.post(
      Uri.parse('https://oauth2.googleapis.com/token'),
      body: {
        'code': serverAuthCode,
        'client_id': googleWebClientId,
        'grant_type': 'authorization_code',
        'redirect_uri': '',
      },
    );

    if (tokenResponse.statusCode != 200) {
      throw Exception('Token exchange failed: ${tokenResponse.body}');
    }

    final tokens = jsonDecode(tokenResponse.body) as Map<String, dynamic>;
    final accessToken = tokens['access_token'] as String?;
    final idToken = tokens['id_token'] as String?;
    if (accessToken == null || idToken == null) {
      throw Exception('Missing tokens');
    }

    final credential = GoogleAuthProvider.credential(
      accessToken: accessToken,
      idToken: idToken,
    );

    await _auth.signInWithCredential(credential);
  }

  Future<void> signInWithEmail(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signUpWithEmail(String email, String password) async {
    await _auth.createUserWithEmailAndPassword(email: email, password: password);
  }

  Future<void> forgotPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> signOut() async {
    await _googleSignIn().signOut();
    await _auth.signOut();
    _ref.invalidate(todoListProvider);
    _ref.invalidate(manualEventsProvider);
    _ref.invalidate(pomodoroProvider);
    _ref.invalidate(settingsProvider);
    _ref.invalidate(notesProvider);
    _ref.invalidate(calendarApiProvider);
  }
}

final authServiceProvider = Provider((ref) => AuthService(ref));
final authLoadingProvider = StateProvider<bool>((ref) => false);
final authEmailErrorProvider = StateProvider<String?>((ref) => null);
final authPasswordErrorProvider = StateProvider<String?>((ref) => null);