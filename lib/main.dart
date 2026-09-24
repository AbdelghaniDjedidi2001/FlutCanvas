import 'package:flutter/material.dart';
import 'ui/whiteboard_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const WhiteboardApp());
}

class WhiteboardApp extends StatefulWidget {
  const WhiteboardApp({super.key});

  @override
  State<WhiteboardApp> createState() => _WhiteboardAppState();
}

class _WhiteboardAppState extends State<WhiteboardApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _toggleTheme(Brightness current) {
    setState(() {
      _themeMode =
          current == Brightness.dark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF3B5BDB);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mini Whiteboard',
      themeMode: _themeMode,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: seed,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: seed,
        brightness: Brightness.dark,
      ),
      home: WhiteboardPage(onToggleTheme: _toggleTheme),
    );
  }
}