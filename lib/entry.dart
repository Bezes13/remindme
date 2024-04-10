class Entry {
  final String title;
  final String description;
  final List<String> images;

  Entry(this.title, this.description, this.images);

  Entry.fromJson(Map<String, dynamic> json)
      : title = json['title'] as String,
        description = json['description'] as String,
        images = json['images'];

  Map<String, dynamic> toJson() =>
      {'title': title, 'description': description, 'images': images};
}
