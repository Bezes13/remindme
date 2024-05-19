import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:remindme/ChipSelection.dart';
import 'package:remindme/creation_page.dart';

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
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
          title: 'Remind Me',
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.pinkAccent),
          ),
        routes: {
          '/': (context) => MyHomePage(),
          '/another': (context) => CreationPage(),
        },),
    );
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
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MyAppState>(context, listen: false).loadEntries();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayLarge!;
    final itemStyle = theme.textTheme.displayMedium!;
    var appState = Provider.of<MyAppState>(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(floating: true, title: Text("Remy", style: style,)),
          SliverToBoxAdapter(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      appState.filter(value);
                    },
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      border: UnderlineInputBorder(),
                    ),
                  ),
                ),
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
          Navigator.pushNamed(context, "/another", arguments: Entry("", "", [], ""));
        },
        tooltip: 'Add Entry',
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );

  }
}
