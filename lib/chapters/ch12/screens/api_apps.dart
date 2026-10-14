import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/todo_provider.dart';
import 'future_demo_screen.dart';
import 'network_mode_bar.dart';
import 'todo_list_screen.dart';
import 'todo_provider_screen.dart';

// ============================================================================
// [คืออะไร] ตัวห่อแอปของแลปบทที่ 12 (เทียบ main.dart ของแต่ละโปรเจกต์ในตำรา)
// [ทำไม]   แต่ละแลปเริ่มจาก MaterialApp ของตัวเอง · แลป Provider ต้องห่อ MaterialApp
//          ด้วย ChangeNotifierProvider (เหมือน runApp(ChangeNotifierProvider(...)) ในบท 10-11)
//   Ch12FutureDemoApp    : home: FutureDemoScreen()
//   Ch12TodoListApp      : home: TodoListScreen()
//   Ch12TodoProviderApp  : ChangeNotifierProvider ห่อ MaterialApp (home: TodoProviderScreen())
// ============================================================================

class Ch12FutureDemoApp extends StatelessWidget {
  const Ch12FutureDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(debugShowCheckedModeBanner: false, home: FutureDemoScreen());
  }
}

class Ch12TodoListApp extends StatelessWidget {
  const Ch12TodoListApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const NetworkModeBar(
      child: MaterialApp(debugShowCheckedModeBanner: false, home: TodoListScreen()),
    );
  }
}

class Ch12TodoProviderApp extends StatelessWidget {
  const Ch12TodoProviderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return NetworkModeBar(
      // ต้องครอบ MaterialApp ด้วย ChangeNotifierProvider ใน main.dart (บทที่ 10-11)
      child: ChangeNotifierProvider(
        create: (context) => TodoProvider(),
        child: const MaterialApp(
          debugShowCheckedModeBanner: false,
          home: TodoProviderScreen(),
        ),
      ),
    );
  }
}
