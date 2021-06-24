import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:movie_geek/key_data.dart' as kd;
import 'package:movie_geek/utils/fetch.dart';
import 'package:url_launcher/url_launcher.dart';

class NewsScreen extends StatefulWidget {
  @override
  _NewsScreenState createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  Future<List<dynamic>> _fetchNews() async {
    List<dynamic> _news = [];
    var urlUS =
        'https://newsapi.org/v2/top-headlines?country=us&apiKey=${kd.newsApiKey}&category=entertainment';
    var urlIndia =
        'https://newsapi.org/v2/top-headlines?country=in&apiKey=${kd.newsApiKey}&category=entertainment';
    var resUS = http.get(Uri.parse(urlUS));
    var resIndia = http.get(Uri.parse(urlIndia));
    var results = await Future.wait([resIndia, resUS]);
    for (var response in results) {
      if (response.statusCode == 200) {
        var _json = json.decode(response.body);
        if (_json == null) {
          print('helooo');
          return null;
        }
        _news.add(_json['articles']);
      }
    }
    return _news;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Fetch().check(),
      builder: (ctx, internetSnapshot) {
        if (internetSnapshot.data == false) {
          return Center(
            child: FlatButton(
                onPressed: () async {
                  setState(() {});
                },
                child: Text('Refresh')),
          );
        }
        return RefreshIndicator(
          onRefresh: () async {
            await _fetchNews();
            setState(() {});
          },
          child: FutureBuilder(
            future: _fetchNews(),
            builder: (ctx, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else {
                final india = snapshot.data[0];
                final us = snapshot.data[1];
                return SingleChildScrollView(
                  physics: ScrollPhysics(),
                  child: Column(
                    children: [
                      Container(
                        child: Text(
                          'Bollywood Buzz',
                          style: TextStyle(
                              fontSize: 30, fontWeight: FontWeight.bold),
                        ),
                      ),
                      ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: india.length,
                        itemBuilder: (ctx, index) => Column(
                          children: [
                            ListTile(
                              onTap: () async {
                                await canLaunch(india[index]['url'])
                                    ? await launch(india[index]['url'])
                                    : Scaffold.of(context).showSnackBar(SnackBar(
                                        content: Text(
                                            'Could not launch ${india[index]['url']}')));
                              },
                              contentPadding: EdgeInsets.all(15),
                              tileColor: (index % 2 == 0)
                                  ? Colors.blue.shade100
                                  : Colors.white,
                              leading: (india[index]['urlToImage'] != null)
                                  ? Image.network(india[index]['urlToImage'])
                                  : Image.network(kd.noPosterPath),
                              title: Text(
                                india[index]['title'],
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Divider(),
                          ],
                        ),
                      ),
                      Container(
                        child: Text(
                          'Hollywood Buzz',
                          style: TextStyle(
                              fontSize: 30, fontWeight: FontWeight.bold),
                        ),
                      ),
                      ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: us.length,
                          itemBuilder: (ctx, index) => Column(
                                children: [
                                  ListTile(
                                    onTap: () async {
                                      await canLaunch(us[index]['url'])
                                          ? await launch(us[index]['url'])
                                          : Scaffold.of(context).showSnackBar(
                                              SnackBar(
                                                  content: Text(
                                                      'Could not launch ${us[index]['url']}')));
                                    },
                                    contentPadding: EdgeInsets.all(15),
                                    tileColor: (index % 2 == 0)
                                        ? Colors.blue.shade100
                                        : Colors.white,
                                    leading: (us[index]['urlToImage'] != null)
                                        ? Image.network(us[index]['urlToImage'])
                                        : Image.network(kd.noPosterPath),
                                    title: Text(
                                      us[index]['title'],
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Divider(),
                                ],
                              ))
                    ],
                  ),
                );
              }
            },
          ),
        );
      },
    );
  }
}
