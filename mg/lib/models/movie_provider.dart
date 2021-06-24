class MovieProvider {
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

  factory MovieProvider.fromJson(Map<String, dynamic> json) {
    return MovieProvider(
      results: json['results'] as List<dynamic>,
      page: json['page'] as int,
      totalPages: json['total_pages'] as int,
      totalResults: json['total_results'] as int,
    );
  }
}
