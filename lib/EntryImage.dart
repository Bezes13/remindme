import 'dart:io';

import 'package:flutter/material.dart';

class EntryImage extends StatelessWidget {
  const EntryImage(
      {super.key,
        required this.image,
        required this.onDelete,
        required this.confirmDialog});

  final String image;
  final Function onDelete;
  final Function(String, Widget, Function) confirmDialog;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Image.file(File(image)),
        Positioned(
          top: -10,
          right: -10,
          child: IconButton(
            onPressed: () {
              confirmDialog("Image", Image.file(File(image)), onDelete);
            },
            icon: const Icon(Icons.delete, color: Colors.red),
          ),
        ),
        Positioned(
          top: -10,
          left: -10,
          child: IconButton(
            onPressed: () {
              _showImageDialog(context, image);
            },
            icon: const Icon(Icons.zoom_in, color: Colors.white),
          ),
        )
      ],
    );
  }

  void _showImageDialog(BuildContext context, String imagePath) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          actionsAlignment: MainAxisAlignment.center,
          content: IconButton(
              onPressed: () => {Navigator.of(context).pop()},
              icon: Image.file(File(imagePath))),
        );
      },
    );
  }
}