import 'package:flutter/material.dart';
import 'package:movie_geek/screens/See_more_screen.dart';
import 'package:movie_geek/screens/Mdetail_screen.dart';
import 'package:movie_geek/screens/TVdetail_screen.dart';
import 'package:movie_geek/screens/see_all_reviews.dart';
import 'package:movie_geek/screens/signin_screen.dart';
import 'package:movie_geek/screens/user_review_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movie Geek',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SignInScreen(),
      routes: {
        SeeMoreScreen.routeName: (ctx) => SeeMoreScreen(),
        MDetailScreen.routeName: (ctx) => MDetailScreen(),
        TVDetailScreen.routeName: (ctx) => TVDetailScreen(),
        UserReviewScreen.routeName: (ctx) => UserReviewScreen(),
        SeeAllReviewsScreen.routeName: (ctx) => SeeAllReviewsScreen(),
      },
    );
  }
}
