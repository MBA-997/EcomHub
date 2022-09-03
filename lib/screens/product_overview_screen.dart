import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/cart_screen.dart';
import '../widgets/badge.dart';
import '../widgets/app_drawer.dart';
import '../widgets/products_grid.dart';
import '../providers/cart.dart';

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
  var showFavoriteOnly = false;

  @override
  Widget build(BuildContext context) {
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
                  ]),
          Consumer<Cart>(
            builder: (_, cartData, ch) => Badge(
              value: cartData.itemCount.toString(),
              child: ch as Widget,
            ),
            child: IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () {
                  Navigator.of(context).pushNamed(CartScreen.routeName);
                }),
          )
        ],
      ),
      drawer: const AppDrawer(),
      body: ProductsGrid(showFavorites: showFavoriteOnly),
    );
  }
}
