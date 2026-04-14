import 'package:hive_flutter/hive_flutter.dart';

import '../models/task_item.dart';

class TaskService {
  static const String _boxName = 'assistant_tasks';
  late final Box _box;

  Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox(_boxName);
  }

  List<TaskItem> getAll() {
    final values = _box.values
        .whereType<Map>()
        .map((entry) => TaskItem.fromMap(entry))
        .toList();
    values.sort((a, b) => a.date.compareTo(b.date));
    return values;
  }

  Future<void> upsert(TaskItem item) async {
    await _box.put(item.id, item.toMap());
  }

  Future<void> toggleDone(TaskItem item) async {
    item.isDone = !item.isDone;
    await upsert(item);
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }
}
