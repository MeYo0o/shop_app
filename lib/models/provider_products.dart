import 'package:flutter/foundation.dart';
import 'package:shop_app/models/httpException.dart';
import 'dart:convert';
import 'package:shop_app/models/provider_product.dart';
import 'package:http/http.dart' as http;

class Products with ChangeNotifier {
  List<Product> _items = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 59.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
  ];

  //in case we want to manage the favorite on whole wide app state
  // bool _isFavorite = false;
  //
  // void showFavorite() {
  //   _isFavorite = true;
  //   notifyListeners();
  // }
  //
  // void showAll() {
  //   _isFavorite = false;
  //   notifyListeners();
  // }

  List<Product> get items {
    // if (_isFavorite) {
    //   return _items.where((product) => product.isFavorite).toList();
    // }
    return [..._items];
  }

  List<Product> get filteredProducts {
    return _items.where((product) => product.isFavorite).toList();
  }

  Product filterById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  Future<void> fetchNSetProducts() async {
    const String url =
        'https://shop-app-79ea9-default-rtdb.europe-west1.firebasedatabase.app/products.json';
    try {
      final response = await http.get(Uri.parse(url));
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData == null) {
        return;
      }
      final List<Product> loadedProducts = [];
      extractedData.forEach((prodId, prodValue) {
        loadedProducts.add(
          Product(
            id: prodId,
            title: prodValue['title'],
            description: prodValue['description'],
            imageUrl: prodValue['imageUrl'],
            price: prodValue['price'],
            isFavorite: prodValue['isFavorite'],
          ),
        );
      });
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> addProduct(Product product) async {
    const String url =
        'https://shop-app-79ea9-default-rtdb.europe-west1.firebasedatabase.app/products.json';
    try {
      final response = await http.post(
        Uri.parse(url),
        body: json.encode(
          {
            'id': product.id,
            'title': product.title,
            'price': product.price,
            'description': product.description,
            'imageUrl': product.imageUrl,
            'isFavorite': product.isFavorite,
          },
        ),
      );

      final newProduct = Product(
        //to use the same id the Firebase has.
        id: json.decode(response.body)['name'],
        title: product.title,
        price: product.price,
        description: product.description,
        imageUrl: product.imageUrl,
      );
      _items.add(newProduct);

      ///alternatively you can add the newProduct to the top of the _items list
      /// of Products
      //_items.insert(0,newProduct);
      notifyListeners();
    } catch (error) {
      ///handle error somewhere else ,
      ///in the edit_product_screen cuz of showDialog to the user
      print(error);

      ///return an Error object to be handled somewhere else
      throw error;
    }
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    ///Update everything except favorite status
    final prodIndex = _items.indexWhere((element) => element.id == id);

    //if the prodIndex >=0 , then it has a value as an element in the list ,
    // we can edit it
    if (prodIndex >= 0) {
      final String url =
          'https://shop-app-79ea9-default-rtdb.europe-west1.firebasedatabase'
          '.app/products/$id.json';
      await http.patch(
        Uri.parse(url),
        body: json.encode(
          {
            'title': newProduct.title,
            'description': newProduct.description,
            'price': newProduct.price,
            'imageUrl': newProduct.imageUrl,
          },
        ),
      );
      _items[prodIndex] = newProduct;
      notifyListeners();
    }
    //else , it's not found
    else {
      print('element not found');
    }
  }

  //Update : It's best to be handled in the Product.dart
  ///Only Update FavoriteStatus
  // Future<void> updateProductFavoriteStatus(
  //     String id, Product newProduct) async {
  //   ///Update everything except favorite status
  //   final prodIndex = _items.indexWhere((element) => element.id == id);

  //   //if the prodIndex >=0 , then it has a value as an element in the list ,
  //   // we can edit it
  //   if (prodIndex >= 0) {
  //     final String url =
  //         'https://shop-app-79ea9-default-rtdb.europe-west1.firebasedatabase'
  //         '.app/products/$id.json';
  //     final response = await http.patch(
  //       Uri.parse(url),
  //       body: json.encode(
  //         {
  //           'isFavorite': newProduct.isFavorite,
  //         },
  //       ),
  //     );
  //     if (response.statusCode >= 400) {
  //       //there was an error , handling error
  //     }
  //     _items[prodIndex] = newProduct;
  //     notifyListeners();
  //   }
  //   //else , it's not found
  //   else {
  //     print('element not found');
  //   }
  // }

  Future<void> deleteProduct(String productId) async {
    final url =
        'https://shop-app-79ea9-default-rtdb.europe-west1.firebasedatabase'
        '.app/products/$productId';
    var exitingProductIndex = _items.indexWhere((prod) => prod.id == productId);

    var existingProduct = _items[exitingProductIndex];

    ///remove the product from App Memory first
    _items.removeWhere((element) => element.id == productId);
    notifyListeners();

    ///remove the product from The database via web server
    final response = await http.delete(Uri.parse(url));

    //if there was an error deleting the product
    //you can specify each status code and handle things accordingly
    if (response.statusCode >= 400) {
      ///But if there was an error when deleting the product
      ///the product won't be deleted from the server
      ///but it will be deleted from the App memory , until you do refresh
      ///So , we want to add the product back to the memory as well
      ///using the index and the product we already stored
      _items.insert(exitingProductIndex, existingProduct);
      notifyListeners();

      ///My touch , lol :D
      ///as we already added the product , why don't we null the values we
      ///don't need
      // exitingProductIndex = null;
      // existingProduct = null;

      ///this exception will stop executing the function
      ///any code after catchError won't be executed
      throw HttpException('there was an error');
    }

    ///if no errors were found
    ///clear the stored product from the memory
    ///we don't need to make else{} because the following code
    ///won't run if there were errors
    existingProduct = null;
  }
}
