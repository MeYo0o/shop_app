import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/provider_products.dart';
import 'product_item.dart';

class ProductsGrid extends StatelessWidget {
  final bool isFavorite;
  ProductsGrid(this.isFavorite);

  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<Products>(context);
    final productsItems = isFavorite
        ? productsData.filteredProducts
        : productsData.items;

    return GridView.builder(
      padding: const EdgeInsets.all(10),
      itemBuilder: (context, i) => ChangeNotifierProvider.value(
        value: productsItems[i],
        child: ProductItem(),
      ),
      itemCount: productsItems.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3 / 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
    );
  }
}
