import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:remindme/ChipSelection.dart';
import 'package:remindme/EntryImage.dart';
import 'package:remindme/entry.dart';
import 'package:remindme/my_app_state.dart';

import 'ConfirmDialog.dart';

class CreationPage extends StatefulWidget {
  const CreationPage({super.key});

  @override
  State<CreationPage> createState() => _CreationPageState();
}

class _CreationPageState extends State<CreationPage> {
  final picker = ImagePicker();

  void _showConfirmDialog(
      String title, Widget content, Function confirmAction) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ConfirmDialog(
            title: title, content: content, confirmAction: confirmAction);
      },
    );
  }

  Future showOptionsOnCreate(Function(String) onImagePicked) async {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
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
    var appState = Provider.of<MyAppState>(context);
    final args = ModalRoute.of(context)!.settings.arguments as Entry;
    String newTitle = args.title;
    String newDescription = args.description;
    List<String> images = args.images;
    String tag = args.tag;
    bool isNew = args.title == "";
    final theme = Theme.of(context);
    final itemStyle = theme.textTheme.displayMedium!;

    return Scaffold(
      appBar: AppBar(title: Text(isNew ? 'Add New Entry' : args.title)),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: TextEditingController(text: newTitle),
                onChanged: (value) {
                  newTitle = value;
                },
                decoration: InputDecoration(
                  hintText: 'Title',
                ),
              ),
            ),
            ChipSelection(
                currentTag: tag,
                onSelected: (selectedTag) => tag = selectedTag,
                addUnassigned: false),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: TextEditingController(text: newDescription),
                minLines: 5,
                maxLines: 20,
                onChanged: (value) {
                  newDescription = value;
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Description',
                ),
              ),
            ),
            if (args.images.isNotEmpty && args.images.length == 1)
              SizedBox(
                  height: 200,
                  child: EntryImage(
                      image: args.images[0],
                      onDelete: () => {
                        setState(() {
                          args.images.removeAt(0);
                        }),
                        Provider.of<MyAppState>(context,
                            listen: false)
                            .saveEntries()
                      },
                      confirmDialog: _showConfirmDialog)
              ),
            if (args.images.isNotEmpty && args.images.length != 1)
              SizedBox(
                height: 200,
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemCount: images.length,
                  itemBuilder: (BuildContext context, int index) => Card(
                      child: EntryImage(
                          image: images[index],
                          onDelete: () => {
                                setState(() {
                                  images.removeAt(index);
                                })
                              },
                          confirmDialog: _showConfirmDialog)),
                ),
              ),
          ],
        ),
      ),
      persistentFooterButtons: <Widget>[
        if (!isNew)


          IconButton(
            onPressed: () async {
              _showConfirmDialog(args.title, Card(
                child: ListTile(
                  title: Text(
                    args.title,
                    style: itemStyle,
                  ),
                  subtitle: Text(
                    args.description,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ), ()=>{
              appState.deleteEntry(args),
              Navigator.pushNamed(context, "/")
              });
            },
            icon: Icon(Icons.delete),
          ),
        IconButton(
          onPressed: () {
            showOptionsOnCreate((p0) => setState(() {
                  images.add(p0);
                }));
          },
          icon: Icon(Icons.add_a_photo),
        )
      ],
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, "/another", arguments: Entry("", "", [], ""));
        },
        tooltip: 'Add Entry',
        child: Icon(Icons.check),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endContained,
      persistentFooterAlignment: AlignmentDirectional.center,
    );
  }
}
