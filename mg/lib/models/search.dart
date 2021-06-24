class Search {
  int id;
  String name;
  String posterPath;
  String type;

  Search({
    this.id,
    this.name,
    this.posterPath,
    this.type,
  });

  Search.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    if (json['media_type'] == 'movie') {
      name = json['title'];
    } else if (json['media_type'] == 'tv') {
      name = json['name'];
    }
    posterPath = json['poster_path'];
    type = json['media_type'];
  }
}
