import 'package:flutter/material.dart';

class TvShow {
  int id;
  String name;
  String language;
  String posterPath;
  List<dynamic> genreIds;

  TvShow({
    this.id,
    this.name,
    this.language,
    this.posterPath,
    this.genreIds,
  });

  TvShow.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    language = json['original_language'];
    posterPath = json['poster_path'];
    genreIds = json['genre_ids'];
  }
}

class TvGenre with ChangeNotifier {
  int id;
  String genre;
  TvGenre({this.id, this.genre});

  List<dynamic> genreListJson;

  factory TvGenre.fromJson(Map<String, dynamic> json) {
    return TvGenre(
      id: json['id'] as int,
      genre: json['name'] as String,
    );
  }
}
