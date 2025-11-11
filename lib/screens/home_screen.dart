import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/todo_provider.dart';
import '../utils/dialogs.dart';
import '../widgets/todo_tile.dart';
import 'add_todo_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final open = ref.watch(uncompletedCountProvider);
    final todos = ref.watch(filteredTodoListProvider);
    final filter = ref.watch(todoFilterProvider);
    final hasCompleted = ref.watch(hasCompletedTodosProvider);
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Tasks ($open open)'),
        leading: hasCompleted
            ? CupertinoButton(
                padding: EdgeInsets.zero,
                child: const Icon(CupertinoIcons.delete_solid, color: CupertinoColors.systemRed, size: 24),
                onPressed: () => showCupertinoConfirmationDialog(
                  context,
                  title: 'Clear Completed?',
                  content: 'Delete all completed tasks permanently.',
                  onConfirm: () => ref.read(todoListProvider.notifier).clearCompleted(),
                ),
              )
            : null,
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.of(context, rootNavigator: true).push(CupertinoPageRoute(fullscreenDialog: true, builder: (_) => const AddTodoScreen())),
          child: const Icon(CupertinoIcons.add),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: CupertinoSegmentedControl<TodoFilter>(
              children: const {
                TodoFilter.all: Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('All')),
                TodoFilter.active: Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('Active')),
                TodoFilter.completed: Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('Completed')),
              },
              groupValue: filter,
              onValueChanged: (v) => ref.read(todoFilterProvider.notifier).state = v,
            ),
          ),
          Expanded(
            child: todos.isEmpty
                ? Center(child: Text('No ${filter.name} tasks', style: const TextStyle(color: CupertinoColors.secondaryLabel)))
                : ListView.builder(itemCount: todos.length, itemBuilder: (_, i) => TodoTile(todo: todos[i])),
          ),
        ]),
      ),
    );
  }
}