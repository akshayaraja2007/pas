import 'package:flutter_test/flutter_test.dart';
import 'package:personal_assistant/models/task_item.dart';

void main() {
  test('TaskItem map conversion', () {
    final item = TaskItem(
      id: '1',
      title: 'Sample',
      date: DateTime.parse('2026-01-01T00:00:00.000'),
    );

    final map = item.toMap();
    final restored = TaskItem.fromMap(map);

    expect(restored.id, '1');
    expect(restored.title, 'Sample');
  });
}
