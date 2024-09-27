import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../components/ChipSelection.dart';
import '../models/entry.dart';
import '../my_app.dart';
import '../my_app_state.dart';
import 'package:flutter_svg/flutter_svg.dart';

class EntryListScreen extends StatefulWidget {
  @override
  _EntryListScreenState createState() => _EntryListScreenState();
}

class _EntryListScreenState extends State<EntryListScreen> {
  final picker = ImagePicker();
  bool isDarkMode = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MyAppState>(context, listen: false).loadEntries();
    });
  }

  @override
  Widget build(BuildContext context) {
    isDarkMode = Theme.of(context).colorScheme.brightness == Brightness.dark;
    final theme = Theme.of(context);
    final itemStyle = theme.textTheme.displayMedium!;
    var appState = Provider.of<MyAppState>(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            leading: SvgPicture.asset(
              'lib/images/download.svg',
              semanticsLabel: '',
              height: 100,
              width: 70,
              color: Colors.pinkAccent,
            ),
            shadowColor: Colors.grey,
            actions: [
              Tooltip(
                message: 'Change brightness mode',
                child: IconButton(
                  isSelected: !isDarkMode,
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
                  selectedIcon: const Icon(Icons.brightness_2_outlined),
                ),
              )
            ],
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
                          decoration: TextDecoration.none),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SearchAnchor(
                    builder: (BuildContext context, SearchController controller) {
                      return SearchBar(
                        controller: controller,
                        padding: const MaterialStatePropertyAll<EdgeInsets>(
                            EdgeInsets.symmetric(horizontal: 16.0)),
                        onChanged: (filter) {
                          appState.filter(filter);
                        },
                        leading: const Icon(Icons.search),
                      );
                    },
                    suggestionsBuilder: (BuildContext context, SearchController controller) {
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
                    },
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
                  shadowColor: Colors.grey,
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
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
