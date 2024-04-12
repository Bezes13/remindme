import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'entry.dart';

class MyAppState extends ChangeNotifier {
  List<Entry> entries = [];
  List<Entry> filteredEntries = [];

  Future<void> loadEntries() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String>? entriesJson = prefs.getStringList('entries');
    if (entriesJson != null) {
      entries = entriesJson
          .map((e) => Entry.fromJson((jsonDecode(e)) as Map<String, dynamic>))
          .toList();
      filteredEntries = List.from(entries);
      notifyListeners();
    }
  }
  Future<void> saveEntries() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> entriesJson =
    entries.map((entry) => jsonEncode(entry)).toList();
    await prefs.setStringList('entries', entriesJson);
  }

  void filter(String filterText) {
    filteredEntries = entries
        .where((entry) =>
        entry.title
            .toLowerCase()
            .contains(filterText.toLowerCase()))
        .toList();
    notifyListeners();
  }

  void addNewEntry(String? newTitle, String? newDescription,
      List<String> images) {
    if (newTitle != null && newDescription != null) {
      entries.add(Entry(newTitle, newDescription, images));
      filteredEntries = entries;
      saveEntries();
      notifyListeners();
    }
  }

  void safeImage(String imagePath, String title) {
    entries = entries.map((entry) {
      if (entry.title == title) {
        entry.images.add(imagePath);
        return Entry(entry.title, entry.description, entry.images);
      } else {
        return entry;
      }
    }).toList();
    filteredEntries = entries;

    saveEntries();
    notifyListeners();
  }

  void deleteEntry(Entry entry) {
    entries.remove(entry);
    filteredEntries = entries;
    saveEntries();
    notifyListeners();
  }
}
