import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis/calendar/v3.dart' as GoogleCalendar;
import 'package:googleapis_auth/auth_io.dart' as auth;

import '../config.dart';
import 'auth_service.dart';

class CalendarEvent {
  final String id, title;
  final DateTime date;
  final bool isGoogleEvent;
  CalendarEvent({required this.id, required this.title, required this.date, this.isGoogleEvent = false});
}

final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day));

class ManualEventsNotifier extends StateNotifier<List<CalendarEvent>> {
  ManualEventsNotifier() : super([
    CalendarEvent(id: 'manual-1', title: 'Review Project (Manual)', date: DateTime.now().add(const Duration(hours: 2))),
  ]);
  void addEvent(String t, DateTime d) => state = [...state, CalendarEvent(id: DateTime.now().millisecondsSinceEpoch.toString(), title: t, date: d)];
  void removeEvent(String id) => state = state.where((e) => e.id != id).toList();
}

final manualEventsProvider = StateNotifierProvider<ManualEventsNotifier, List<CalendarEvent>>((ref) => ManualEventsNotifier());

// ---------------------------------------------------------------
// CALENDAR API PROVIDER – uses the same token-exchange flow
// ---------------------------------------------------------------
final calendarApiProvider = FutureProvider<GoogleCalendar.CalendarApi?>((ref) async {
  final user = ref.watch(authStateProvider).asData?.value;
  if (user == null) return null;

  final gsi = GoogleSignIn(clientId: googleWebClientId, scopes: [GoogleCalendar.CalendarApi.calendarReadonlyScope]);
  GoogleSignInAccount? googleUser;

  // Try silent first
  try {
    googleUser = await gsi.signInSilently();
  } catch (_) {}

  // If silent fails → interactive
  googleUser ??= await gsi.signIn();
  if (googleUser == null) return null;

  final googleAuth = await googleUser.authentication;
  final serverAuthCode = googleAuth.serverAuthCode;
  if (serverAuthCode == null) return null;

  final tokenResp = await http.post(
    Uri.parse('https://oauth2.googleapis.com/token'),
    body: {
      'code': serverAuthCode,
      'client_id': googleWebClientId,
      'grant_type': 'authorization_code',
      'redirect_uri': '',
    },
  );

  if (tokenResp.statusCode != 200) return null;
  final tokens = jsonDecode(tokenResp.body) as Map<String, dynamic>;
  final accessToken = tokens['access_token'] as String?;
  final idToken = tokens['id_token'] as String?;
  if (accessToken == null || idToken == null) return null;

  final creds = auth.AccessCredentials(
    auth.AccessToken('Bearer', accessToken, DateTime.now().toUtc().add(const Duration(hours: 1))),
    null,
    [GoogleCalendar.CalendarApi.calendarReadonlyScope],
    idToken: idToken,
  );

  final client = auth.authenticatedClient(http.Client(), creds);
  return GoogleCalendar.CalendarApi(client);
});

final calendarEventsProvider = FutureProvider<List<CalendarEvent>>((ref) async {
  final manual = ref.watch(manualEventsProvider);
  final api = ref.watch(calendarApiProvider).asData?.value;
  if (api == null) return manual;

  try {
    final now = DateTime.now().toUtc();
    final events = await api.events.list(
      'primary',
      timeMin: now.subtract(const Duration(days: 30)),
      timeMax: now.add(const Duration(days: 30)),
      singleEvents: true,
      orderBy: 'startTime',
    );
    final googleEvents = <CalendarEvent>[];
    for (var e in events.items ?? []) {
      final title = e.summary;
      final date = e.start?.dateTime?.toLocal() ?? e.start?.date?.toLocal();
      if (title != null && date != null && e.id != null) {
        googleEvents.add(CalendarEvent(id: e.id!, title: title, date: date, isGoogleEvent: true));
      }
    }
    return [...manual, ...googleEvents];
  } catch (e) {
    print('Calendar error: $e');
    return manual;
  }
});

final eventsForSelectedDayProvider = Provider<AsyncValue<List<CalendarEvent>>>((ref) {
  final date = ref.watch(selectedDateProvider);
  return ref.watch(calendarEventsProvider).whenData((events) {
    final filtered = events.where((e) => e.date.year == date.year && e.date.month == date.month && e.date.day == date.day).toList();
    filtered.sort((a, b) => a.date.compareTo(b.date));
    return filtered;
  });
});