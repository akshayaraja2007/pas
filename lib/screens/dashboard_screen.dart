import 'package:flutter/material.dart';

import '../models/task_item.dart';
import '../services/task_service.dart';
import '../services/voice_service.dart';
import '../widgets/section_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key, required this.taskService, required this.voiceService});

  final TaskService taskService;
  final VoiceService voiceService;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final TextEditingController _taskController = TextEditingController();
  final TextEditingController _plannerController = TextEditingController();
  final TextEditingController _habitController = TextEditingController();

  List<TaskItem> _items = <TaskItem>[];
  String _voiceText = 'Tap microphone to speak';
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    setState(() {
      _items = widget.taskService.getAll();
    });
  }

  Future<void> _addItem({required String title, required bool isHabit}) async {
    if (title.trim().isEmpty) return;
    final now = DateTime.now();
    final item = TaskItem(
      id: '${now.millisecondsSinceEpoch}-${title.hashCode}',
      title: title.trim(),
      notes: isHabit ? 'Habit' : 'Task',
      date: now,
      isHabit: isHabit,
    );
    await widget.taskService.upsert(item);
    _refresh();
  }

  Future<void> _addPlannerEntry(String title) async {
    if (title.trim().isEmpty) return;
    final now = DateTime.now();
    final item = TaskItem(
      id: '${now.millisecondsSinceEpoch}-${title.hashCode}',
      title: title.trim(),
      notes: 'Planner',
      date: now,
    );
    await widget.taskService.upsert(item);
    _refresh();
  }

  Future<void> _toggle(TaskItem item) async {
    await widget.taskService.toggleDone(item);
    _refresh();
  }

  Future<void> _delete(TaskItem item) async {
    await widget.taskService.delete(item.id);
    _refresh();
  }

  Future<void> _listen() async {
    if (_isListening) {
      await widget.voiceService.stopListening();
      setState(() {
        _isListening = false;
      });
      return;
    }

    setState(() {
      _isListening = true;
      _voiceText = 'Listening...';
    });

    await widget.voiceService.listen(
      onResult: (text) async {
        if (!mounted) return;
        setState(() {
          _voiceText = text;
        });

        if (text.toLowerCase().startsWith('add task ')) {
          final task = text.substring(9);
          await _addItem(title: task, isHabit: false);
          await widget.voiceService.speak('Task added');
        }
      },
    );

    if (mounted) {
      setState(() {
        _isListening = false;
      });
    }
  }

  @override
  void dispose() {
    _taskController.dispose();
    _plannerController.dispose();
    _habitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tasks = _items.where((item) => !item.isHabit && item.notes != 'Planner').toList();
    final planner = _items.where((item) => item.notes == 'Planner').toList();
    final habits = _items.where((item) => item.isHabit).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Personal Assistant'),
        actions: [
          IconButton(
            onPressed: () => widget.voiceService.speak('Hello, I am ready to assist you.'),
            icon: const Icon(Icons.volume_up_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _listen,
        icon: Icon(_isListening ? Icons.mic_off : Icons.mic),
        label: Text(_isListening ? 'Stop' : 'Voice'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SectionCard(
            title: 'Voice Assistant',
            trailing: Icon(_isListening ? Icons.hearing : Icons.record_voice_over),
            child: Text(_voiceText),
          ),
          const SizedBox(height: 12),
          SectionCard(
            title: 'Task Manager',
            child: Column(
              children: [
                _inputRow(
                  controller: _taskController,
                  hint: 'Add a task',
                  onSubmit: () async {
                    await _addItem(title: _taskController.text, isHabit: false);
                    _taskController.clear();
                  },
                ),
                _itemList(tasks),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SectionCard(
            title: 'Daily Planner',
            child: Column(
              children: [
                _inputRow(
                  controller: _plannerController,
                  hint: 'Plan your day',
                  onSubmit: () async {
                    await _addPlannerEntry(_plannerController.text);
                    _plannerController.clear();
                  },
                ),
                _itemList(planner),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SectionCard(
            title: 'Habit Tracker',
            child: Column(
              children: [
                _inputRow(
                  controller: _habitController,
                  hint: 'Add a habit',
                  onSubmit: () async {
                    await _addItem(title: _habitController.text, isHabit: true);
                    _habitController.clear();
                  },
                ),
                _itemList(habits),
              ],
            ),
          ),
          const SizedBox(height: 86),
        ],
      ),
    );
  }

  Widget _inputRow({
    required TextEditingController controller,
    required String hint,
    required Future<void> Function() onSubmit,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: hint,
                border: const OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: onSubmit,
            icon: const Icon(Icons.add_circle_outline),
          ),
        ],
      ),
    );
  }

  Widget _itemList(List<TaskItem> items) {
    if (items.isEmpty) {
      return const Align(
        alignment: Alignment.centerLeft,
        child: Text('No items yet'),
      );
    }

    return Column(
      children: items
          .map(
            (item) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Checkbox(
                value: item.isDone,
                onChanged: (_) => _toggle(item),
              ),
              title: Text(item.title),
              subtitle: Text(item.date.toLocal().toString().split('.').first),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _delete(item),
              ),
            ),
          )
          .toList(),
    );
  }
}
