import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/notes_provider.dart';

class NoteEditorScreen extends ConsumerStatefulWidget {
  final Note? noteToEdit;
  const NoteEditorScreen({super.key, this.noteToEdit});
  @override ConsumerState<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends ConsumerState<NoteEditorScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  final FocusNode _contentFocusNode = FocusNode();
  bool get _isEditing => widget.noteToEdit != null;

  @override void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.noteToEdit?.title ?? '');
    _contentController = TextEditingController(text: widget.noteToEdit?.content ?? '');
    if (!_isEditing) WidgetsBinding.instance.addPostFrameCallback((_) => _contentFocusNode.requestFocus());
  }

  @override void dispose() { _titleController.dispose(); _contentController.dispose(); _contentFocusNode.dispose(); super.dispose(); }

  void _save() {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    if (title.isEmpty && content.isEmpty) { if (_isEditing) ref.read(notesProvider.notifier).removeNote(widget.noteToEdit!.id); Navigator.of(context).pop(); return; }
    if (_isEditing) {
      ref.read(notesProvider.notifier).editNote(widget.noteToEdit!.id, title, content);
    } else {
      ref.read(notesProvider.notifier).addNote(title, content);
    }
    Navigator.of(context).pop();
  }

  @override Widget build(BuildContext context) {
    final textStyle = CupertinoTheme.of(context).textTheme.textStyle;
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(middle: Text(_isEditing ? 'Edit Note' : 'New Note'), leading: CupertinoButton(padding: EdgeInsets.zero, child: const Text('Cancel'), onPressed: () => Navigator.of(context).pop()), trailing: CupertinoButton(padding: EdgeInsets.zero, child: const Text('Done', style: TextStyle(fontWeight: FontWeight.bold)), onPressed: _save)),
      child: SafeArea(child: SingleChildScrollView(padding: const EdgeInsets.all(16.0), child: Column(children: [
        CupertinoTextField(controller: _titleController, placeholder: 'Title (Optional)', padding: const EdgeInsets.symmetric(vertical: 12), style: textStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 22), decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: CupertinoColors.separator, width: 0.5))), maxLines: 1, onSubmitted: (_) => _contentFocusNode.requestFocus()),
        const SizedBox(height: 8),
        CupertinoTextField(controller: _contentController, focusNode: _contentFocusNode, placeholder: 'Note content...', padding: const EdgeInsets.symmetric(vertical: 12), style: textStyle.copyWith(fontSize: 16), decoration: const BoxDecoration(), maxLines: null, keyboardType: TextInputType.multiline),
      ]))),
    );
  }
}