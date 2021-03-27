import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Product with ChangeNotifier {
  final String id, title, description, imageUrl;
  final double price;
  bool isFavorite;

  Product({
    @required this.id,
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

  Future<void> toggleFavorite() async {
    bool oldFavStatus = isFavorite;
    isFavorite = !isFavorite;
    final String url =
        'https://shop-app-79ea9-default-rtdb.europe-west1.firebasedatabase.app/products/$id.json';
    try {
      final response = await http.patch(
        Uri.parse(url),
        body: json.encode(
          {'isFavorite': isFavorite},
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
