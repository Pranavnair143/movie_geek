import 'package:flutter/material.dart';
import 'package:movie_geek/providers/latest_movies_provider.dart' as pvd;
import 'package:movie_geek/widgets/hscroll_view.dart';
import '../models/movie.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:movie_geek/key_data.dart' as kd;
import 'user_review_screen.dart';
import '../widgets/review_section.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'see_all_reviews.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MDetailScreen extends StatefulWidget {
  static const routeName = '/movie-detail';
  @override
  _MDetailScreenState createState() => _MDetailScreenState();
}

class _MDetailScreenState extends State<MDetailScreen> {
  var _isLoading = true;
  Movie item;
  var _showSimilar = false;
  List<dynamic> similarMoviesList = [];
  var _isSimilarLoading = true;
  var _firstFetch = true;
  User user = FirebaseAuth.instance.currentUser;
  Future<bool> isReviewed;

  @override
  void didChangeDependencies() {
    final int movieId = ModalRoute.of(context).settings.arguments as int;
    fetchItemMovieDetails(movieId);
    setState(() {
      isReviewed = _isReviewed(movieId);
    });
    super.didChangeDependencies();
  }

  Future<bool> _isReviewed(int tv_id) async {
    var result = await FirebaseFirestore.instance
        .collection('reviews/')
        .where('itemId', isEqualTo: tv_id)
        .where('userId', isEqualTo: user.uid)
        .get();
    if (result.docs.isEmpty) {
      return false;
    }
    return true;
  }

  void fetchSimilar(int movie_id) async {
    if (_firstFetch) {
      var url =
          'https://api.themoviedb.org/3/movie/${movie_id}/similar?api_key=${kd.apiKey}&language=en-US&page=1';
      var response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        var parsed = json.decode(response.body);
        if (parsed == null) {
          return;
        }
        List<dynamic> _list = [];
        for (final json in parsed['results']) {
          _list.add(pvd.Movie.fromJson(json));
        }
        setState(() {
          similarMoviesList.addAll(_list);
          _firstFetch = false;
          _isSimilarLoading = false;
        });
      }
    }
  }

  void fetchItemMovieDetails(int movie_id) async {
    if (_isLoading) {
      var url =
          'https://api.themoviedb.org/3/movie/${movie_id}?api_key=${kd.apiKey}&language=en-US';
      var response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        var parsed = json.decode(response.body);
        if (parsed == null) {
          return;
        }
        setState(() {
          item = Movie.fromJson(parsed);
          print(item.id.toString());
          _isLoading = false;
        });
      }
    }
  }

  Future<dynamic> _fetchAvgRevs(int id) async {
    final value = await FirebaseFirestore.instance
        .collection('reviews/')
        .where('itemId', isEqualTo: id)
        .get();
    if (value.docs.length == 0) {
      print('helooooo');
      return -1;
    } else {
      int _count = value.docs.length;
      double sum = 0;
      for (var review in value.docs) {
        sum += review['rate'];
      }
      double ans = sum / _count;
      return ans;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: (_isLoading)
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                children: [
                  Container(
                    child: (item.backdropPath == null)
                        ? Image.network(kd.noBackdropPath)
                        : Image.network(kd.imgUrl + item.backdropPath),
                  ),
                  Container(
                    child: Column(
                      children: [
                        Container(
                          height: 250,
                          padding: EdgeInsets.fromLTRB(10, 25, 20, 10),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: (item.posterPath == null)
                                ? Image.network(
                                    kd.noPosterPath,
                                    fit: BoxFit.cover,
                                  )
                                : Image.network(
                                    kd.imgUrl + item.posterPath,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 20,
                          ),
                          child: AutoSizeText(
                            item.name,
                            style: TextStyle(
                              fontSize: 35,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        FutureBuilder(
                            future: _fetchAvgRevs(item.id),
                            builder: (ctx, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Container();
                              } else {
                                print(snapshot.data);
                                if (snapshot.data == -1) {
                                  return Container();
                                } else {
                                  return Wrap(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            0, 10, 10, 0),
                                        child: Text(
                                          'Movie Geek rating',
                                          style: TextStyle(fontSize: 20),
                                        ),
                                      ),
                                      Chip(
                                        backgroundColor: (snapshot.data >= 4)
                                            ? Colors.green
                                            : (snapshot.data >= 2)
                                                ? Colors.yellow.shade900
                                                : Colors.red,
                                        label: Wrap(
                                          children: [
                                            Text(
                                              snapshot.data
                                                  .toString()
                                                  .substring(0, 3),
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                            Icon(
                                              Icons.star,
                                              size: 15,
                                              color: Colors.white,
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  );
                                }
                              }
                            }),
                        Container(
                          child: ListTile(
                            trailing: Text(
                              Duration(minutes: item.runTime)
                                  .toString()
                                  .split('.')[0],
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            leading: Icon(
                              Icons.timer,
                              color: Colors.black,
                            ),
                            title: Text(
                              'Duration',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            horizontalTitleGap: 50,
                            tileColor: Colors.black12,
                          ),
                        ),
                        Container(
                          child: ListTile(
                            trailing: Text(
                              item.releaseDate,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            leading: Icon(
                              Icons.movie_filter_outlined,
                              color: Colors.black,
                            ),
                            title: Text(
                              'Release Date',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            horizontalTitleGap: 50,
                          ),
                        ),
                        Container(
                          child: ListTile(
                            trailing: (item.language == 'hi')
                                ? Text('Hindi',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold))
                                : Text('English',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                            leading: Icon(
                              Icons.language,
                              color: Colors.black,
                            ),
                            title: Text(
                              'Language',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            horizontalTitleGap: 50,
                            tileColor: Colors.black12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Genres',
                              style: TextStyle(fontSize: 35),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 50,
                        child: Builder(builder: (_) {
                          List<dynamic> l = item.genreIds;
                          return ListView.builder(
                              physics: ClampingScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: l.length,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (context, index) => Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Chip(
                                      label: Text(l[index]),
                                    ),
                                  ));
                        }),
                      ),
                      FlatButton(
                        onPressed: () {
                          fetchSimilar(item.id);
                          setState(() {
                            _showSimilar = !_showSimilar;
                          });
                        },
                        child: (_showSimilar == false)
                            ? Text('Show Similar Movies')
                            : Text('Hide Similar Movies'),
                        color: Colors.blue,
                      ),
                      Container(
                        color: Colors.grey.shade200,
                        child: (_showSimilar)
                            ? (_isSimilarLoading)
                                ? Center(child: CircularProgressIndicator())
                                : Container(
                                    child: (similarMoviesList.length == 0)
                                        ? Container(
                                            width: double.infinity,
                                            height: 20,
                                            child: Center(
                                              child: Text(
                                                  'No similar movies available'),
                                            ),
                                          )
                                        : Column(children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  'Similar Movies',
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              height: 400,
                                              child: HscrollView(
                                                itemList: similarMoviesList,
                                                itemType: 'movie',
                                                seeMore: false,
                                              ),
                                            ),
                                          ]),
                                  )
                            : Container(),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Movie Info',
                              style: TextStyle(fontSize: 35),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                        child: Text(
                          item.overview,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Reviews',
                              style: TextStyle(fontSize: 35),
                            ),
                          ],
                        ),
                      ),
                      FutureBuilder(
                          future: _isReviewed(item.id),
                          builder: (ctx, snapshot) {
                            if (snapshot.connectionState == ConnectionState) {
                              return Center(child: CircularProgressIndicator());
                            } else {
                              if (snapshot.data == true) {
                                return Container(
                                    color: Colors.blue.shade100,
                                    padding: EdgeInsets.all(20),
                                    child: Wrap(children: [
                                      Text(
                                          'You have already reviewed about it.See all your reviews '),
                                      InkWell(
                                        child: Text(
                                          'here.',
                                          style: TextStyle(color: Colors.blue),
                                        ),
                                        onTap: () {
                                          Navigator.of(context).pushNamed(
                                              UserReviewScreen.routeName);
                                        },
                                      )
                                    ]));
                              }
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 15),
                                child: ReviewSection(item.id, 'movie'),
                              );
                            }
                          }),
                      ListTile(
                        title: Text("See all reviews "),
                        trailing: Icon(
                          Icons.arrow_forward_ios_outlined,
                        ),
                        onTap: () {
                          Navigator.of(context).pushNamed(
                            SeeAllReviewsScreen.routeName,
                            arguments: item.id,
                          );
                        },
                        tileColor: Colors.grey.shade300,
                      ),
                    ],
                  )
                ],
              ),
            ),
    );
  }
}
