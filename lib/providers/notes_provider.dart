import 'package:flutter_riverpod/flutter_riverpod.dart';

class Note {
  final String id, title, content;
  final DateTime lastEdited;
  Note({required this.id, required this.title, required this.content, required this.lastEdited});
  Note copyWith({String? title, String? content, DateTime? lastEdited}) => Note(
        id: id,
        title: title ?? this.title,
        content: content ?? this.content,
        lastEdited: lastEdited ?? this.lastEdited,
      );
}

class NotesNotifier extends StateNotifier<List<Note>> {
  NotesNotifier()
      : super([
          Note(id: '1', title: 'Welcome', content: 'Sample note', lastEdited: DateTime.now()),
        ]);

  String _title(String c) => c.split('\n').first.trim().isEmpty ? 'New Note' : c.split('\n').first.trim();

  void addNote(String t, String c) => state = [
        Note(id: DateTime.now().millisecondsSinceEpoch.toString(), title: t.isEmpty ? _title(c) : t, content: c, lastEdited: DateTime.now()),
        ...state
      ];
  void editNote(String id, String t, String c) => state = [
        for (var n in state)
          if (n.id == id) n.copyWith(title: t.isEmpty ? _title(c) : t, content: c, lastEdited: DateTime.now()) else n
      ]..sort((a, b) => b.lastEdited.compareTo(a.lastEdited));
  void removeNote(String id) => state = state.where((n) => n.id != id).toList();
}

final notesProvider = StateNotifierProvider<NotesNotifier, List<Note>>((ref) => NotesNotifier());