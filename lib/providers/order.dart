import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import '../providers/cart.dart';
import '../models/http_exception.dart';

const API = 'ecomhub-a440c-default-rtdb.firebaseio.com';

class OrderItem {
  final String id;
  final List<CartItem> products;
  final double amount;
  final DateTime dateTime;

  OrderItem(
      {required this.id,
      required this.amount,
      required this.products,
      required this.dateTime});
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> fetchAndSetOrders() async {
    final url = Uri.https(API, '/orders.json');
    final List<OrderItem> loadedOrders = [];

    http.get(url).then((response) {
      if (response.statusCode >= 400) {
        throw HttpException('Could not load orders.');
      }
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData == null) {
        return;
      }
      extractedData.forEach((orderId, orderData) {
        loadedOrders.add(
          OrderItem(
            id: orderId,
            amount: orderData['amount'],
            dateTime: DateTime.parse(orderData['dateTime']),
            products: (orderData['products'] as List<dynamic>)
                .map(
                  (item) => CartItem(
                      id: item['id'],
                      title: item['title'],
                      price: item['price'],
                      quantity: item['quantity']),
                )
                .toList(),
          ),
        );
      });
      _orders = loadedOrders.reversed.toList();
      notifyListeners();
    });
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final url = Uri.https(API, '/orders.json');
    final timestamp = DateTime.now();

    return http
        .post(
      url,
      body: json.encode({
        'dateTime': timestamp.toIso8601String(),
        'amount': total,
        'products': cartProducts
            .map((cp) => {
                  'id': cp.id,
                  'title': cp.title,
                  'price': cp.price,
                  'quantity': cp.quantity
                })
            .toList()
      }),
    )
        .then((response) {
      if (response.statusCode >= 400) {
        throw HttpException('Could not set Favorite.');
      }

      _orders.insert(
          0,
          OrderItem(
              id: json.decode(response.body)['name'],
              dateTime: timestamp,
              amount: total,
              products: cartProducts));
      notifyListeners();
    }).catchError((error) {
      throw error;
    });
  }
}
