import 'package:flutter/material.dart';
import 'package:movie_geek/screens/home_screen.dart';
import 'package:movie_geek/utils/authentication.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  bool _isSigningIn = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Center(
        child: Card(
          color: Colors.white,
          child: Container(
            padding: const EdgeInsets.all(50),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    'Movie Geek',
                    style: TextStyle(fontSize: 50, color: Colors.blue),
                  ),
                  SizedBox(
                    height: 50,
                  ),
                  FutureBuilder(
                    future: Authentication.initializeFirebase(context: context),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Text('Error initializing Firebase');
                      } else if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(
                            backgroundColor: Colors.white,
                          ),
                        );
                      }
                      return SignInButton(
                        Buttons.GoogleDark,
                        text: 'Sign up with Google',
                        onPressed: () async {
                          setState(() {
                            _isSigningIn = true;
                          });
                          User user = await Authentication.signInWithGoogle(
                              context: context);
                          setState(() {
                            _isSigningIn = false;
                          });
                          if (user != null) {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (content) => HomeScreen(user),
                              ),
                            );
                          }
                        },
                      );
                    },
                  ),
                  if (_isSigningIn)
                    CircularProgressIndicator(
                      backgroundColor: Colors.white,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
