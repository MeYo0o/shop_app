import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shop_app/models/httpException.dart';
import 'package:http/http.dart' as http;

class Auth with ChangeNotifier {
  FirebaseAuth _auth = FirebaseAuth.instance;
  static const String apiKey =
      'AIzaSyBbReBau9pPvQ7B0iAk2XJN0KHkM7tAKS4';
  String _token; //to manage , store Token
  String _userId; //to distinguish each user uniquely
  DateTime _expiryDate; //to store token expiry date

  Future<void> flutterFirebaseSignUp(
      String email, String password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: email, password: password);
      print('lets Roll...');
      print(userCredential);

      ///Testing
      FirebaseAuth.instance.authStateChanges().listen((User user) {
        if (user == null) {
          print('User is currently signed out!');
        } else {
          print('User is signed in!');
        }
      });

      ///End of Testing
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        // print('The password provided is too weak.');
        throw HttpException(e.code);
      } else if (e.code == 'email-already-in-use') {
        // print('The account already exists for that email.');
        throw HttpException(e.code);
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> flutterFirebaseSignIn(
      String email, String password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      print('lets Roll...');
      print(userCredential.credential);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        // print('No user found for that email.');
        throw HttpException(e.code);
      } else if (e.code == 'wrong-password') {
        // print('Wrong password provided for that user.');
        throw HttpException(e.code);
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> firebaseRESTSignUp(String email, String password) async {
    final String url =
        'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=$apiKey';

    final response = await http.post(
      Uri.parse(url),
      body: json.encode(
        {
          'email': email,
          'password': password,
          'returnSecureToken': true,
        },
      ),
    );

    print(json.decode(response.body));
  }

  Future<void> firebaseRESTSignIn(String email, String password) async {
    final String url = 'https://identitytoolkit.googleapis'
        '.com/v1/accounts:signInWithPassword?key=$apiKey';
    final response = await http.post(
      Uri.parse(url),
      body: json.encode(
        {
          'email': email,
          'password': password,
          'returnSecureToken': true,
        },
      ),
    );

    print(json.decode(response.body));
  }

  //end of class
}
