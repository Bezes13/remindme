import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:remindme/ChipSelection.dart';
import 'package:remindme/creation_page.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'entry.dart';
import 'my_app_state.dart';

main() {
  runApp(MyApp());
}

// 14 scrollbar
// 9 Font
// 7 Hero
// 4 Animated Container for chips?
// 2Launcher icon
// interactive viewer
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
        theme: ThemeData(useMaterial3: true, colorScheme: ColorScheme.fromSeed(seedColor: Colors.pinkAccent),),
        themeMode: _themeMode,
        routes: {
          '/': (context) => MyHomePage(),
          '/another': (context) => CreationPage(),
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

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _EntryListScreen();
  }
}

enum Screen { main, camera }

class _EntryListScreen extends StatefulWidget {
  @override
  _EntryListScreenState createState() => _EntryListScreenState();
}

class _EntryListScreenState extends State<_EntryListScreen> {
  final picker = ImagePicker();
  bool isDarkMode = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MyAppState>(context, listen: false).loadEntries();
    });
    isDarkMode = Theme.of(context).colorScheme.brightness == Brightness.dark;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final itemStyle = theme.textTheme.displayMedium!;
    var appState = Provider.of<MyAppState>(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
              leading: SvgPicture.asset(
                'lib/download.svg',
                semanticsLabel: '',
                height: 100,
                width: 70,
                color: Colors.pinkAccent,
              ),
              forceElevated: true,
              pinned: true,
              title: Center(
                child: RichText(
                  text: TextSpan(
                    text: 'Re',
                    style: DefaultTextStyle.of(context).style.copyWith(
                        color: Colors.pinkAccent,
                        decoration: TextDecoration.none),
                    children: <TextSpan>[
                      TextSpan(
                          text: 'My',
                          style: DefaultTextStyle.of(context).style.copyWith(
                              color: (Theme.of(context).textTheme.bodyLarge?.color),
                              decoration: TextDecoration.none))

                    ],
                  ),
                ),
              )),
          SliverToBoxAdapter(
            child: Column(
              children: [
                Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SearchAnchor(builder:
                        (BuildContext context, SearchController controller) {
                      return SearchBar(
                        controller: controller,
                        padding: const MaterialStatePropertyAll<EdgeInsets>(
                            EdgeInsets.symmetric(horizontal: 16.0)),
                        onChanged: (filter) {
                          appState.filter(filter);
                        },
                        leading: const Icon(Icons.search),
                        trailing: <Widget>[
                          Tooltip(
                            message: 'Change brightness mode',
                            child: IconButton(
                              isSelected: isDarkMode,
                              onPressed: () {
                                setState(() {
                                  isDarkMode = !isDarkMode;
                                  if (isDarkMode) {
                                    MyApp.of(context).changeTheme(ThemeMode.dark);
                                  } else {
                                    MyApp.of(context).changeTheme(ThemeMode.light);
                                  }
                                });
                              },
                              icon: const Icon(Icons.wb_sunny_outlined),
                              selectedIcon:
                                  const Icon(Icons.brightness_2_outlined),
                            ),
                          )
                        ],
                      );
                    }, suggestionsBuilder:
                        (BuildContext context, SearchController controller) {
                      return List<ListTile>.generate(5, (int index) {
                        final String item = 'item $index';
                        return ListTile(
                          title: Text(item),
                          onTap: () {
                            setState(() {
                              controller.closeView(item);
                            });
                          },
                        );
                      });
                    })),
                ChipSelection(
                  currentTag: "",
                  onSelected: appState.filterByTag,
                  addUnassigned: true,
                ),
              ],
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return Card(
                  child: ListTile(
                    title: Text(
                      appState.filteredEntries[index].title,
                      style: itemStyle,
                    ),
                    subtitle: Text(
                      appState.filteredEntries[index].description,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        "/another",
                        arguments: appState.filteredEntries[index],
                      );
                    },
                  ),
                );
              },
              childCount: appState.filteredEntries.length,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, "/another",
              arguments: Entry("", "", [], ""));
        },
        tooltip: 'Add Entry',
        child: Icon(Icons.add),
        //backgroundColor: appState.darkMode ? Colors.pinkAccent : Theme.of(context).floatingActionButtonTheme.backgroundColor ,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
