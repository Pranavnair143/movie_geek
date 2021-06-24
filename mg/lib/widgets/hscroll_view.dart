import 'package:flutter/material.dart';
import 'package:movie_geek/widgets/scroll_item.dart';
import '../utils/fetch.dart';
import 'package:movie_geek/key_data.dart' as kd;
import '../screens/See_more_screen.dart';

class HscrollView extends StatelessWidget {
  final List<dynamic> itemList;
  final String screen;
  final String itemType;
  final bool seeMore;

  HscrollView({
    this.itemList,
    this.screen,
    this.itemType,
    this.seeMore = true,
  });
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Fetch().fetchGenre(
            (this.itemType == 'movie') ? kd.movieGenres : kd.tvGenres,
            itemType),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else {
            return ListView.builder(
                physics: ClampingScrollPhysics(),
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemCount: itemList.length + 1,
                itemBuilder: (_, index) {
                  if (index == itemList.length) {
                    if (this.seeMore == false) {
                      return Container();
                    }
                    return Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.all(10),
                        child: IconButton(
                          icon: Icon(Icons.arrow_forward_outlined),
                          onPressed: () {
                            if (this.screen == 'EM') {
                              Navigator.of(context).pushNamed(
                                  SeeMoreScreen.routeName,
                                  arguments: {
                                    'languageCode': 'en',
                                    'Title': 'Latest English Movies',
                                    'urlMain': kd.nowplaying,
                                    'urlGenre': kd.movieGenres,
                                    'type': 'movie',
                                  });
                            } else if (this.screen == 'HM') {
                              Navigator.of(context).pushNamed(
                                  SeeMoreScreen.routeName,
                                  arguments: {
                                    'languageCode': 'hi',
                                    'Title': 'Top Rated Indian Movies',
                                    'urlMain': kd.topRated,
                                    'urlGenre': kd.movieGenres,
                                    'type': 'movie',
                                  });
                            } else if (this.screen == 'ETv') {
                              Navigator.of(context).pushNamed(
                                  SeeMoreScreen.routeName,
                                  arguments: {
                                    'languageCode': 'en',
                                    'Title': 'Popular English TvShows',
                                    'urlMain': kd.popular,
                                    'urlGenre': kd.tvGenres,
                                    'type': 'tv',
                                  });
                            } else if (this.screen == 'HTv') {
                              Navigator.of(context).pushNamed(
                                  SeeMoreScreen.routeName,
                                  arguments: {
                                    'languageCode': 'hi',
                                    'Title': 'Popular Hindi TvShows',
                                    'urlMain': kd.popular,
                                    'urlGenre': kd.tvGenres,
                                    'type': 'tv',
                                  });
                            }
                          },
                        ));
                  } else {
                    return Container(
                      padding: EdgeInsets.all(10),
                      child: ScrollItem(
                          item: itemList[index], itemGenre: snapshot.data),
                    );
                  }
                });
          }
        });
  }
}
