

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'main.dart';

class MyAppState extends ChangeNotifier {
  Screen currentScreen = Screen.main;
  TakePictureInfo? picture;
}
