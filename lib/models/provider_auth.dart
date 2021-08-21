import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop_app/models/httpException.dart';
import 'package:http/http.dart' as http;

class Auth with ChangeNotifier {
  //Incase u wanna work with Firebase For Flutter
  // FirebaseAuth _auth = FirebaseAuth.instance;
  static const String apiKey = 'AIzaSyBbReBau9pPvQ7B0iAk2XJN0KHkM7tAKS4';
  String _token; //to manage , store Token
  String _userId; //to distinguish each user uniquely
  DateTime _expiryDate; //to store token expiry date
  Timer _authTimer;

  bool get isAuth {
    // print(_token);
    return token != null;
  }

  String get token {
    if (_expiryDate != null && _expiryDate.isAfter(DateTime.now()) && _token != null) {
      return _token;
    }
    return null;
  }

  String get userId {
    return _userId;
  }

  Future<void> _authenticate(String email, String password, String urlSegment) async {
    final String url = 'https://identitytoolkit.googleapis'
        '.com/v1/accounts:$urlSegment?key=$apiKey';

    try {
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
      final responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        //throwing the error is like return error , it will stop
        // executing the following code
        throw HttpException(responseData['error']['message']);
      }
      //so if we get to this code , we definitely don't have an error
      //storing token , userID and expiry date
      _token = responseData['idToken'];
      _userId = responseData['localId'];
      //as we get dateTime in a string format but in seconds , we
      // must add it to the current dateTime now so we can determine
      // when it's gonna expire ,
      //also remember we need to convert string to int
      _expiryDate = DateTime.now().add(
        Duration(
          seconds: int.parse(
            responseData['expiresIn'],
          ),
        ),
      );

      _autoLogout();
      notifyListeners();
      //store data on device storage
      //1st Initialize the SharedPreferences Service
      final prefs = await SharedPreferences.getInstance();
      //now you can use it's service , store data now
      //json.encode saves complex map data AS String
      final String storedUserData = json.encode({
        'token': _token,
        'userId': _userId,
        'expiryDate': _expiryDate.toIso8601String(),
      });
      //save that string with key = userDataKey , so you can later load the data from that key
      prefs.setString('userDataKey', storedUserData);
    } catch (error) {
      throw error;
    }

    // print(json.decode(response.body));
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    //if the initialized Variable doesn't contain the key we saved the data into , we won't do
    // autoLogin , as the user must re-authenticate
    if (!prefs.containsKey('userDataKey')) {
      return false;
    }
    final extractedUserData = json.decode(prefs.getString('userDataKey')) as Map<String, Object>;
    final expiryDate = DateTime.parse(extractedUserData['expiryDate'] as String);

    //if the extracted expiryDate is before current time , we don't have valid token so we should
    // re-authenticate
    if (expiryDate.isBefore(DateTime.now())) {
      return false;
    }

    _token = extractedUserData['token'] as String;
    _userId = extractedUserData['userId'] as String;
    _expiryDate = expiryDate;
    notifyListeners();
    //start the logout timer
    _autoLogout();
    return true;
  }

  Future<void> firebaseRESTSignUp(String email, String password) async {
    return _authenticate(email, password, 'signUp');
  }

  Future<void> firebaseRESTSignIn(String email, String password) async {
    return _authenticate(email, password, 'signInWithPassword');
  }

  Future<void> flutterFirebaseSignUp(String email, String password) async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
      print('lets Roll...');
      print(userCredential);

      ///Testing the user current state //need to learn streams
      // FirebaseAuth.instance.authStateChanges().listen((User user) {
      //   if (user == null) {
      //     print('User is currently signed out!');
      //   } else {
      //     print('User is signed in!');
      //   }
      // });

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

  Future<void> flutterFirebaseSignIn(String email, String password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
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

  Future<void> logout() async {
    _token = null;
    _userId = null;
    _expiryDate = null;
    if (_authTimer != null) {
      _authTimer.cancel();
      _authTimer = null;
    }
    notifyListeners();
    //as you logout , delete the stored userDataKey
    final prefs = await SharedPreferences.getInstance();
    //this way you can delete specific key
    prefs.remove('userDataKey');
    print('done');
    //this way you can delete all stored keys related to this application
    // prefs.clear();
  }

  void _autoLogout() {
    if (_authTimer != null) {
      _authTimer.cancel();
    }
    final timeToExpiry = _expiryDate.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpiry), logout);
  }

  //end of class
}
