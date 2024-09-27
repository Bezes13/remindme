import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:remindme/screens/entry_list_screen.dart';
import 'my_app_state.dart';
import 'screens/creation_screen.dart';
import 'theme/my_theme.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();

  static _MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>()!;
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Remind Me',
        darkTheme: ThemeData.dark().copyWith(
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            backgroundColor: Colors.pinkAccent,
          ),
        ),
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.pinkAccent),
          inputDecorationTheme: MyTheme().theme(),
        ),
        themeMode: _themeMode,
        routes: {
          '/': (context) => EntryListScreen(),
          '/another': (context) => CreationScreen(),
        },
      ),
    );
  }

  void changeTheme(ThemeMode themeMode) {
    setState(() {
      _themeMode = themeMode;
    });
  }
}
