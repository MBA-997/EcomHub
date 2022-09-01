import 'package:flutter/material.dart';

import '../widgets/products_grid.dart';

enum FilterOptions {
  all,
  favorites,
}

class ProductOverviewScreen extends StatefulWidget {
  const ProductOverviewScreen({Key? key}) : super(key: key);

  @override
  State<ProductOverviewScreen> createState() => _ProductOverviewScreenState();
}

class _ProductOverviewScreenState extends State<ProductOverviewScreen> {
  @override
  Widget build(BuildContext context) {
    var showFavoriteOnly = false;
    // final productsData = Provider.of<ProductsProvider>(context, listen: false);
    return Scaffold(
        appBar: AppBar(
          title: const Text('EcomHub'),
          actions: <Widget>[
            PopupMenuButton(
                onSelected: (FilterOptions selectedValue) {
                  setState(() {
                    if (selectedValue == FilterOptions.favorites) {
                      showFavoriteOnly = true;
                    } else {
                      showFavoriteOnly = false;
                    }
                  });
                },
                icon: const Icon(
                  Icons.more_vert,
                ),
                itemBuilder: (_) => [
                      const PopupMenuItem(
                          value: FilterOptions.favorites,
                          child: Text('Only Favorites')),
                      const PopupMenuItem(
                          value: FilterOptions.all, child: Text('Show All')),
                    ])
          ],
        ),
        body: ProductsGrid(showFavorites: showFavoriteOnly));
  }
}
