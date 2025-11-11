import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/todo_provider.dart';

class AddTodoScreen extends ConsumerStatefulWidget {
  final TodoItem? todoToEdit;
  const AddTodoScreen({super.key, this.todoToEdit});
  @override ConsumerState<AddTodoScreen> createState() => _AddTodoScreenState();
}

class _AddTodoScreenState extends ConsumerState<AddTodoScreen> {
  late final TextEditingController _controller;
  late Priority _selectedPriority;
  bool get _isEditing => widget.todoToEdit != null;

  @override void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.todoToEdit?.description ?? '');
    _selectedPriority = widget.todoToEdit?.priority ?? Priority.none;
  }

  void _save() {
    final desc = _controller.text;
    if (desc.isEmpty) return;
    if (_isEditing) {
      ref.read(todoListProvider.notifier).editTodo(widget.todoToEdit!.id, desc, _selectedPriority);
    } else {
      ref.read(todoListProvider.notifier).addTodo(desc, _selectedPriority);
    }
    Navigator.of(context).pop();
  }

  @override Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(middle: Text(_isEditing ? 'Edit Task' : 'Add New Task'), leading: CupertinoButton(padding: EdgeInsets.zero, child: const Text('Cancel'), onPressed: () => Navigator.of(context).pop()), trailing: CupertinoButton(padding: EdgeInsets.zero, child: Text(_isEditing ? 'Save' : 'Add', style: const TextStyle(fontWeight: FontWeight.bold)), onPressed: _save)),
      child: SafeArea(child: Padding(padding: const EdgeInsets.all(16.0), child: Column(children: [
        CupertinoTextField(controller: _controller, autofocus: true, placeholder: 'Task Description', padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: CupertinoColors.secondarySystemFill, borderRadius: BorderRadius.circular(8))),
        const SizedBox(height: 24),
        const Align(alignment: Alignment.centerLeft, child: Text('Priority', style: TextStyle(color: CupertinoColors.secondaryLabel))),
        const SizedBox(height: 8),
        CupertinoSegmentedControl<Priority>(groupValue: _selectedPriority, onValueChanged: (v) => setState(() => _selectedPriority = v), children: const { Priority.none: Padding(padding: EdgeInsets.all(8), child: Text('None')), Priority.low: Padding(padding: EdgeInsets.all(8), child: Text('Low')), Priority.medium: Padding(padding: EdgeInsets.all(8), child: Text('Medium')), Priority.high: Padding(padding: EdgeInsets.all(8), child: Text('High')) }),
      ]))),
    );
  }
}