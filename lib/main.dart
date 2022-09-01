import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './screens/product_overview_screen.dart';
import './screens/product_detail_screen.dart';
import './screens/cart_screen.dart';
import './screens/order_screen.dart';
import './providers/products_provider.dart';
import './providers/cart.dart';
import './providers/order.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          Provider(create: (ctx) => ProductsProvider()),
          Provider(create: (ctx) => Cart()),
          Provider(create: (ctx) => Orders()),
        ],
        child: MaterialApp(
          title: 'EcomHub',
          theme: ThemeData(
              fontFamily: 'Lato',
              backgroundColor: Colors.white,
              colorScheme: ColorScheme.fromSwatch().copyWith(
                  primary: Colors.black,
                  secondary: const Color.fromARGB(255, 187, 255, 0))),
          home: const ProductOverviewScreen(),
          routes: {
            ProductDetailScreen.routeName: (ctx) => const ProductDetailScreen(),
            CartScreen.routeName: (ctx) => const CartScreen(),
            OrderScreen.routeName: (ctx) => const OrderScreen(),
          },
        ));
  }
}
