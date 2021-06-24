import 'package:flutter/material.dart';
import 'package:movie_geek/providers/latest_movies_provider.dart';
import 'package:movie_geek/providers/latest_ott_series.dart';
import 'package:movie_geek/widgets/hscroll_view.dart';
import 'package:movie_geek/key_data.dart' as kd;
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/fetch.dart';

class LatestReviewsScreen extends StatefulWidget {
  @override
  _LatestReviewsScreenState createState() => _LatestReviewsScreenState();
}

class _LatestReviewsScreenState extends State<LatestReviewsScreen> {
  Future<List<dynamic>> _fetchTopFive(
      String lang, String baseUrl, String itemType) async {
    var url = baseUrl + '&language=${lang}&page=1';
    List<dynamic> _list = [];
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final parsed = json.decode(response.body);
        if (parsed == null) {
          return null;
        }
        for (int page = 1; page < parsed['total_pages']; page++) {
          if (_list.length >= 5) {
            return _list;
          }
          var url = baseUrl + '&language=${lang}&page=${page}';
          final responseFull = await http.get(Uri.parse(url));
          if (response.statusCode == 200) {
            final parsedFull = json.decode(responseFull.body);
            if (parsedFull == null) {
              return null;
            }
            var perPageResult = parsedFull['results'] as List<dynamic>;
            for (final json in perPageResult) {
              if (json['original_language'] == lang) {
                if (_list.length >= 5) {
                  return _list;
                }
                if (itemType == 'movie') {
                  _list.add(Movie.fromJson(json));
                } else {
                  _list.add(TvShow.fromJson(json));
                }
              }
            }
          }
        }
      }
    } catch (error) {
      print(error);
    }
  }

  Future<void> swipeRefresh() async {
    //Future.wait([
    //  _fetchTopFive('en', kd.nowplaying, 'movie'),
    //  _fetchTopFive('hi', kd.topRated, 'movie'),
    //  _fetchTopFive('en', kd.popular, 'tv'),
    //  _fetchTopFive('hi', kd.popular, 'tv'),
    //]);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Fetch().check(),
      builder: (ctx, connection) {
        if (connection.data == false) {
          return Center(
            child: FlatButton(onPressed: swipeRefresh, child: Text('Refresh')),
          );
        } else {
          return RefreshIndicator(
            onRefresh: swipeRefresh,
            child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FutureBuilder(
                        future: _fetchTopFive('en', kd.nowplaying, 'movie'),
                        builder: (ctx, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          } else {
                            return Column(
                              children: [
                                Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Text(
                                        'Latest English Movies',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 400,
                                  child: HscrollView(
                                    itemList: snapshot.data,
                                    itemType: 'movie',
                                    screen: 'EM',
                                  ),
                                ),
                              ],
                            );
                          }
                        }),
                    FutureBuilder(
                        future: _fetchTopFive('hi', kd.topRated, 'movie'),
                        builder: (ctx, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Container();
                          } else {
                            return Column(
                              children: [
                                Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(11),
                                      child: Text(
                                        'Top Rated Indian Movies',
                                        style: TextStyle(
                                          fontSize: 25,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 400,
                                  child: HscrollView(
                                    itemList: snapshot.data,
                                    screen: 'HM',
                                    itemType: 'movie',
                                  ),
                                ),
                              ],
                            );
                          }
                        }),
                    FutureBuilder(
                        future: _fetchTopFive('en', kd.popular, 'tv'),
                        builder: (ctx, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Container();
                          } else {
                            return Column(
                              children: [
                                Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(11),
                                      child: Text(
                                        'Latest English Tv Shows',
                                        style: TextStyle(
                                          fontSize: 25,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 400,
                                  child: HscrollView(
                                    itemList: snapshot.data,
                                    screen: 'ETv',
                                    itemType: 'tv',
                                  ),
                                ),
                              ],
                            );
                          }
                        }),
                    FutureBuilder(
                        future: _fetchTopFive('hi', kd.popular, 'tv'),
                        builder: (ctx, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Container();
                          } else {
                            return Column(
                              children: [
                                Row(children: [
                                  Padding(
                                    padding: const EdgeInsets.all(11),
                                    child: Text(
                                      'Popular Hindi Tv Shows',
                                      style: TextStyle(
                                        fontSize: 25,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ]),
                                SizedBox(
                                  height: 400,
                                  child: HscrollView(
                                    itemList: snapshot.data,
                                    screen: 'HTv',
                                    itemType: 'tv',
                                  ),
                                ),
                              ],
                            );
                          }
                        }),
                  ],
                )),
          );
        }
      },
    );
  }
}
