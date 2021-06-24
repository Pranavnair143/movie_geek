import 'package:flutter/material.dart';

const apiKey = '6be69e78e94ba4f86b3ceb93664c3daa';

class Movie {
  int id;
  String name;
  String language;
  String posterPath;
  List<dynamic> genreIds;

  Movie({
    this.id,
    this.name,
    this.language,
    this.posterPath,
    this.genreIds,
  });

  Movie.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['title'];
    language = json['original_language'];
    posterPath = json['poster_path'];
    genreIds = json['genre_ids'];
  }

  Map<String, dynamic> toJson() => {
        'id': id,
      };
}

class MovieProvider with ChangeNotifier {
  List<dynamic> results;
  int page;
  int totalPages;
  int totalResults;

  MovieProvider({
    this.results,
    this.page,
    this.totalPages,
    this.totalResults,
  });

  bool loading = false;

  factory MovieProvider.fromJson(Map<String, dynamic> json) {
    return MovieProvider(
      results: json['results'] as List<dynamic>,
      page: json['page'] as int,
      totalPages: json['total_pages'] as int,
      totalResults: json['total_results'] as int,
    );
  }
}

class MovieGenre with ChangeNotifier {
  int id;
  String genre;
  MovieGenre({
    this.id,
    this.genre,
  });

  List<dynamic> genreListJson;

  factory MovieGenre.fromJson(Map<String, dynamic> json) {
    return MovieGenre(
      id: json['id'] as int,
      genre: json['name'] as String,
    );
  }
}
