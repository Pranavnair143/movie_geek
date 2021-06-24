import 'package:flutter/material.dart';
import 'package:movie_geek/screens/Mdetail_screen.dart';
import 'package:movie_geek/screens/TVdetail_screen.dart';
import '../providers/latest_movies_provider.dart';
import '../providers/latest_ott_series.dart';
import 'package:movie_geek/key_data.dart' as kd;
import '../utils/fetch.dart';

class ScrollItem extends StatefulWidget {
  final dynamic item;
  final dynamic itemGenre;

  ScrollItem({
    this.item,
    this.itemGenre,
  });

  @override
  _ScrollItemState createState() => _ScrollItemState();
}

class _ScrollItemState extends State<ScrollItem> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (widget.item.runtimeType == Movie) {
          Navigator.of(context)
              .pushNamed(MDetailScreen.routeName, arguments: widget.item.id);
        } else if (widget.item.runtimeType == TvShow) {
          Navigator.of(context)
              .pushNamed(TVDetailScreen.routeName, arguments: widget.item.id);
        }
      },
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  child: (widget.item.posterPath == null)
                      ? Image.network(
                          kd.noPosterPath,
                          fit: BoxFit.cover,
                          width: 180,
                        )
                      : Image.network(
                          kd.imgUrl + widget.item.posterPath,
                          fit: BoxFit.cover,
                          width: 180,
                        ),
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: FutureBuilder(
                      future: Fetch().fetchAvgRevs(widget.item.id),
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
                                        style: TextStyle(color: Colors.white),
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
            SizedBox(
              width: 160,
              child: Container(
                padding: EdgeInsets.all(10),
                child: Column(children: [
                  Text(
                    widget.item.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    width: 160,
                    child: Builder(builder: (_) {
                      String genreList = '';
                      var l = widget.item.genreIds;
                      for (int i = 0; i < l.length; i++) {
                        var o = widget.itemGenre
                            .firstWhere((element) => element.id == l[i]);
                        if (i == l.length - 1) {
                          genreList += o.genre + '';
                        } else {
                          genreList += o.genre + ', ';
                        }
                      }
                      if (genreList == null) {
                        return Container();
                      } else {
                        return Text(genreList);
                      }
                    }),
                  ),
                ]),
              ),
            )
          ],
        ),
      ),
    );
  }
}
