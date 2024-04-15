class Entry {
  final String title;
  final String description;
  final List<String> images;
  final String tag;

  Entry(this.title, this.description, this.images, this.tag);

  Entry.fromJson(Map<String, dynamic> json)
      : title = json['title'] as String,
        description = json['description'] as String,
        images = (json['images'] as List<dynamic>).map((e) => e.toString()).toList(),
        tag = (json['tag']??"" as String);

  Map<String, dynamic> toJson() =>
      {'title': title, 'description': description, 'images': images, 'tag': tag};
}
