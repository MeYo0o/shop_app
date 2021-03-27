import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:shop_app/models/provider_product.dart';
// import 'package:shop_app/models/provider_products.dart';
import 'package:shop_app/screens/product_detail_screen.dart';
import 'package:shop_app/models/provider_cart.dart';

class ProductItem extends StatelessWidget {
  // final String id, title, imageUrl;
  //
  // ProductItem({
  //   @required this.id,
  //   @required this.title,
  //   @required this.imageUrl,
  // });

  //Testing worked!
  // final Product product;
  // ProductItem(this.product);

  @override
  Widget build(BuildContext context) {
    final product = Provider.of<Product>(context, listen: false);
    // final products = Provider.of<Products>(context);
    // final cart = Provider.of<Cart>(context, listen: false);
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: GridTile(
        child: InkWell(
          onTap: () {
            Navigator.of(context).pushNamed(
              ProductDetailScreen.id,
              arguments: product.id,
            );
          },
          child: Image.network(
            product.imageUrl,
            fit: BoxFit.cover,
          ),
        ),
        footer: GridTileBar(
          leading: Consumer<Product>(
            builder: (context, product, child) => IconButton(
              icon: Icon(
                product.isFavorite ? Icons.favorite : Icons.favorite_border,
                color: Theme.of(context).accentColor,
              ),
              onPressed: () {
                product.toggleFavorite();
                //Now is handled in Product.dart
                // products.updateProductFavoriteStatus(product.id, product);
              },
            ),
          ),
          title: Text(
            product.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.black87,
          trailing: Consumer<Cart>(
            builder: (context, cart, child) => IconButton(
              icon: Icon(
                cart.isInCart(product.id)
                    ? Icons.shopping_cart
                    : Icons.shopping_cart_outlined,
                color: Theme.of(context).accentColor,
              ),
              onPressed: () {
                ///Optional
                //if not in cart , add product to cart
                // if (!cart.isInCart(product.id)) {
                //   cart.addProduct(
                //     product.id,
                //     product.title,
                //     product.price,
                //   );
                //   //if clicked again and already in cart :
                // } else {
                //   //remove product from cart
                //   cart.removeProduct(product.id);
                // }
                cart.addProduct(
                  product.id,
                  product.title,
                  product.price,
                );

                ///If there is an existing SnackBar showing , hide it
                ScaffoldMessenger.of(context).hideCurrentSnackBar();

                ///Current Flutter 2.0.1 update:
                ///ScaffoldMessenger.hideCurrentSnackBar;

                ///Show New SnackBar as a feedback of adding items to the cart
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Product Added'
                        ' to the Cart'),
                    duration: Duration(seconds: 2),
                    action: SnackBarAction(
                      label: 'UNDO',
                      onPressed: () {
                        cart.removeSingleProduct(product.id);
                      },
                    ),
                  ),
                );
                //for testing
                // print(cart.items.keys);
              },
            ),
          ),
        ),
      ),
    );
  }
}
