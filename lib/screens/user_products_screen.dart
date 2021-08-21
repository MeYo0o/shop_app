import 'package:flutter/material.dart';
import 'package:shop_app/models/provider_product.dart';
import 'package:shop_app/models/provider_products.dart';
import 'package:provider/provider.dart';
import '../widgets/appDrawer.dart';
import 'package:shop_app/screens/edit_product_screen.dart';
import 'package:shop_app/widgets/user_product_item.dart';

class UserProductsScreen extends StatelessWidget {
  static const String id = 'user_products_screen';

  Future<void> _refreshProducts(BuildContext context) async {
    await Provider.of<Products>(context, listen: false).fetchNSetProducts(true);
  }

  @override
  Widget build(BuildContext context) {
    // final productsData = Provider.of<Products>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Products'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).pushNamed(EditProductScreen.id);
            },
          ),
        ],
      ),
      body: FutureBuilder(
        future: _refreshProducts(context),
        builder: (context, snapShot) => snapShot.connectionState == ConnectionState.waiting
            ? Center(
                child: CircularProgressIndicator(),
              )
            : RefreshIndicator(
                onRefresh: () => _refreshProducts(context),
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: Consumer<Products>(
                    builder: (context, productsData, child) => ListView.builder(
                      itemCount: productsData.items.length,
                      itemBuilder: (context, i) => Column(
                        children: [
                          UserProductItem(
                            id: productsData.items[i].productId,
                            title: productsData.items[i].title,
                            imageUrl: productsData.items[i].imageUrl,
                          ),
                          Divider(thickness: 0.5),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
      ),
      drawer: AppDrawer(),
    );
  }
}
