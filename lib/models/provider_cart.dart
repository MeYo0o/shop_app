import 'package:flutter/foundation.dart';

class CartItem {
  final String id, title;
  final int quantity;
  final double price;

  CartItem({
    @required this.id,
    @required this.title,
    @required this.quantity,
    @required this.price,
  });
}

class Cart with ChangeNotifier {
  //Map of items already in the cart
  Map<String, CartItem> _items = {};

  //Map of copied items from the card , so we can edit , add or
  // remove without affecting the original map
  Map<String, CartItem> get items {
    return {..._items};
  }

  //return the cart items as ID , not quantity
  int get itemsCount {
    return items.length;
  }

  //check if a certain item is in the cart or not , check by id
  bool isInCart(String id) {
    return items.containsKey(id);
  }

  double get totalAmountOfAllItems {
    double sum = 0.0;
    _items.forEach((key, cartItem) {
      sum += cartItem.price * cartItem.quantity;
    });
    return sum;
  }

  void addProduct(String productId, String title, double price) {
    //if product already exist in the items map :
    if (_items.containsKey(productId)) {
      //increase it's quantity
      _items.update(
        productId,
        (existCartItem) => CartItem(
          id: DateTime.now().toString(),
          title: existCartItem.title,
          price: existCartItem.price,
          quantity: existCartItem.quantity + 1,
        ),
      );
      //if not :
    } else {
      //add a new product to the items map
      _items.putIfAbsent(
        productId,
        () => CartItem(
          id: productId,
          title: title,
          price: price,
          quantity: 1,
        ),
      );
    }

    //notify listeners
    notifyListeners();
  }

  void removeProduct(String productId) {
    //check if the cart is already in the cart list
    if (_items.containsKey(productId)) {
      _items.remove(productId);
    }
    notifyListeners();
  }

  void removeSingleProduct(String productID) {
    //if the item is not already in the cart with this productID, just return the function
    //This is usable in case someone added an item and quickly went to cart ,removed it
    // then go back to the main screen while the duration of Snackbar is still up and
    // pressed the undo button to delete something that's not already exist.
    if (!_items.containsKey(productID)) {
      print('you are a troller!');
      return;
    }
    //if it's already in the cart , decrease it's quantity by 1
    else if (_items[productID].quantity > 1) {
      _items.update(
        productID,
        (existingItem) => CartItem(
          id: existingItem.id,
          title: existingItem.title,
          quantity: existingItem.quantity - 1,
          price: existingItem.price,
        ),
      );
    }
    //if it's the only item with this productID , delete the item as a whole productID
    else {
      _items.remove(productID);
    }
    notifyListeners();
  }

  void clearCartOnOrder() {
    _items = {};
    notifyListeners();
  }
}
