import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:movie_geek/providers/latest_ott_series.dart' as pvd;
import 'package:movie_geek/screens/see_all_reviews.dart';
import 'package:movie_geek/screens/user_review_screen.dart';
import 'package:movie_geek/widgets/hscroll_view.dart';
import 'package:movie_geek/widgets/review_section.dart';
import 'package:movie_geek/widgets/season_section.dart';
import '../models/tvshow.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:movie_geek/key_data.dart' as kd;

class TVDetailScreen extends StatefulWidget {
  static const routeName = '/tv-detail';
  @override
  _TVDetailScreenState createState() => _TVDetailScreenState();
}

class _TVDetailScreenState extends State<TVDetailScreen> {
  var _isLoading = true;
  TvShow item;
  var _showSimilar = false;
  List<dynamic> similarTvshowList = [];
  var _isSimilarLoading = true;
  var _firstFetch = true;
  User user = FirebaseAuth.instance.currentUser;
  Future<bool> isReviewed;

  @override
  void didChangeDependencies() {
    final int tvshowId = ModalRoute.of(context).settings.arguments as int;
    print(tvshowId);
    fetchItemTvshowDetails(tvshowId);
    setState(() {
      isReviewed = _isReviewed(tvshowId);
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

  Future<dynamic> fetchAvgRevs(int id) async {
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

  void fetchSimilar(int tv_id) async {
    if (_firstFetch) {
      var url =
          'https://api.themoviedb.org/3/tv/${tv_id}/similar?api_key=${kd.apiKey}&language=en-US&page=1';
      var response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        var parsed = json.decode(response.body);
        if (parsed == null) {
          return;
        }
        List<dynamic> _list = [];
        for (final json in parsed['results']) {
          _list.add(pvd.TvShow.fromJson(json));
        }
        setState(() {
          similarTvshowList.addAll(_list);
          _firstFetch = false;
          _isSimilarLoading = false;
        });
      }
    }
  }

  void fetchItemTvshowDetails(int tv_id) async {
    if (_isLoading) {
      var url =
          'https://api.themoviedb.org/3/tv/$tv_id?api_key=${kd.apiKey}&language=en-US';
      var response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        var parsed = json.decode(response.body);
        if (parsed == null) {
          return;
        }
        setState(() {
          item = TvShow.fromJson(parsed);
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: (_isLoading)
          ? Center(child: CircularProgressIndicator())
          : Center(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  children: [
                    Container(
                      child: (item.backdropPath == null)
                          ? Image.network(
                              kd.noBackdropPath,
                            )
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
                              future: fetchAvgRevs(item.id),
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
                              trailing: (item.runTime == null)
                                  ? Text('-')
                                  : Text(
                                      Duration(minutes: item.runTime)
                                          .toString()
                                          .split('.')[0],
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                              leading: Icon(
                                Icons.timer,
                                color: Colors.black,
                              ),
                              title: Text(
                                'Episode Duration',
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
                              trailing: Builder(builder: (_) {
                                var langString = '';
                                for (int i = 0;
                                    i < item.languages.length;
                                    i++) {
                                  langString += item.languages[i] + ' ';
                                }
                                return Text(langString);
                              }),
                              leading: Icon(
                                Icons.language,
                                color: Colors.black,
                              ),
                              title: Text(
                                'Languages',
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
                              ? Text('Show Similar TvShows')
                              : Text('Hide Similar TvShows'),
                          color: Colors.blue,
                        ),
                        Container(
                          color: Colors.grey.shade200,
                          child: (_showSimilar)
                              ? (_isSimilarLoading)
                                  ? Center(child: CircularProgressIndicator())
                                  : Container(
                                      child: (similarTvshowList.length == 0)
                                          ? Container(
                                              width: double.infinity,
                                              height: 20,
                                              child: Center(
                                                child: Text(
                                                    'No similar TvShows available'),
                                              ),
                                            )
                                          : Column(children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    'Similar TvShows',
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                height: 400,
                                                child: HscrollView(
                                                  itemList: similarTvshowList,
                                                  itemType: 'tv',
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
                                'Series Info',
                                style: TextStyle(fontSize: 35),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 15, horizontal: 15),
                          child: Text(
                            item.overview,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        Container(
                          child: (item.seasons == null)
                              ? Container()
                              : Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Season's Details ",
                                            style: TextStyle(fontSize: 35),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SeasonSection(
                                      seasonList: item.seasons,
                                    ),
                                  ],
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
                                return Center(
                                    child: CircularProgressIndicator());
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
                                            style:
                                                TextStyle(color: Colors.blue),
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
                                  child: ReviewSection(item.id, 'tv'),
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
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
