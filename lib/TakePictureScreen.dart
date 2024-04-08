import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class TakePictureScreen extends StatefulWidget {
  const TakePictureScreen({
    super.key,
    required this.camera,
    required this.title,
    required this.onPictureTaken,
  });

  final CameraDescription camera;
  final Function(String, String) onPictureTaken;
  final String title;

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.medium,
    );

    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FutureBuilder<void>(
          future: _initializeControllerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return CameraPreview(_controller);
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
        FloatingActionButton(
          onPressed: () async {
            try {
              await _initializeControllerFuture;
              final image = await _controller.takePicture();
              widget.onPictureTaken(image.path, widget.title);
              if (!context.mounted) return;
              Navigator.of(context).pop();
            } catch (e) {
              print(e);
            }
          },
          child: const Icon(Icons.camera_alt),
        ),
      ],
    );
  }
}
