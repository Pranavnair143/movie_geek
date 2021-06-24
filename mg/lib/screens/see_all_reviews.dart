import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:badges/badges.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

class SeeAllReviewsScreen extends StatefulWidget {
  static String routeName = 'see-all-reviews/';

  @override
  _SeeAllReviewsScreenState createState() => _SeeAllReviewsScreenState();
}

class _SeeAllReviewsScreenState extends State<SeeAllReviewsScreen> {
  double _filterMaxRate = 6;
  double _filterMinRate = 0;

  Future<DocumentSnapshot<Map<String, dynamic>>> _fetchUserDetail(
      String userId) async {
    final user = await FirebaseFirestore.instance
        .collection('users/')
        .doc('$userId')
        .get();
    return user;
  }

  @override
  void dispose() {
    double _filterMaxRate = 6;
    double _filterMinRate = 0;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final int itemId = ModalRoute.of(context).settings.arguments as int;
    final DateFormat _formatter = DateFormat('yMMMMd');
    return Scaffold(
      floatingActionButton: SpeedDial(
        icon: Icons.filter_alt_sharp,
        activeIcon: Icons.close,
        closeManually: false,
        children: [
          SpeedDialChild(
            foregroundColor: Colors.red,
            child: Icon(Icons.sentiment_very_dissatisfied_outlined),
            backgroundColor: Colors.white,
            label: 'Poor',
            onTap: () {
              setState(() {
                _filterMaxRate = 2;
                _filterMinRate = 0;
              });
            },
            labelBackgroundColor: Colors.white,
            labelStyle:
                TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
          SpeedDialChild(
              foregroundColor: Colors.yellow.shade900,
              child: Icon(Icons.sentiment_satisfied),
              backgroundColor: Colors.white,
              label: 'Not Bad',
              onTap: () {
                setState(() {
                  _filterMaxRate = 4;
                  _filterMinRate = 2;
                });
              },
              labelStyle: TextStyle(
                  color: Colors.yellow.shade900, fontWeight: FontWeight.bold),
              labelBackgroundColor: Colors.white),
          SpeedDialChild(
            foregroundColor: Colors.green,
            child: Icon(Icons.sentiment_very_satisfied_sharp),
            backgroundColor: Colors.white,
            label: 'Superb',
            labelBackgroundColor: Colors.white,
            labelStyle:
                TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
            onTap: () {
              setState(() {
                _filterMaxRate = 6;
                _filterMinRate = 4;
              });
            },
          )
        ],
      ),
      appBar: AppBar(
        title: Text('See all reviews'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('reviews/')
            .where('itemId', isEqualTo: itemId)
            .where('rate',
                isGreaterThanOrEqualTo: _filterMinRate,
                isLessThan: _filterMaxRate)
            .snapshots(),
        builder: (ctx, streamDoc) {
          if (streamDoc.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            final streamData = streamDoc.data.docs;
            return ListView.builder(
                itemCount: streamData.length,
                itemBuilder: (ctx, index) {
                  return FutureBuilder(
                      future: _fetchUserDetail(streamData[index]['userId']),
                      builder: (ctx, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Container();
                        } else {
                          return Container(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Column(
                              children: [
                                ListTile(
                                  minVerticalPadding: 0,
                                  contentPadding: EdgeInsets.all(0),
                                  leading: CircleAvatar(
                                    backgroundImage: NetworkImage(
                                      snapshot.data['userImgUrl'].toString(),
                                    ),
                                    radius: 25,
                                  ),
                                  title: Wrap(
                                    children: [
                                      Text(
                                        snapshot.data['userName'].toString(),
                                        style: TextStyle(fontSize: 18),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Badge(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          shape: BadgeShape.square,
                                          badgeColor: (streamData[index]
                                                      ['rate'] >=
                                                  4)
                                              ? Colors.green
                                              : (streamData[index]['rate'] > 2)
                                                  ? Colors.yellow.shade900
                                                  : Colors.red,
                                          badgeContent: Wrap(
                                            children: [
                                              Text(
                                                streamData[index]['rate']
                                                    .toString(),
                                                style: TextStyle(
                                                    fontSize: 10,
                                                    color: Colors.white),
                                              ),
                                              Icon(
                                                Icons.star,
                                                size: 10,
                                                color: Colors.white,
                                              ),
                                            ],
                                          ))
                                    ],
                                  ),
                                  subtitle: Text(_formatter.format(
                                      streamData[index]['createdAt'].toDate())),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      streamData[index]['text'],
                                    ),
                                  ],
                                ),
                                Divider(),
                              ],
                            ),
                          );
                        }
                      });
                });
          }
        },
      ),
    );
  }
}
