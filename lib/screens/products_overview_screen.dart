import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/models/provider_cart.dart';
import 'package:shop_app/models/provider_products.dart';
import 'package:shop_app/screens/cart_screen.dart';
import 'package:shop_app/widgets/badge.dart';
import 'package:shop_app/widgets/products_grid.dart';
import 'package:shop_app/widgets/appDrawer.dart';

enum FilterOptions { FavoriteOnly, All }

class ProductsOverViewScreen extends StatefulWidget {
  static const String id = 'POVS';

  @override
  _ProductsOverViewScreenState createState() => _ProductsOverViewScreenState();
}

class _ProductsOverViewScreenState extends State<ProductsOverViewScreen> {
  bool _isFavorite = false;
  bool _isInit = true;
  bool _isLoading = false;

  void _startIndicator() {
    setState(() {
      _isLoading = true;
    });
  }

  void _stopIndicator() {
    setState(() {
      _isLoading = false;
    });
  }

  ///To load up products when the app first launches
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      try {
        _startIndicator();
        Provider.of<Products>(context).fetchNSetProducts().then((_) {
          _stopIndicator();
        });
      }
      //handling errors
      catch (error) {
        print(error);
        _stopIndicator();
      } finally {
        _stopIndicator();
      }
    }
    _isInit = false;
  }

  @override
  Widget build(BuildContext context) {
    // final _productsData = Provider.of<Products>(
    //   context,
    //   listen: false,
    // );

    return Scaffold(
      appBar: AppBar(
        title: Text('Shop App'),
        centerTitle: true,
        actions: [
          PopupMenuButton(
            icon: Icon(Icons.more_vert),
            onSelected: (FilterOptions selectedValue) {
              if (selectedValue == FilterOptions.FavoriteOnly) {
                // _productsData.showFavorite();
                setState(() {
                  _isFavorite = true;
                });
              } else {
                // _productsData.showAll();
                setState(() {
                  _isFavorite = false;
                });
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                child: Text('Show Favorite Only'),
                value: FilterOptions.FavoriteOnly,
              ),
              PopupMenuItem(
                child: Text('Show All'),
                value: FilterOptions.All,
              ),
            ],
          ),
          Consumer<Cart>(
            builder: (context, cart, child) => Badge(
              child: child,
              value: cart.itemsCount.toString(),
              color: Theme.of(context).accentColor,
            ),
            child: IconButton(
              icon: Icon(Icons.shopping_cart),
              onPressed: () {
                Navigator.of(context).pushNamed(CartScreen.id);
              },
            ),
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ProductsGrid(_isFavorite),
      drawer: AppDrawer(),
    );
  }
}
