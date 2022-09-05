import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart.dart';
import '../providers/order.dart';
import '../widgets/cart_item_builder.dart';

class CartScreen extends StatefulWidget {
  static const routeName = '/cart';

  const CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  var _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final cartData = Provider.of<Cart>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Your Cart')),
      body: Column(
        children: <Widget>[
          Card(
            margin: const EdgeInsets.all(15),
            child: Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    const Text(
                      'Total',
                      style: TextStyle(fontSize: 20),
                    ),
                    const Spacer(),
                    Chip(
                      label: Text(
                        '\$${cartData.totalAmount.toStringAsFixed(2)}',
                        style: const TextStyle(color: Colors.white),
                      ),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                    ),
                    TextButton(
                      onPressed: (cartData.totalAmount <= 0 || _isLoading)
                          ? null
                          : () async {
                              setState(() {
                                _isLoading = true;
                              });
                              Provider.of<Orders>(context, listen: false)
                                  .addOrder(cartData.items.values.toList(),
                                      cartData.totalAmount)
                                  .then((_) {
                                cartData.clear();

                                setState(() {
                                  _isLoading = false;
                                });
                              });
                            },
                      child: _isLoading
                          ? const CircularProgressIndicator()
                          : Text(
                              'Proceed to Order',
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary),
                            ),
                    )
                  ],
                )),
          ),
          const SizedBox(
            height: 10,
          ),
          Expanded(
              child: ListView.builder(
            itemBuilder: (ctx, i) => CartItemBuilder(
              id: cartData.items.values.toList()[i].id,
              productId: cartData.items.keys.toList()[i],
              title: cartData.items.values.toList()[i].title,
              price: cartData.items.values.toList()[i].price,
              quantity: cartData.items.values.toList()[i].quantity,
            ),
            itemCount: cartData.itemCount,
          ))
        ],
      ),
    );
  }
}
