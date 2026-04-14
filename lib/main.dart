import 'package:flutter/material.dart';

import 'screens/dashboard_screen.dart';
import 'services/task_service.dart';
import 'services/voice_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final taskService = TaskService();
  await taskService.init();

  runApp(MyApp(taskService: taskService));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key, required this.taskService});

  final TaskService taskService;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final VoiceService _voiceService = VoiceService();

  @override
  void dispose() {
    _voiceService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Personal Assistant',
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        colorSchemeSeed: Colors.teal,
        scaffoldBackgroundColor: const Color(0xFF121212),
      ),
      home: DashboardScreen(
        taskService: widget.taskService,
        voiceService: _voiceService,
      ),
    );
  }
}
