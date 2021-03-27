import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/models/provider_cart.dart';

class CartItem extends StatelessWidget {
  final String id, productId, title;
  final double price;
  final int quantity;

  CartItem({
    @required this.id,
    @required this.productId,
    @required this.title,
    @required this.quantity,
    @required this.price,
  });
  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);
    return Dismissible(
      key: ValueKey(productId),
      background: Container(
        color: Theme.of(context).errorColor,
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
        margin: EdgeInsets.symmetric(horizontal: 15, vertical: 4),
        child: Icon(
          Icons.delete,
          size: 40,
          color: Colors.white,
        ),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (DismissDirection direction) {
        ///Optional
        // if (direction == DismissDirection.endToStart) {
        //   //remove this item from the cartItems list
        //   cart.removeProduct(id);
        // }
        cart.removeProduct(productId);
      },
      confirmDismiss: (direction) {
        return showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('Are You Sure?'),
            content: Text('You are going to delete < $title > from the Cart.'),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(ctx).pop(false);
                },
                child: Text('No'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(ctx).pop(true);
                },
                child: Text('Yes'),
              ),
            ],
          ),
        );
      },
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 15, vertical: 4),
        child: Padding(
          padding: EdgeInsets.all(8),
          child: ListTile(
            leading: CircleAvatar(
              radius: 25,
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: FittedBox(
                  alignment: Alignment.center,
                  child: Text('$price\$'),
                ),
              ),
            ),
            title: Text(title),
            subtitle:
                Text('Total : ${(quantity * price).toStringAsFixed(2)}\$'),
            trailing: Text('X : $quantity'),
          ),
        ),
      ),
    );
  }
}
