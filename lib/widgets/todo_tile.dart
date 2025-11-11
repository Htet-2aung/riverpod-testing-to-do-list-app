import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/todo_provider.dart';
import '../screens/add_todo_screen.dart';

class TodoTile extends ConsumerWidget {
  final TodoItem todo;
  const TodoTile({super.key, required this.todo});

  Color _priorityColor(Priority p) => switch (p) { Priority.high => CupertinoColors.systemRed, Priority.medium => CupertinoColors.systemOrange, Priority.low => CupertinoColors.systemBlue, _ => CupertinoColors.inactiveGray };

  void _showEditSheet(BuildContext context, WidgetRef ref) => Navigator.of(context, rootNavigator: true).push(CupertinoPageRoute(fullscreenDialog: true, builder: (_) => AddTodoScreen(todoToEdit: todo)));

  @override Widget build(BuildContext context, WidgetRef ref) {
    return CupertinoListTile(
      onTap: () => _showEditSheet(context, ref),
      leading: CupertinoButton(padding: EdgeInsets.zero, onPressed: () => ref.read(todoListProvider.notifier).toggle(todo.id), child: Icon(todo.completed ? CupertinoIcons.checkmark_circle_fill : CupertinoIcons.circle, color: todo.completed ? CupertinoColors.systemGreen : CupertinoColors.systemGrey)),
      title: Text(todo.description, style: TextStyle(decoration: todo.completed ? TextDecoration.lineThrough : null, color: todo.completed ? CupertinoColors.secondaryLabel : CupertinoColors.label)),
      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(todo.priority == Priority.none ? CupertinoIcons.flag : CupertinoIcons.flag_fill, color: _priorityColor(todo.priority), size: 20),
        const SizedBox(width: 8),
        CupertinoButton(padding: EdgeInsets.zero, onPressed: () => ref.read(todoListProvider.notifier).remove(todo.id), child: const Icon(CupertinoIcons.delete, color: CupertinoColors.systemRed)),
      ]),
    );
  }
}