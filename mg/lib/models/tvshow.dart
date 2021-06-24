class Season {
  int id;
  int episodesCount;
  String name;
  String overview;
  String posterPath;
  int numSeason;

  Season({
    this.id,
    this.episodesCount,
    this.name,
    this.overview,
    this.posterPath,
    this.numSeason,
  });

  Season.fromJson(Map<String, dynamic> seasonJson) {
    id = seasonJson['id'];
    episodesCount = seasonJson['episode_count'];
    name = seasonJson['name'];
    overview = seasonJson['overview'];
    posterPath = seasonJson['poster_path'];
    numSeason = seasonJson['season_number'];
  }
}

class TvShow {
  int id;
  String name;
  List<dynamic> languages;
  String posterPath;
  List<String> genreIds = [];
  bool adult;
  String backdropPath;
  String overview;
  String releaseDate;
  int runTime;
  String releaseStatus;
  int numEpisodes;
  int numSeasons;
  List<Season> seasons = [];

  TvShow({
    this.id,
    this.name,
    this.languages,
    this.posterPath,
    this.genreIds,
    this.adult,
    this.backdropPath,
    this.overview,
    this.releaseDate,
    this.releaseStatus,
    this.runTime,
    this.numEpisodes,
    this.numSeasons,
    this.seasons,
  });

  TvShow.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    for (int i = 0; i < json['genres'].length; i++) {
      genreIds.add(json['genres'][i]['name']);
    }
    languages = json['languages'];
    posterPath = json['poster_path'];
    adult = json['adult'];
    backdropPath = json['backdrop_path'];
    overview = json['overview'];
    releaseDate = json['first_air_date'];
    releaseStatus = json['status'];
    if (json['episode_run_time'].toString() == '[]') {
      runTime = null;
    } else {
      runTime = json['episode_run_time'][0];
    }
    for (int i = 0; i < json['seasons'].length; i++) {
      Season ss = Season.fromJson(json['seasons'][i]);
      seasons.add(ss);
    }
  }
}
