import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_state_management/providers/todo_provider.dart'; // Adjust import

void main() {
  group('TodoListNotifier Unit Test', () {
    late TodoListNotifier notifier;

    // setUp is called before each test
    setUp(() {
      notifier = TodoListNotifier();
    });

    test('Initial state is correct', () {
      // Check the default tasks you provided
      expect(notifier.state.length, 3);
      expect(notifier.state.first.description, 'Test Google Sign-In flow (Real)');
    });

    test('addTodo adds a new item', () {
      // Get initial count
      final initialCount = notifier.state.length;

      // Act
      notifier.addTodo('A new task', Priority.low);

      // Assert
      expect(notifier.state.length, initialCount + 1);
      expect(notifier.state.last.description, 'A new task');
      expect(notifier.state.last.priority, Priority.low);
    });

    test('addTodo does not add empty tasks', () {
      final initialCount = notifier.state.length;
      notifier.addTodo('   ', Priority.none); // Empty/whitespace
      expect(notifier.state.length, initialCount);
    });

    test('toggle changes completed status', () {
      // Arrange
      final testTodo = notifier.state.first;
      expect(testTodo.completed, false); // Initial state

      // Act
      notifier.toggle(testTodo.id);

      // Assert
      expect(notifier.state.first.completed, true);

      // Act again
      notifier.toggle(testTodo.id);

      // Assert
      expect(notifier.state.first.completed, false);
    });

    test('remove deletes an item', () {
      final initialCount = notifier.state.length;
      final todoToRemove = notifier.state.first;

      notifier.remove(todoToRemove.id);

      expect(notifier.state.length, initialCount - 1);
      expect(notifier.state.any((t) => t.id == todoToRemove.id), false);
    });

    test('clearCompleted removes only completed tasks', () {
      // Arrange: complete the first two tasks
      notifier.toggle(notifier.state[0].id);
      notifier.toggle(notifier.state[1].id);
      
      // We have 2 completed, 1 active
      expect(notifier.state.where((t) => t.completed).length, 2);
      expect(notifier.state.length, 3);

      // Act
      notifier.clearCompleted();

      // Assert
      expect(notifier.state.length, 1);
      expect(notifier.state.first.completed, false);
      expect(notifier.state.first.description, 'Run Pomodoro session');
    });
  });
}