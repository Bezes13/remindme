import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

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
          home: MyHomePage()),
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

  //Image Picker function to get image from gallery
  Future getImageFromGallery(String title) async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      safeImage(pickedFile.path, title);
    }
  }

  //Image Picker function to get image from camera
  Future getImageFromCamera(String title) async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      safeImage(pickedFile.path, title);
    }
  }

  //Show options to get image from camera or gallery
  Future showOptions(String title) async {
    showCupertinoModalPopup(
      context: context,
      builder: (context) =>
          CupertinoActionSheet(
            actions: [
              CupertinoActionSheetAction(
                child: Text('Photo Gallery'),
                onPressed: () {
                  // close the options modal
                  Navigator.of(context).pop();
                  // get image from gallery
                  getImageFromGallery(title);
                },
              ),
              CupertinoActionSheetAction(
                child: Text('Camera'),
                onPressed: () {
                  // close the options modal
                  Navigator.of(context).pop();
                  // get image from camera
                  getImageFromCamera(title);
                },
              ),
            ],
          ),
    );
  }

  Future showOptionsOnCreate(Function(String) onImagePicked) async {
    showCupertinoModalPopup(
      context: context,
      builder: (context) =>
          CupertinoActionSheet(
            actions: [
              CupertinoActionSheetAction(
                child: Text('Photo Gallery'),
                onPressed: () async {
                  // close the options modal
                  Navigator.of(context).pop();
                  // get image from gallery
                  final pickedFile =
                  await picker.pickImage(source: ImageSource.gallery);
                  if (pickedFile != null) {
                    onImagePicked(pickedFile.path);
                  }
                },
              ),
              CupertinoActionSheetAction(
                child: Text('Camera'),
                onPressed: () async {
                  // close the options modal
                  Navigator.of(context).pop();
                  // get image from camera
                  final pickedFile =
                  await picker.pickImage(source: ImageSource.camera);

                  if (pickedFile != null) {
                    onImagePicked(pickedFile.path);
                  }
                },
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayLarge!;
    final itemStyle = theme.textTheme.displayMedium!;
    var appState = Provider.of<MyAppState>(context);
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
                  appState.filter(value);
                },
                decoration: InputDecoration(
                  hintText: 'Search...',
                  border: UnderlineInputBorder(),
                )),
          ),
          Expanded(
              child: ListView.builder(
                itemCount: appState.filteredEntries.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      title: Text(appState.filteredEntries[index].title,
                          style: itemStyle),
                      subtitle: Text(
                        appState.filteredEntries[index].description,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () {
                        _showEntryDetails(
                            context, appState.filteredEntries[index]);
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
    var appState = Provider.of<MyAppState>(context, listen: false);
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        String? newTitle;
        String? newDescription;
        List<String> images = [];
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: Text('Add New Entry'),
            content: SingleChildScrollView(
              child: Column(
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
                  SizedBox(
                    height: 200,
                    width: double.maxFinite,
                    child: ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemCount: images.length,
                      itemBuilder: (BuildContext context, int index) =>
                          Card(
                            child: Stack(
                              children: [
                                Image.file(File(images[index])),
                                IconButton(
                                    onPressed: () => {},
                                    icon: Icon(Icons.delete))
                              ],
                            ),
                          ),
                    ),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              IconButton(
                onPressed: () {
                  showOptionsOnCreate((p0) =>
                      setState(() {
                        images.add(p0);
                      }));
                },
                icon: Icon(Icons.camera_alt),
              ),
              ElevatedButton(
                onPressed: () async {
                  appState.addNewEntry(newTitle, newDescription, images);
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
        });
      },
    );
  }

  void safeImage(String imagePath, String title) {
    var appState = Provider.of<MyAppState>(context, listen: false);
    Navigator.of(context).pop();
    appState.safeImage(imagePath, title);
    _showEntryDetails(context,
        appState.entries.firstWhere((element) => element.title == title));
  }

  void _showConfirmDialog(String title, Widget content,
      Function confirmAction) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          actionsAlignment: MainAxisAlignment.center,
          title: Text(
            "Remove $title",
            textAlign: TextAlign.center,
            textWidthBasis: TextWidthBasis.parent,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Divider(
                thickness: 1,
              ),
              content
            ],
          ),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                confirmAction();
                Navigator.of(context).pop();
              },
              child: Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  void deleteEntry(Entry entry) {
    var appState = Provider.of<MyAppState>(context, listen: false);
    appState.deleteEntry(entry);
    Navigator.of(context).pop();
  }


  void _showEntryDetails(BuildContext context, Entry entry) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            actionsAlignment: MainAxisAlignment.center,
            title: Text(
              entry.title,
              textAlign: TextAlign.center,
              textWidthBasis: TextWidthBasis.parent,
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Divider(
                    thickness: 1,
                  ),
                  Text(entry.description),
                  SizedBox(
                    height: 200,
                    width: double.maxFinite,
                    child: ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemCount: entry.images.length,
                      itemBuilder: (BuildContext context, int index) =>
                          Card(
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Image.file(File(entry.images[index])),
                                Positioned(
                                  top: -10,
                                  right: -10,
                                  child: IconButton(
                                    onPressed: () {
                                      _showConfirmDialog("Image", Image.file(
                                          File(entry.images[index])), () =>
                                      {
                                        setState(() {
                                          entry.images.removeAt(index);
                                        }),
                                        Provider.of<MyAppState>(
                                            context, listen: false)
                                            .saveEntries()
                                      });
                                    },
                                    icon: const Icon(
                                        Icons.delete, color: Colors.red),
                                  ),
                                )
                              ],
                            ),
                          ),
                    ),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              IconButton(
                onPressed: () {
                  showOptions(entry.title);
                },
                icon: Icon(Icons.camera_alt),
              ),
              IconButton(
                onPressed: () {
                  _showConfirmDialog(
                      entry.title,
                      Text("Do you want to delete the entry ${entry.title}?"),
                      () => deleteEntry(entry));
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
        }
        );
      },
    );
  }
}
