import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:movie_geek/providers/latest_movies_provider.dart';
import 'package:movie_geek/providers/latest_ott_series.dart';
import 'package:connectivity/connectivity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Fetch {
  Future<List<dynamic>> fetchGenre(String url, String itemType) async {
    List<dynamic> _genreList;
    List<dynamic> genreListJson;
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final parsed = json.decode(response.body);
        if (parsed == null) {
          return null;
        }
        genreListJson = parsed['genres'] as List<dynamic>;
        if (itemType == 'movie') {
          _genreList =
              genreListJson.map((json) => MovieGenre.fromJson(json)).toList();
        } else if (itemType == 'tv') {
          _genreList =
              genreListJson.map((json) => TvGenre.fromJson(json)).toList();
        }
        return _genreList;
      }
    } catch (error) {
      print(error);
    }
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

  Future<bool> check() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      return true;
    } else if (connectivityResult == ConnectivityResult.wifi) {
      return true;
    }
    return false;
  }
}
