import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:movie_geek/screens/home_screen.dart';

class Authentication {
  static Future<FirebaseApp> initializeFirebase(
      {@required BuildContext context}) async {
    FirebaseApp firebaseApp = await Firebase.initializeApp();
    User user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => HomeScreen(
            user,
          ),
        ),
      );
    }
    return firebaseApp;
  }

  static Future<User> signInWithGoogle({@required BuildContext context}) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User user;

    if (kIsWeb) {
      GoogleAuthProvider authProvider = GoogleAuthProvider();

      try {
        final UserCredential userCredential =
            await auth.signInWithPopup(authProvider);
        user = userCredential.user;
        await FirebaseFirestore.instance
            .collection('users/')
            .doc(user.uid)
            .set({
          'userImgUrl': user.photoURL,
          'userName': user.displayName,
        });
      } catch (e) {
        print(e);
        print('Hello');
      }
    } else {
      final GoogleSignIn googleSignIn = GoogleSignIn();

      final GoogleSignInAccount googleSignInAccount =
          await googleSignIn.signIn();

      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );
        try {
          final UserCredential userCredential =
              await auth.signInWithCredential(credential);
          user = userCredential.user;
          await FirebaseFirestore.instance
              .collection('users/')
              .doc(user.uid)
              .set({
            'userImgUrl': user.photoURL,
            'userName': user.displayName,
          });
        } on FirebaseAuthException catch (e) {
          if (e.code == 'account-exists-with-different-credential') {
            print(e);
          } else if (e.code == 'invalid-credential') {
            print(e);
          }
        } catch (e) {
          print(e);
        }
      }
    }

    return user;
  }

  static Future<void> signOut({@required BuildContext context}) async {
    final GoogleSignIn googleSignIn = GoogleSignIn();

    try {
      if (!kIsWeb) {
        await googleSignIn.signOut();
      }
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error signing out. Try again.')));
    }
  }
}
