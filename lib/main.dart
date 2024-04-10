import 'dart:convert';

import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:remindme/TakePictureScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'entry.dart';
import 'my_app_state.dart';

main() {
  runApp(MyApp());
  // TODO saveEntries
}

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
        home: MyHomePage()
    ),
    );
    }

}


class TakePictureInfo{
  final CameraDescription camera;
  final Function(String, String) onPictureTaken;
  final String title;

  TakePictureInfo(this.camera, this.onPictureTaken, this.title);
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    Widget page = _EntryListScreen();
    if(appState.currentScreen == Screen.main && appState.picture != null){
      page = TakePictureScreen(camera: appState.picture!.camera, title: appState.picture!.title, onPictureTaken: appState.picture!.onPictureTaken);
    }
    return page;
  }
}

enum Screen {
  main, camera
}

class _EntryListScreen extends StatefulWidget {
  @override
  _EntryListScreenState createState() => _EntryListScreenState();
}

class _EntryListScreenState extends State<_EntryListScreen> {
  List<Entry> entries = [];
  List<Entry> filteredEntries = [];

  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String>? entriesJson = prefs.getStringList('entries');
    if (entriesJson != null) {
      setState(() {
        entries = entriesJson
            .map((e) => Entry.fromJson((jsonDecode(e)) as Map<String, dynamic>))
            .toList();
        filteredEntries = entries;
      });
    }
  }

  Future<void> _saveEntries() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> entriesJson =
        entries.map((entry) => jsonEncode(entry)).toList();
    await prefs.setStringList('entries', entriesJson);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayLarge!;
    final itemStyle = theme.textTheme.displayMedium!;
    return Scaffold(
      appBar: AppBar(
        title: Text('Remind me', style: style),
      ),
      body: Column(
        children: [
          Divider(
            color: Colors.black,
            thickness: 1,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    filteredEntries = entries
                        .where((entry) => entry.title
                            .toLowerCase()
                            .contains(value.toLowerCase()))
                        .toList();
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search...',
                  border: UnderlineInputBorder(),
                )),
          ),
          Expanded(
              child: ListView.builder(
            itemCount: filteredEntries.length,
            itemBuilder: (context, index) {
              return Card(
                child: ListTile(
                  title: Text(filteredEntries[index].title, style: itemStyle),
                  subtitle: Text(
                    filteredEntries[index].description,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () {
                    _showEntryDetails(context, filteredEntries[index]);
                  },
                ),
              );
            },
          ))
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _addEntry(context);
        },
        tooltip: 'Add Entry',
        child: Icon(Icons.add),
      ),
    );
  }

  void _addEntry(BuildContext context) async {
    String? newTitle;
    String? newDescription;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return newEntryDialog(newTitle, newDescription, context);
      },
    );
  }

  void safeImage(String imagePath, String title) {
    Navigator.of(context).pop();
    setState(() {
      entries = entries.map((entry) {
      if (entry.title == title) {
        entry.images.add(imagePath);
        return Entry(entry.title, entry.description, entry.images);
      } else {
        return entry;
      }
    }).toList();
      filteredEntries = entries;
    });
    _showEntryDetails(context, entries.firstWhere((element) => element.title == title));
  }

  void _takePicture(BuildContext context, String title) async {
    // Navigator.of(context).pop();
    WidgetsFlutterBinding.ensureInitialized();

    // Obtain a list of the available cameras on the device.
    final cameras = await availableCameras();

    // Get a specific camera from the list of available cameras.
    final firstCamera = cameras.first;
    var appState = Provider.of<MyAppState>(context, listen: false);
/*
    setState(() {
      appState.picture = TakePictureInfo(firstCamera, safeImage, title);
      appState.currentScreen = Screen.camera;
    });
*/
    Navigator.of(context).pop();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TakePictureScreen(
          camera: firstCamera,
          title: title,
          onPictureTaken: safeImage
          ,
        ),
      ),
    );
  }

  AlertDialog newEntryDialog(
      String? newTitle, String? newDescription, BuildContext context) {
    return AlertDialog(
      title: Text('Add New Entry'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TextField(
            onChanged: (value) {
              newTitle = value;
            },
            decoration: InputDecoration(
              hintText: 'Title',
            ),
          ),
          TextFormField(
            minLines: 5,
            maxLines: 20,
            onChanged: (value) {
              newDescription = value;
            },
            decoration: InputDecoration(
              hintText: 'Description',
            ),
          ),
        ],
      ),
      actions: <Widget>[
        ElevatedButton(
          onPressed: () async {
            if (newTitle != null && newDescription != null) {
              setState(() {
                entries.add(Entry(newTitle!, newDescription!, []));
                filteredEntries = entries;
              });
              await _saveEntries();
            }
            Navigator.of(context).pop();
          },
          child: Text('Add'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancel'),
        ),
      ],
    );
  }

  void _showEntryDetails(BuildContext context, Entry entry) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          actionsAlignment: MainAxisAlignment.center,
          title: Text(
            entry.title,
            textAlign: TextAlign.center,
            textWidthBasis: TextWidthBasis.parent,
          ),
          content: Container(
            height: 200, // Set a height or remove this line if you want it to be unconstrained
            width: double.maxFinite, // Ensure the content takes full width
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Divider(
                  thickness: 1,
                ),
                Text(entry.description),
                Expanded( // Use Expanded to allow ListView.builder to occupy remaining space
                  child: ListView.builder(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemCount: entry.images.length,
                    itemBuilder: (BuildContext context, int index) => Card(
                      child: Image.file(File(entry.images[index])),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            IconButton(
              onPressed: () {
                _takePicture(context, entry.title);
              },
              icon: Icon(Icons.camera_alt),
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  entries.remove(entry);
                  filteredEntries = entries;
                });
                Navigator.of(context).pop();

              },
              icon: Icon(Icons.delete),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );


      },
    );
  }
}
