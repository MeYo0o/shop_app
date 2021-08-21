import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Product with ChangeNotifier {
  final String productId, title, description, imageUrl;
  final double price;
  bool isFavorite;

  Product({
    @required this.productId,
    @required this.title,
    @required this.description,
    @required this.imageUrl,
    @required this.price,
    this.isFavorite = false,
  });

  void _changeFavoriteStatusBack(bool newFavoriteStatus) {
    isFavorite = newFavoriteStatus;
    notifyListeners();
  }

  Future<void> toggleFavorite(String authToken, String userId) async {
    bool oldFavStatus = isFavorite;
    isFavorite = !isFavorite;
    final String url = 'https://shop-app-79ea9-default-rtdb.europe-west1'
        '.firebasedatabase.app/userFavorites/$userId/$productId'
        '.json?auth=$authToken';
    try {
      //instead of appending new value for 'isFavorite' each time ,
      // we will replace the existing one with this one , so we used
      // PUT instead of Patch , also we don't want a key to store the
      // value to , we will just store it as true/false to the
      // userId/productId == favStatus
      final response = await http.put(
        Uri.parse(url),
        body: json.encode(
          isFavorite,
        ),
      );
      //handle reverting fav status back to it's state in app memory
      if (response.statusCode >= 400) {
        _changeFavoriteStatusBack(oldFavStatus);
      }
    } catch (error) {
      //handle error here
      _changeFavoriteStatusBack(oldFavStatus);
    }
    notifyListeners();
  }
}
