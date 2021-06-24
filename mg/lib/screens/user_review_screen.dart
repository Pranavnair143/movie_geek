import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/rendering.dart';
import 'package:movie_geek/key_data.dart' as kd;
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserReviewScreen extends StatefulWidget {
  static String routeName = 'user-reviews/';
  @override
  _UserReviewScreenState createState() => _UserReviewScreenState();
}

class _UserReviewScreenState extends State<UserReviewScreen> {
  Future<dynamic> fetchItemDetails(int itemId, String itemType) async {
    var url =
        'https://api.themoviedb.org/3/${itemType}/${itemId}?api_key=${kd.apiKey}&language=en-US';

    var response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      var parsed = json.decode(response.body);
      if (parsed == null) {
        return null;
      }
      print(url);
      print(parsed);
      return parsed;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Reviews'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('reviews/')
            .where('userId', isEqualTo: user.uid)
            .snapshots(),
        builder: (ctx, streamDoc) {
          if (streamDoc.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            final revs = streamDoc.data.docs;
            return SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                children: [
                  ListView.builder(
                      physics: ScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: revs.length,
                      itemBuilder: (ctx, index) {
                        return FutureBuilder(
                            future: fetchItemDetails(
                              revs[index]['itemId'],
                              revs[index]['itemType'],
                            ),
                            builder: (ctx, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Container();
                              } else {
                                return Column(children: [
                                  ListTile(
                                    contentPadding: EdgeInsets.all(15),
                                    leading: Container(
                                      child: (snapshot.data['poster_path'] ==
                                              null)
                                          ? Image.network(
                                              kd.noPosterPath.toString(),
                                            )
                                          : Image.network(
                                              kd.imgUrl +
                                                  snapshot.data['poster_path']
                                                      .toString(),
                                            ),
                                    ),
                                    title: Wrap(children: [
                                      Container(
                                        child: (revs[index]['itemType'] == 'tv')
                                            ? Text(snapshot.data['name'] +
                                                '  ' +
                                                revs[index]['rate'].toString() +
                                                '/5')
                                            : Text(snapshot.data['title'] +
                                                '  ' +
                                                revs[index]['rate'].toString() +
                                                '/5'),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            0, 1, 0, 0),
                                        child: Icon(
                                          Icons.star,
                                          size: 17,
                                          color: Colors.yellow,
                                        ),
                                      ),
                                    ]),
                                    subtitle: Text(revs[index]['text']),
                                    trailing: IconButton(
                                      icon: Icon(Icons.delete),
                                      onPressed: () {
                                        FirebaseFirestore.instance
                                            .collection('reviews/')
                                            .doc(revs[index].id)
                                            .delete();
                                      },
                                    ),
                                  ),
                                  Divider()
                                ]);
                              }
                            });
                      }),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
