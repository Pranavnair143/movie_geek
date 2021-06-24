import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../screens/user_review_screen.dart';

class ReviewSection extends StatefulWidget {
  final int itemId;
  final String itemType;
  ReviewSection(this.itemId, this.itemType);
  @override
  _ReviewSectionState createState() => _ReviewSectionState();
}

class _ReviewSectionState extends State<ReviewSection> {
  double _rating = 0;
  double _initialRating = 0;
  Icon _selectedIcon;
  TextEditingController reviewController = TextEditingController();
  bool _isSubmitting = false;
  bool _isReviewed = false;
  void _submit() async {
    try {
      setState(() {
        _isSubmitting = true;
      });
      final user = FirebaseAuth.instance.currentUser;
      await FirebaseFirestore.instance.collection('reviews/').add({
        'itemId': widget.itemId,
        'itemType': widget.itemType,
        'rate': _rating,
        'text': reviewController.text,
        'createdAt': Timestamp.now(),
        'userId': user.uid,
        'userImage': user.photoURL,
        'userName': user.displayName,
      });
      reviewController.clear();
      setState(() {
        _isSubmitting = false;
        _isReviewed = true;
      });
    } catch (error) {
      print(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: (_isReviewed)
            ? Container(
                color: Colors.blue.shade100,
                padding: EdgeInsets.all(20),
                child: Wrap(children: [
                  Text(
                      'You have already reviewed about it. See all your reviews'),
                  InkWell(
                    child: Text(
                      'here',
                      style: TextStyle(color: Colors.blue),
                    ),
                    onTap: () {
                      Navigator.of(context)
                          .pushNamed(UserReviewScreen.routeName);
                    },
                  )
                ]))
            : Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RatingBar.builder(
                        initialRating: _initialRating,
                        minRating: 0,
                        allowHalfRating: true,
                        unratedColor: Colors.amber.withAlpha(50),
                        itemCount: 5,
                        itemSize: 50.0,
                        itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                        itemBuilder: (context, _) => Icon(
                          _selectedIcon ?? Icons.star,
                          color: Colors.amber,
                        ),
                        onRatingUpdate: (rating) {
                          setState(() {
                            _rating = rating;
                          });
                          print(_rating);
                        },
                        updateOnDrag: true,
                      ),
                      if (_rating != 0)
                        Container(
                          child: Column(
                            children: [
                              Text(
                                _rating.toString(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                              ),
                              (_rating <= 2)
                                  ? Text(
                                      'Poor',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                      ),
                                    )
                                  : (_rating < 4)
                                      ? Text(
                                          'Average',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                          ),
                                        )
                                      : Text(
                                          'Superb',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 15,
                                          ),
                                        ),
                            ],
                          ),
                          padding: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: (_rating <= 2)
                                ? Colors.red.shade300
                                : (_rating < 4)
                                    ? Colors.orange.shade300
                                    : Colors.green.shade300,
                            border: Border.all(
                                color: (_rating <= 2)
                                    ? Colors.red
                                    : (_rating < 4)
                                        ? Colors.orange
                                        : Colors.green,
                                width: 5),
                          ),
                        ),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.all(20),
                    child: TextField(
                      maxLines: 8,
                      controller: reviewController,
                      autocorrect: true,
                      decoration:
                          InputDecoration(hintText: 'Write your review'),
                    ),
                  ),
                  Container(
                    child: (_isSubmitting)
                        ? CircularProgressIndicator()
                        : RaisedButton(
                            onPressed: _submit,
                            child: Text(
                              'Submit',
                              style: TextStyle(fontSize: 15),
                            ),
                            color: Colors.blue,
                            padding: EdgeInsets.all(15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                  ),
                ],
              ));
  }
}
