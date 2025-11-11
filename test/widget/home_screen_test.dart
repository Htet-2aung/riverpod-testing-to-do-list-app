import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_state_management/widgets/todo_tile.dart'; 
import 'package:flutter_state_management/screens/home_screen.dart';     
import 'package:flutter_state_management/providers/todo_provider.dart'; 
Widget createTestableWidget(Widget child, List<Override> overrides) {
  return ProviderScope(
    overrides: overrides,
    child: CupertinoApp(
      home: child,
    ),
  );
}

void main() {
  // Define our fake data
  final todoList = [
    TodoItem(id: '1', description: 'Active Task', priority: Priority.high),
    TodoItem(id: '2', description: 'Completed Task', completed: true),
  ];

  group('HomeScreen Widget Test', () {
    testWidgets('Displays tasks and correct open count', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createTestableWidget(
        const HomeScreen(),
        [
          // Override the providers with fake data
          filteredTodoListProvider.overrideWithValue(todoList),
          uncompletedCountProvider.overrideWithValue(1),
          hasCompletedTodosProvider.overrideWithValue(true),
        ],
      ));

      // Assert
      expect(find.text('Tasks (1 open)'), findsOneWidget); // Checks nav bar title
      expect(find.text('Active Task'), findsOneWidget);     // Finds first task
      expect(find.text('Completed Task'), findsOneWidget);  // Finds second task
      
      // Finds the "clear completed" button
      expect(find.byIcon(CupertinoIcons.delete_solid), findsOneWidget); 
    });

    testWidgets('Shows "No tasks" message when list is empty', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createTestableWidget(
        const HomeScreen(),
        [
          filteredTodoListProvider.overrideWithValue([]), // Empty list
          uncompletedCountProvider.overrideWithValue(0),
          hasCompletedTodosProvider.overrideWithValue(false),
        ],
      ));

      // Assert
      expect(find.text('Tasks (0 open)'), findsOneWidget);
      expect(find.text('No all tasks'), findsOneWidget); // 'all' is the default filter
      expect(find.byType(TodoTile), findsNothing); // No TodoTiles
      
      // "Clear completed" button should not be visible
      expect(find.byIcon(CupertinoIcons.delete_solid), findsNothing); 
    });

    testWidgets('Tapping filter changes UI (by changing provider)', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(
        const HomeScreen(),
        [
          // We only override the main list
          todoListProvider.overrideWith((ref) => TodoListNotifier()..state = todoList),
          // Other providers will run their real logic
        ],
      ));

      // Assert initial state (Filter: All)
      expect(find.text('Active Task'), findsOneWidget);
      expect(find.text('Completed Task'), findsOneWidget);

      // Act: Tap the 'Active' filter
      await tester.tap(find.text('Active'));
      await tester.pumpAndSettle(); // Wait for UI to rebuild

      // Assert new state
      expect(find.text('Active Task'), findsOneWidget);
      expect(find.text('Completed Task'), findsNothing); // Completed task is filtered out

      // Act: Tap the 'Completed' filter
      await tester.tap(find.text('Completed'));
      await tester.pumpAndSettle();

      // Assert new state
      expect(find.text('Active Task'), findsNothing);
      expect(find.text('Completed Task'), findsOneWidget);
    });
  });
}