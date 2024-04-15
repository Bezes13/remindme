import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'entry.dart';

class MyAppState extends ChangeNotifier {
  List<Entry> entries = [];
  List<Entry> filteredEntries = [];
  List<String> allTags = ["Minigolf", "Food", "Restaurant", "Vacation"];

  Future<void> loadEntries() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String>? entriesJson = prefs.getStringList('entries');
    allTags = prefs.getStringList('allTags') ?? allTags;
    if (entriesJson != null) {
      entries = entriesJson
          .map((e) => Entry.fromJson((jsonDecode(e)) as Map<String, dynamic>))
          .toList();
      entries.sort((a, b) => a.title.compareTo(b.title));
      filteredEntries = List.from(entries);

      notifyListeners();
    }
  }

  Future<void> saveEntries() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> entriesJson = entries.map((entry) => jsonEncode(entry)).toList();
    await prefs.setStringList('entries', entriesJson);
  }

  void filter(String filterText) {
    filteredEntries = entries
        .where((entry) =>
            entry.title.toLowerCase().contains(filterText.toLowerCase()))
        .toList();
    notifyListeners();
  }

  void addNewEntry(String? oldTitle, String? newTitle, String? newDescription,
      List<String> images, String tag) {
    if (newTitle != null) {
      if (oldTitle != null) {
        entries.removeWhere((element) => oldTitle == element.title);
      }

      entries.add(Entry(newTitle, newDescription ?? "", images, tag));
      entries.sort((a, b) => a.title.compareTo(b.title));
      filteredEntries = entries;
      saveEntries();
      notifyListeners();
    }
  }

  void safeImage(String imagePath, String title) {
    entries = entries.map((entry) {
      if (entry.title == title) {
        entry.images.add(imagePath);
        return Entry(entry.title, entry.description, entry.images, entry.tag);
      } else {
        return entry;
      }
    }).toList();
    filteredEntries = entries;

    saveEntries();
    notifyListeners();
  }

  void addTag(String tag, String title){
    entries = entries.map((entry) {
      if (entry.title == title) {
        return Entry(entry.title, entry.description, entry.images, tag);
      } else {
        return entry;
      }
    }).toList();
    filteredEntries = entries;

    saveEntries();
    notifyListeners();
  }

  Future<void> createTag( String tag) async {
    allTags.add(tag);
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setStringList('allTags', allTags);
    notifyListeners();
  }

  void deleteEntry(Entry entry) {
    entries.remove(entry);
    filteredEntries = entries;
    saveEntries();
    notifyListeners();
  }

  void filterByTag(String tag){
    filteredEntries = entries.where((element) => element.tag == tag).toList();
    notifyListeners();
  }
}
