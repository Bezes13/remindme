import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'entry.dart';

class MyAppState extends ChangeNotifier {
  List<Entry> entries = [];
  List<Entry> filteredEntries = [];
  List<String> allTags = ["Minigolf", "Food", "Restaurant", "Vacation","BucketList"];
  String tag = "";
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
    if(tag == ""){
      filteredEntries = entries;
    }else{
      filteredEntries = entries.where((element) => (element.tag == tag) || element.tag == "" && tag == "Unassigned").toList();
    }
    filteredEntries = filteredEntries
        .where((entry) =>
            entry.title.toLowerCase().contains(filterText.toLowerCase()))
        .toList();
    notifyListeners();
  }

  void addNewEntry(String? oldTitle, String? newTitle, String? newDescription,
      List<String> images, String tag, int rating) {
    if (newTitle != null) {
      if (oldTitle != null) {
        entries.removeWhere((element) => oldTitle == element.title);
      }

      entries.add(Entry(newTitle, newDescription ?? "", images, tag, rating));
      entries.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
      filterWithTag();
      saveEntries();
      notifyListeners();
    }
  }

  void safeImage(String imagePath, String title) {
    entries = entries.map((entry) {
      if (entry.title == title) {
        entry.images.add(imagePath);
        return Entry(entry.title, entry.description, entry.images, entry.tag, entry.rating);
      } else {
        return entry;
      }
    }).toList();
    filterWithTag();

    saveEntries();
    notifyListeners();
  }

  void addTag(String tag, String title){
    entries = entries.map((entry) {
      if (entry.title == title) {
        return Entry(entry.title, entry.description, entry.images, tag, entry.rating);
      } else {
        return entry;
      }
    }).toList();
    filterWithTag();

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
    filterWithTag();
    saveEntries();
    notifyListeners();
  }

  void filterWithTag(){
    if(tag == ""){
      filteredEntries = entries;
    }else{
      filteredEntries = entries.where((element) => (element.tag == tag) || element.tag == "" && tag == "Unassigned").toList();
    }
  }

  void filterByTag(String tag){
    this.tag = tag;
    filterWithTag();
    notifyListeners();
  }

  void removeTag(String tag) {
    allTags.remove(tag);
    entries.map((entry) {
      if (entry.tag == tag) {
        return Entry(entry.title, entry.description, entry.images, "", entry.rating);
      } else {
        return entry;
      }
    }).toList();
    notifyListeners();
  }
}
