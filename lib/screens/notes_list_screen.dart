import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/notes_provider.dart';
import 'note_editor_screen.dart';

class NotesListScreen extends ConsumerWidget {
  const NotesListScreen({super.key});
  @override Widget build(BuildContext context, WidgetRef ref) {
    final notes = ref.watch(notesProvider);
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(middle: const Text('Notes'), trailing: CupertinoButton(padding: EdgeInsets.zero, child: const Icon(CupertinoIcons.add), onPressed: () => Navigator.of(context, rootNavigator: true).push(CupertinoPageRoute(fullscreenDialog: true, builder: (_) => const NoteEditorScreen())))),
      child: SafeArea(bottom: false, child: notes.isEmpty ? const Center(child: Text('No notes yet. Tap + to create one.', style: TextStyle(color: CupertinoColors.secondaryLabel))) : ListView.builder(itemCount: notes.length, itemBuilder: (context, index) {
        final note = notes[index];
        return Dismissible(
          key: Key(note.id),
          direction: DismissDirection.endToStart,
          onDismissed: (_) => ref.read(notesProvider.notifier).removeNote(note.id),
          background: Container(color: CupertinoColors.systemRed, alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20), child: const Icon(CupertinoIcons.delete_solid, color: CupertinoColors.white)),
          child: CupertinoListTile(
            title: Text(note.title, maxLines: 1, overflow: TextOverflow.ellipsis),
            subtitle: Text('${DateFormat.yMd().add_jm().format(note.lastEdited)} - ${note.content}', maxLines: 1, overflow: TextOverflow.ellipsis),
            onTap: () => Navigator.of(context, rootNavigator: true).push(CupertinoPageRoute(fullscreenDialog: true, builder: (_) => NoteEditorScreen(noteToEdit: note))),
          ),
        );
      })),
    );
  }
}