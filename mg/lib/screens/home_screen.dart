import 'package:flutter/material.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:movie_geek/screens/Mdetail_screen.dart';
import 'package:movie_geek/screens/TVdetail_screen.dart';
import 'package:movie_geek/screens/user_review_screen.dart';
import 'package:movie_geek/utils/authentication.dart';
import 'latest_reviews_screen.dart';
import 'NewsScreen.dart';
import 'package:movie_geek/key_data.dart' as kd;
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/search.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {
  final User user;
  HomeScreen(this.user);
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  User _user;
  int _pageToggleIndex = 0;
  List<Map<String, Object>> _pages;
  final _searchController = FloatingSearchBarController();
  bool _searchLoader = false;
  List<Search> searchResults = [];
  String _query = '';
  bool _isSigningOut = false;

  void _togglePage(int index) {
    setState(() {
      _pageToggleIndex = index;
    });
  }

  void fetchResults(String keyword) async {
    if (!_searchLoader) {
      if ((_query == keyword)) {
        return;
      }
      setState(() {
        _query = keyword;
        _searchLoader = true;
        searchResults.clear();
      });
      List<Search> _list = [];
      if (keyword == '') {
        setState(() {
          searchResults.clear();
          _searchLoader = false;
        });
      } else {
        final url =
            'https://api.themoviedb.org/3/search/multi?api_key=${kd.apiKey}&language=en-US&query=${keyword}&page=1&include_adult=false';
        final response = await http.get(Uri.parse(url));
        final parsed = json.decode(response.body);
        if (parsed == null) {
          return;
        }
        var firstPageResult = parsed['results'] as List<dynamic>;
        for (final json in firstPageResult) {
          if (json['media_type'] == 'movie' || json['media_type'] == 'tv') {
            _list.add(Search.fromJson(json));
          }
        }
        _list.removeWhere((element) => element == null);
        setState(() {
          searchResults = _list.toSet().toList();
          _searchLoader = false;
        });
        _list.clear();
      }
    }
  }

  @override
  void initState() {
    _user = widget.user;
    _pages = [
      {
        'page': LatestReviewsScreen(),
        'title': 'Reviews',
      },
      {
        'page': NewsScreen(),
        'title': 'News',
      }
    ];
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final actions = [
      FloatingSearchBarAction.searchToClear(
        showIfClosed: false,
      ),
    ];
    return Scaffold(
      drawer: Drawer(
        child: Container(
          width: 200,
          child: Column(
            children: [
              Center(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 40, 0, 10),
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(_user.photoURL),
                        radius: 40,
                      ),
                    ),
                    Text(
                      _user.displayName,
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 50,
              ),
              Divider(),
              ListTile(
                leading: Icon(
                  Icons.message_rounded,
                  color: Colors.yellow.shade400,
                ),
                title: Text('Your reviews'),
                onTap: () {
                  Navigator.of(context).pushNamed(UserReviewScreen.routeName);
                },
              ),
              Divider(),
              ListTile(
                onTap: () async {
                  setState(() {
                    _isSigningOut = true;
                  });
                  await Authentication.signOut(context: context);
                  setState(() {
                    _isSigningOut = false;
                  });
                  Navigator.of(context).pop();
                  Navigator.of(context).pushNamed('/');
                },
                leading: Icon(
                  Icons.logout,
                  color: Colors.red,
                ),
                title: Text(
                  'Log out',
                  style: TextStyle(color: Colors.red),
                ),
              )
            ],
          ),
        ),
      ),
      resizeToAvoidBottomInset: false,
      body: FloatingSearchBar(
        automaticallyImplyBackButton: false,
        controller: _searchController,
        clearQueryOnClose: true,
        hint: 'Search',
        transitionDuration: const Duration(milliseconds: 800),
        transitionCurve: Curves.easeInOutCubic,
        physics: const BouncingScrollPhysics(),
        axisAlignment: 0.0,
        openAxisAlignment: 0.0,
        actions: actions,
        progress: _searchLoader,
        onQueryChanged: fetchResults,
        closeOnBackdropTap: true,
        builder: (context, _) => (_query == '')
            ? null
            : Material(
                elevation: 4.0,
                borderRadius: BorderRadius.circular(8),
                child: ListView(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  children: searchResults.map((e) {
                    return ListTile(
                      onTap: () {
                        if (e.type == 'movie') {
                          Navigator.of(context).pushNamed(
                              MDetailScreen.routeName,
                              arguments: e.id);
                        } else if (e.type == 'tv') {
                          Navigator.of(context).pushNamed(
                              TVDetailScreen.routeName,
                              arguments: e.id);
                        }
                      },
                      leading: (e.posterPath == null)
                          ? Image.network(
                              kd.noPosterPath,
                              fit: BoxFit.cover,
                              height: 50,
                              width: 40,
                            )
                          : Image.network(
                              kd.imgUrl + e.posterPath,
                              fit: BoxFit.cover,
                              height: 50,
                              width: 40,
                            ),
                      title: (e.name == null) ? Text('null') : Text(e.name),
                      subtitle: Text(
                        e.type,
                      ),
                    );
                  }).toList(),
                ),
              ),
        body: FloatingSearchAppBar(
          transitionDuration: const Duration(milliseconds: 800),
          body: _pages[_pageToggleIndex]['page'],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedFontSize: 17,
        unselectedItemColor: Colors.black,
        selectedItemColor: Colors.blue,
        onTap: _togglePage,
        currentIndex: _pageToggleIndex,
        type: BottomNavigationBarType.shifting,
        items: [
          BottomNavigationBarItem(
              label: 'Reviews',
              icon: Icon(
                Icons.local_movies_rounded,
              )),
          BottomNavigationBarItem(
            icon: Icon(Icons.new_releases_outlined),
            label: 'MBuzz',
          )
        ],
      ),
    );
  }
}

class ScrollableSearch extends StatelessWidget {
  List<dynamic> _list;
  ScrollableSearch(this._list);
  @override
  Widget build(BuildContext context) {
    return FloatingSearchBarScrollNotifier(
      child: ListView.separated(
        itemCount: _list.length,
        itemBuilder: (context, i) => ListTile(
          title: (_list[i].name == null) ? Text('null') : Text(_list[i].name),
        ),
        separatorBuilder: (context, index) => const Divider(),
      ),
    );
  }
}
/**/