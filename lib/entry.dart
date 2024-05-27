class Entry {
  final String title;
  final String description;
  final List<String> images;
  final String tag;
  final int rating;

  Entry(this.title, this.description, this.images, this.tag, this.rating);

  Entry.fromJson(Map<String, dynamic> json)
      : title = json['title'] as String,
        description = json['description'] as String,
        images = (json['images'] as List<dynamic>).map((e) => e.toString()).toList(),
        tag = json['tag']??"",
        rating = json['rating'] as int;

  Map<String, dynamic> toJson() =>
      {'title': title, 'description': description, 'images': images, 'tag': tag, 'rating': rating};
}
