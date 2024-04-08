class Entry {
  final String title;
  final String description;
  final String image;

  Entry(this.title, this.description, this.image);

  Entry.fromJson(Map<String, dynamic> json)
      : title = json['title'] as String,
        description = json['description'] as String,
        image = json['image'];

  Map<String, dynamic> toJson() =>
      {'title': title, 'description': description, 'image': image};
}
