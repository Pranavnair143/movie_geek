class Movie {
  int id;
  String name;
  String language;
  String posterPath;
  List<String> genreIds = [];
  bool adult;
  String backdropPath;
  String overview;
  String releaseDate;
  int runTime;
  String releaseStatus;

  Movie({
    this.id,
    this.name,
    this.language,
    this.posterPath,
    this.genreIds,
    this.adult,
    this.backdropPath,
    this.overview,
    this.releaseDate,
    this.releaseStatus,
    this.runTime,
  });

  Movie.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['title'];
    for (int i = 0; i < json['genres'].length; i++) {
      genreIds.add(json['genres'][i]['name']);
    }
    language = json['original_language'];
    posterPath = json['poster_path'];
    adult = json['adult'];
    backdropPath = json['backdrop_path'];
    overview = json['overview'];
    releaseDate = json['release_date'];
    releaseStatus = json['status'];
    runTime = json['runtime'];
  }
}
