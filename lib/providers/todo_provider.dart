// lib/providers/todo_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum TodoFilter { all, active, completed }  //data models
enum Priority { none, low, medium, high } //data models

class TodoItem {
  final String id;
  final String description;
  final bool completed;
  final Priority priority;
  TodoItem({required this.id, required this.description, this.completed = false, this.priority = Priority.none});
  TodoItem copyWith({String? description, bool? completed, Priority? priority}) {
    return TodoItem(
      id: id,
      description: description ?? this.description,
      completed: completed ?? this.completed,
      priority: priority ?? this.priority,
    );
  }
}

class TodoListNotifier extends StateNotifier<List<TodoItem>> {
  TodoListNotifier()
      : super([
          TodoItem(id: '1', description: 'Test Google Sign-In flow (Real)', priority: Priority.high),
          TodoItem(id: '2', description: 'Verify Calendar Sync', priority: Priority.medium),
          TodoItem(id: '3', description: 'Run Pomodoro session'),
        ]);

  void addTodo(String description, Priority priority) {
    if (description.trim().isEmpty) return;
    state = [...state, TodoItem(id: DateTime.now().millisecondsSinceEpoch.toString(), description: description.trim(), priority: priority)];
  }

  void editTodo(String id, String desc, Priority p) {
    state = [for (var t in state) if (t.id == id) t.copyWith(description: desc, priority: p) else t];
  }

  void toggle(String id) {
    state = [for (var t in state) if (t.id == id) t.copyWith(completed: !t.completed) else t];
  }

  void remove(String id) {
    state = state.where((t) => t.id != id).toList();
  }

  void clearCompleted() {
    state = state.where((t) => !t.completed).toList();
  }
}

final todoListProvider = StateNotifierProvider<TodoListNotifier, List<TodoItem>>((ref) => TodoListNotifier());
final todoFilterProvider = StateProvider<TodoFilter>((ref) => TodoFilter.all);
final filteredTodoListProvider = Provider<List<TodoItem>>((ref) {
  final f = ref.watch(todoFilterProvider);
  final todos = ref.watch(todoListProvider);
  var filtered = switch (f) {
    TodoFilter.completed => todos.where((t) => t.completed).toList(),
    TodoFilter.active => todos.where((t) => !t.completed).toList(),
    _ => todos,
  };
  filtered.sort((a, b) => b.priority.index.compareTo(a.priority.index));
  return filtered;
});
final uncompletedCountProvider = Provider<int>((ref) => ref.watch(todoListProvider).where((t) => !t.completed).length);
final hasCompletedTodosProvider = Provider<bool>((ref) => ref.watch(todoListProvider).any((t) => t.completed));