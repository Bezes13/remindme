import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:remindme/ChipSelection.dart';
import 'package:remindme/EntryImage.dart';
import 'package:remindme/entry.dart';
import 'package:remindme/my_app_state.dart';

import 'ConfirmDialog.dart';
import 'main.dart';

class CreationPage extends StatefulWidget {
  const CreationPage({super.key});

  @override
  State<CreationPage> createState() => _CreationPageState();
}

class _CreationPageState extends State<CreationPage> {
  final picker = ImagePicker();
  bool isDarkMode = false;
  double rating = 0;
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
          CupertinoActionSheetAction(
            child: Text('Cancel'),
            onPressed: () async {
              // close the options modal
              Navigator.of(context).pop();
              // get image from gallery
            },
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    isDarkMode = Theme.of(context).colorScheme.brightness == Brightness.dark;
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
      // isNew ? 'Add New Entry' : args.title
      body: CustomScrollView(slivers: [
        SliverAppBar(
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
                selectedIcon:
                const Icon(Icons.brightness_2_outlined),
              ),
            )
          ],
          foregroundColor: Colors.pinkAccent.shade100,
          forceElevated: true,
          pinned: true,
          title: Center(
            child: Text(
              (isNew ? 'Add New Entry' : args.title),
              style: DefaultTextStyle.of(context).style.copyWith(
                  color: Colors.pinkAccent, decoration: TextDecoration.none, fontSize: 20 ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(top:8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: TextEditingController(text: newTitle),
                    onChanged: (value) {
                      newTitle = value;
                    },
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(16),
                        isDense: true,
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
                        labelText: "Title"
                    ),
                  ),
                ),
                /*Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Rating: "),
                    RatingStars(
                      axis: Axis.horizontal,
                      value: rating,
                      onValueChanged: (v) {
                        setState(() {
                          rating = v;
                        });
                      },
                      starCount: 5,
                      starSize: 20,
                      valueLabelColor: const Color(0xff9b9b9b),
                      valueLabelTextStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w400,
                          fontStyle: FontStyle.normal,
                          fontSize: 12.0),
                      valueLabelRadius: 5,
                      maxValue: 5,
                      starSpacing: 2,
                      maxValueVisibility: false,
                      valueLabelVisibility: false,
                      animationDuration: Duration(milliseconds: 1000),
                      //valueLabelPadding:
                      //const EdgeInsets.symmetric(vertical: 1, horizontal: 8),
                      //valueLabelMargin: const EdgeInsets.only(right: 8),
                      starOffColor: const Color(0xffe7e8ea),
                      starColor: Colors.yellow,
                      angle: 12,
                    ),
                  ],
                ),*/
                ChipSelection(
                    currentTag: tag,
                    onSelected: (selectedTag) => tag = selectedTag,
                    addUnassigned: false),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: TextEditingController(text: newDescription),
                    maxLines: 10,
                    onChanged: (value) {
                      newDescription = value;
                    },
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.all(16),
                      isDense: true,
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
                      label:  Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.description_outlined),
                            Padding(
                              padding: const EdgeInsets.only(left:8.0),
                              child: Text("Description"),
                            )
                          ],
                        )
                    ),
                  ),
                ),
                Divider(),
                if (args.images.isNotEmpty && args.images.length == 1)
                  SizedBox(
                      height: 200,
                      child: EntryImage(
                          image: args.images[0],
                          onDelete: () => {
                                setState(() {
                                  args.images.removeAt(0);
                                }),
                                Provider.of<MyAppState>(context, listen: false)
                                    .saveEntries()
                              },
                          confirmDialog: _showConfirmDialog)),
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
        ),
      ]),
      persistentFooterButtons: <Widget>[
        IconButton(
          onPressed: () {
            Navigator.pushNamed(context, "/");
          },
          icon: Icon(Icons.home_filled),
        ),
        if (!isNew)
          IconButton(
            onPressed: () async {
              _showConfirmDialog(
                  args.title,
                  Card(
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
                  ),
                  () => {
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
          appState.addNewEntry(args.title, newTitle, newDescription, images, tag, rating.toInt());
          Navigator.pushNamed(context, "/");
        },
        tooltip: 'Add Entry',
        child: Icon(Icons.check),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endContained,
      persistentFooterAlignment: AlignmentDirectional.center,
    );
  }
}
