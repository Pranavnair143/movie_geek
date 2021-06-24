import 'package:flutter/material.dart';
import 'package:movie_geek/screens/Mdetail_screen.dart';
import '../providers/latest_movies_provider.dart';
import '../providers/latest_ott_series.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:movie_geek/key_data.dart' as kd;
import '../utils/fetch.dart';
import '../key_data.dart' as kd;
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'TVdetail_screen.dart';

class SeeMoreScreen extends StatefulWidget {
  static const routeName = '/EM';

  @override
  _SeeMoreScreenState createState() => _SeeMoreScreenState();
}

class _SeeMoreScreenState extends State<SeeMoreScreen> {
  final ScrollController _controller = new ScrollController();
  static int pageIndex;
  List<dynamic> itemsList = [];
  bool _isLoading = false;
  bool firstFetch = true;
  int totalPages;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    final args =
        ModalRoute.of(context).settings.arguments as Map<String, dynamic>;
    this.fetchItemsList(args['languageCode'], args['urlMain'], args['type']);
    super.didChangeDependencies();
    _controller.addListener(() {
      if (_controller.position.pixels == _controller.position.maxScrollExtent) {
        this.fetchItemsList(
            args['languageCode'], args['urlMain'], args['type']);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void fetchItemsList(String languageCode, String baseUrl, String _type) async {
    if (!_isLoading) {
      setState(() {
        _isLoading = true;
      });
      List<dynamic> _list = [];
      if (firstFetch) {
        setState(() {
          pageIndex = 1;
        });
        var url = baseUrl + '&page=1';
        final response = await http.get(Uri.parse(url));
        final parsed = json.decode(response.body);
        if (parsed == null) {
          return null;
        }
        setState(() {
          firstFetch = false;
          totalPages = parsed['total_pages'];
        });
      }
      for (int page = pageIndex; page < totalPages; page++) {
        if (_list.length >= 10) {
          setState(() {
            _isLoading = false;
            itemsList.addAll(_list);
            pageIndex = page + 1;
          });
          _list.clear();
          break;
        }
        var urlFull = baseUrl + '&page=$page';
        final responseFull = await http.get(Uri.parse(urlFull));
        final parsedFull = json.decode(responseFull.body);
        if (parsedFull == null) {
          return null;
        }
        var perPageResult = parsedFull['results'] as List<dynamic>;
        for (final json in perPageResult) {
          if (languageCode == 'hi') {
            if (['ta', 'hi', 'ml', 'te', 'mr', 'kn']
                .contains(json['original_language'])) {
              if (_type == 'movie') {
                _list.add(Movie.fromJson(json));
              } else if (_type == 'tv') {
                _list.add(TvShow.fromJson(json));
              }
            }
          } else {
            if (json['original_language'] == languageCode) {
              if (_type == 'movie') {
                _list.add(Movie.fromJson(json));
              } else if (_type == 'tv') {
                _list.add(TvShow.fromJson(json));
              }
            }
          }
        }
      }
      setState(() {
        _isLoading = false;
        itemsList.addAll(_list);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context).settings.arguments as Map<String, dynamic>;
    return Scaffold(
      appBar: AppBar(
        title: Text(args['Title']),
      ),
      body: StaggeredGridView.countBuilder(
        crossAxisCount: 4,
        itemCount: itemsList.length,
        controller: _controller,
        itemBuilder: (BuildContext context, int index) => new InkWell(
          onTap: () {
            if (args['type'] == 'movie') {
              Navigator.of(context).pushNamed(MDetailScreen.routeName,
                  arguments: itemsList[index].id);
            } else {
              Navigator.of(context).pushNamed(TVDetailScreen.routeName,
                  arguments: itemsList[index].id);
            }
          },
          child: Card(
            child: Column(
              children: [
                Stack(
                  children: [
                    Container(
                      child: (itemsList[index].posterPath == null)
                          ? Image.network(
                              kd.noPosterPath,
                              fit: BoxFit.cover,
                              width: 180,
                            )
                          : Image.network(
                              kd.imgUrl + itemsList[index].posterPath,
                              fit: BoxFit.cover,
                              width: 180,
                            ),
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child: FutureBuilder(
                          future: Fetch().fetchAvgRevs(itemsList[index].id),
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
                                    Chip(
                                      labelPadding: EdgeInsets.all(2),
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
                                            style:
                                                TextStyle(color: Colors.white),
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
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Text(
                        itemsList[index].name,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      FutureBuilder(
                          future: Fetch()
                              .fetchGenre(args['urlGenre'], args['type']),
                          builder: (ctx, genreSnapshot) {
                            if (genreSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Container();
                            } else {
                              final listMovieGenres = genreSnapshot.data;
                              return SizedBox(
                                width: 160,
                                height: 50,
                                child: Builder(
                                  builder: (_) {
                                    var genString = '';
                                    var l = itemsList[index].genreIds;
                                    for (int i = 0; i < l.length; i++) {
                                      var o = listMovieGenres.firstWhere(
                                          (element) => element.id == l[i]);
                                      if (i == l.length - 1) {
                                        genString += o.genre;
                                      } else {
                                        genString += o.genre + ', ';
                                      }
                                    }
                                    return Text(genString);
                                  },
                                ),
                              );
                            }
                          }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        staggeredTileBuilder: (int index) => new StaggeredTile.fit(2),
        mainAxisSpacing: 4,
        crossAxisSpacing: 4.0,
      ),
//GridView.builder(
//        controller: _controller,
//        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//          //childAspectRatio: (MediaQuery.of(context).size.width) /
//          //    (MediaQuery.of(context).size.height),
//          childAspectRatio: 0.48,
//          crossAxisCount: (orientation == Orientation.portrait) ? 2 : 3,
//        ),
//        itemCount: itemsList.length,
//        itemBuilder: (context, index) {
//          return GridTile(
//            child:
//          );
//        },
//      ),
    );
  }
}
