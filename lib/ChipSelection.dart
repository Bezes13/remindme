import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'my_app_state.dart';

class ChipSelection extends StatefulWidget {
  const ChipSelection(
      {super.key, required this.currentTag, required this.onSelected});

  final String currentTag;
  final Function(String) onSelected;

  @override
  State<ChipSelection> createState() => _ChipSelectionState();
}

class _ChipSelectionState extends State<ChipSelection> {
  var selectedTag = "";
  @override
  void initState() {
    super.initState();
    selectedTag = widget.currentTag; // Assign the currentTag to selectedTag in initState
  }
  @override
  Widget build(BuildContext context) {
    var appState = Provider.of<MyAppState>(context);
    if (selectedTag == "") {
      return Wrap(
        spacing: 0.0,
        children: appState.allTags.map((String tag) {
          return FilterChip(
            label: Text(tag),
            selected: selectedTag == tag,
            onSelected: (bool selected) {
              setState(() {
                if (selected) {
                  selectedTag = tag;
                } else {
                  selectedTag = "";
                }
                widget.onSelected(tag);
              });
            },
          );
        }).followedBy([
          FilterChip(
              label: Text("create"),
              avatar: Icon(Icons.add),
              selected: false,
              onSelected: (bool selected) {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      String tag = "";
                      return AlertDialog(
                          actionsAlignment: MainAxisAlignment.center,
                          title: Text(
                            "Add new Tag",
                          ),
                          content: TextField(
                              onChanged: (value) {
                                tag = value;
                              },
                              decoration: InputDecoration(
                                hintText: 'Tag Name',
                              )),
                          actions: <Widget>[
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                if(tag != "") {
                                  appState.createTag(tag);
                                }
                              },
                              child: Text('Add'),
                            ),
                          ]);
                    });
              })
        ]).toList(),
      );
    } else {
      return FilterChip(
        label: Text(selectedTag),
        selected: true,
        onSelected: (bool selected) {
          setState(() {
            selectedTag = "";
            widget.onSelected("");
          });
        },
      );
    }
  }
}
