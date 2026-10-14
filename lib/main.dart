import 'package:flutter/material.dart';

import 'chapters/registry.dart';
import 'core/chapter_screen.dart';
import 'core/lab.dart';
import 'core/lab_screen.dart';
import 'home_screen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'แลปทบทวน Flutter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {'/': (context) => const HomeScreen()},
      // onGenerateRoute (บทที่ 9): ตรวจชนิดของ arguments ที่จุดเดียว
      // แล้วส่งให้หน้าจอผ่าน constructor
      onGenerateRoute: (settings) {
        final args = settings.arguments;
        if (settings.name == ChapterScreen.routeName && args is int) {
          final chapter = chapterByNumber(args);
          if (chapter != null) {
            return MaterialPageRoute(
              settings: settings,
              builder: (context) => ChapterScreen(chapter: chapter),
            );
          }
        }
        if (settings.name == LabScreen.routeName && args is LabArgs) {
          final chapter = chapterByNumber(args.chapterNumber);
          if (chapter != null && args.labIndex < chapter.labs.length) {
            return MaterialPageRoute(
              settings: settings,
              builder: (context) =>
                  LabScreen(chapter: chapter, lab: chapter.labs[args.labIndex]),
            );
          }
        }
        return null;
      },
    );
  }
}
