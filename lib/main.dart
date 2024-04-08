import 'dart:convert';

import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:remindme/TakePictureScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'entry.dart';
import 'my_app_state.dart';

main() {
  runApp(MyApp());
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
        home: _EntryListScreen(),
      ),
    );
  }
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
                    _showEntryDetails(filteredEntries[index]);
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
    setState(() {
      entries.map((e) => {
            if (e.title == title)
              Entry(e.title, e.description, imagePath)
            else
              e
          });
    });
  }

  void _takePicture(BuildContext context, String title) async {
    // Navigator.of(context).pop();
    WidgetsFlutterBinding.ensureInitialized();

    // Obtain a list of the available cameras on the device.
    final cameras = await availableCameras();

    // Get a specific camera from the list of available cameras.
    final firstCamera = cameras.first;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Take Picture'),
          content: TakePictureScreen(
              camera: firstCamera, title: title, onPictureTaken: safeImage),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Ok'),
            ),
          ],
        );
      },
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
                entries.add(Entry(newTitle!, newDescription!, ""));
                filteredEntries = entries;
              });
              await _saveEntries();
            }
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

  void _showEntryDetails(Entry entry) {
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
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Divider(
                thickness: 1,
              ),
              Text(entry.description),
              if (entry.image != "") Image.file(File(entry.image)),
              ElevatedButton(
                onPressed: () {
                  _takePicture(context, entry.title);
                },
                child: Text('Take Picture'),
              ),
            ],
          ),
          actions: <Widget>[
            ElevatedButton(
              style: const ButtonStyle(
                backgroundColor: MaterialStatePropertyAll<Color>(Colors.red),
              ),
              onPressed: () {
                setState(() {
                  entries.remove(entry);
                  filteredEntries = entries;
                });

                Navigator.of(context).pop();
              },
              child: Icon(Icons.delete),
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
