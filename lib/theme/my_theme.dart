import 'package:flutter/material.dart';

class MyTheme{

  OutlineInputBorder _buildBorder(){
    return OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(20)),
    );
  }

  InputDecorationTheme theme() => InputDecorationTheme(
    contentPadding: EdgeInsets.all(16),
    isDense: true,
    floatingLabelBehavior: FloatingLabelBehavior.always,
    enabledBorder: _buildBorder(),
    errorBorder: _buildBorder(),
    focusedBorder: _buildBorder(),
    focusedErrorBorder: _buildBorder(),
    disabledBorder: _buildBorder(),
    border: _buildBorder()
  );
}